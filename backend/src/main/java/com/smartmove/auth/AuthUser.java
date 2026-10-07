package com.smartmove.auth;

import java.util.List;

public record AuthUser(Long id, String firstName, String lastName, String email, List<String> roles) {
    public String displayName() {
        return firstName + " " + lastName;
    }

    public String primaryRole() {
        if (roles.contains("ADMIN")) return "ADMIN";
        if (roles.contains("DRIVER")) return "DRIVER";
        return "PASSENGER";
    }
}
