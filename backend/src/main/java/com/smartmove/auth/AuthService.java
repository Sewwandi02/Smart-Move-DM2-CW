package com.smartmove.auth;

import java.sql.PreparedStatement;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {
    private static final Set<String> REGISTERABLE_ROLES = Set.of("PASSENGER", "DRIVER");

    private final JdbcTemplate jdbc;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwt;

    public AuthService(JdbcTemplate jdbc, PasswordEncoder passwordEncoder, JwtService jwt) {
        this.jdbc = jdbc;
        this.passwordEncoder = passwordEncoder;
        this.jwt = jwt;
    }

    public AuthResponse login(LoginRequest request) {
        String email = normalizeEmail(request.email());
        List<AuthUserRow> rows = jdbc.query("""
                SELECT u.user_id, u.f_name, u.l_name, u.email, u.password, r.role_name
                FROM app_user u
                JOIN user_role ur ON ur.user_id = u.user_id
                JOIN role r ON r.role_id = ur.role_id
                WHERE LOWER(u.email) = ?
                ORDER BY r.role_name
                """, (rs, rowNum) -> new AuthUserRow(
                rs.getLong("user_id"),
                rs.getString("f_name"),
                rs.getString("l_name"),
                rs.getString("email"),
                rs.getString("password"),
                rs.getString("role_name")), email);

        if (rows.isEmpty() || !passwordEncoder.matches(request.password(), rows.get(0).passwordHash())) {
            throw new BadCredentialsException("Invalid email or password.");
        }
        AuthUser user = fromRows(rows);
        return new AuthResponse(jwt.issue(user), user);
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String role = request.role().trim().toUpperCase(Locale.ROOT);
        if (!REGISTERABLE_ROLES.contains(role)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Choose Passenger or Driver.");
        }
        if ("DRIVER".equals(role) && (request.license() == null || request.license().isBlank())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A driver license is required.");
        }
        if (request.password().getBytes(StandardCharsets.UTF_8).length > 72) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Password must be no longer than 72 UTF-8 bytes.");
        }

        Long roleId = jdbc.query("""
                SELECT role_id FROM role WHERE UPPER(role_name) = ?
                """, rs -> rs.next() ? rs.getLong(1) : null, role);
        if (roleId == null) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "The requested account role is not configured in the database.");
        }

        KeyHolder keyHolder = new GeneratedKeyHolder();
        String email = normalizeEmail(request.email());
        try {
            jdbc.update(connection -> {
                PreparedStatement statement = connection.prepareStatement("""
                        INSERT INTO app_user (f_name, l_name, email, password)
                        VALUES (?, ?, ?, ?)
                        """, new String[] {"USER_ID"});
                statement.setString(1, request.firstName().trim());
                statement.setString(2, request.lastName().trim());
                statement.setString(3, email);
                statement.setString(4, passwordEncoder.encode(request.password()));
                return statement;
            }, keyHolder);
        } catch (DuplicateKeyException exception) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "An account with this email already exists.");
        }

        Number generatedId = keyHolder.getKey();
        if (generatedId == null) {
            throw new IllegalStateException("Oracle did not return the generated user ID.");
        }
        long userId = generatedId.longValue();
        jdbc.update("INSERT INTO user_role (user_id, role_id) VALUES (?, ?)", userId, roleId);
        if ("PASSENGER".equals(role)) {
            jdbc.update("INSERT INTO passenger (user_id) VALUES (?)", userId);
        } else {
            jdbc.update("INSERT INTO driver (user_id, license) VALUES (?, ?)", userId, request.license().trim());
        }

        AuthUser user = new AuthUser(userId, request.firstName().trim(), request.lastName().trim(), email, List.of(role));
        return new AuthResponse(jwt.issue(user), user);
    }

    public AuthUser getUser(long userId) {
        List<AuthUserRow> rows = jdbc.query("""
                SELECT u.user_id, u.f_name, u.l_name, u.email, u.password, r.role_name
                FROM app_user u
                JOIN user_role ur ON ur.user_id = u.user_id
                JOIN role r ON r.role_id = ur.role_id
                WHERE u.user_id = ?
                ORDER BY r.role_name
                """, (rs, rowNum) -> new AuthUserRow(
                rs.getLong("user_id"),
                rs.getString("f_name"),
                rs.getString("l_name"),
                rs.getString("email"),
                rs.getString("password"),
                rs.getString("role_name")), userId);
        if (rows.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found.");
        }
        return fromRows(rows);
    }

    private AuthUser fromRows(List<AuthUserRow> rows) {
        AuthUserRow first = rows.get(0);
        List<String> roles = rows.stream()
                .map(row -> row.role().trim().toUpperCase(Locale.ROOT))
                .distinct()
                .toList();
        return new AuthUser(first.id(), first.firstName(), first.lastName(), first.email(), roles);
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private record AuthUserRow(
            long id,
            String firstName,
            String lastName,
            String email,
            String passwordHash,
            String role) {
    }
}
