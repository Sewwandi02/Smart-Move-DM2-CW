package com.smartmove.auth;

public record AuthResponse(String token, AuthUser user) {
}
