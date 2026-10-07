package com.smartmove.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.util.List;
import org.junit.jupiter.api.Test;

class JwtServiceTest {
    private final JwtService jwt = new JwtService(
            "a-test-secret-that-is-at-least-thirty-two-bytes-long",
            3_600_000);

    @Test
    void issuedTokenContainsUserIdentityAndRoles() {
        AuthUser user = new AuthUser(17L, "Ada", "Lovelace", "ada@example.test", List.of("ADMIN"));

        var claims = jwt.parse(jwt.issue(user));

        assertEquals("17", claims.getSubject());
        assertEquals("ada@example.test", claims.get("email"));
        assertEquals(List.of("ADMIN"), claims.get("roles", List.class));
    }

    @Test
    void rejectsWeakSigningSecret() {
        assertThrows(IllegalArgumentException.class, () -> new JwtService("too-short", 3_600_000));
    }
}
