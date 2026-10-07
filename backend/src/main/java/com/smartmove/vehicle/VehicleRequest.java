package com.smartmove.vehicle;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record VehicleRequest(
        @NotBlank @Size(max = 20) String regNo,
        @NotBlank @Size(max = 50) String vehicleType,
        @Min(1) @Max(99999) int capacity,
        @Size(max = 20) String status,
        Long adminId) {
}
