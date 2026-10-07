package com.smartmove.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

class AuthServiceTest {
    private final JdbcTemplate jdbc = mock(JdbcTemplate.class);
    private final PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
    private final JwtService jwt = new JwtService("a-test-secret-that-is-at-least-thirty-two-bytes-long", 3_600_000);
    private final AuthService auth = new AuthService(jdbc, passwordEncoder, jwt);

    @Test
    void publicRegistrationCannotCreateAnAdmin() {
        RegisterRequest request = new RegisterRequest("Site", "Owner", "owner@example.test",
                "a-long-password", "ADMIN", null);

        ResponseStatusException exception = assertThrows(
                ResponseStatusException.class, () -> auth.register(request));

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatusCode());
        verifyNoInteractions(jdbc, passwordEncoder);
    }

    @Test
    void driverRegistrationRequiresLicense() {
        RegisterRequest request = new RegisterRequest("Driver", "One", "driver@example.test",
                "a-long-password", "DRIVER", " ");

        ResponseStatusException exception = assertThrows(
                ResponseStatusException.class, () -> auth.register(request));

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatusCode());
        verifyNoInteractions(jdbc, passwordEncoder);
    }
}
