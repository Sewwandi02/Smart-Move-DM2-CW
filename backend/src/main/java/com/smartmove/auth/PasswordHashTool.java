package com.smartmove.auth;

import java.io.Console;
import java.nio.charset.StandardCharsets;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public final class PasswordHashTool {
    private PasswordHashTool() {
    }

    public static void main(String[] args) {
        Console console = System.console();
        if (console == null) {
            throw new IllegalStateException("Run this helper in an interactive terminal with password echo disabled.");
        }
        char[] password = console.readPassword("Admin password: ");
        try {
            if (password == null || password.length < 8) {
                throw new IllegalArgumentException("Password must contain at least 8 characters.");
            }
            if (new String(password).getBytes(StandardCharsets.UTF_8).length > 72) {
                throw new IllegalArgumentException("Password must be no longer than 72 UTF-8 bytes.");
            }
            System.out.println(new BCryptPasswordEncoder().encode(new String(password)));
        } finally {
            if (password != null) {
                java.util.Arrays.fill(password, '\0');
            }
        }
    }
}
