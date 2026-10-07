package com.smartmove.vehicle;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class VehicleService {
    private final VehicleRepository vehicles;

    public VehicleService(VehicleRepository vehicles) {
        this.vehicles = vehicles;
    }

    public List<Vehicle> list(String search, String status) {
        String normalizedSearch = search == null || search.isBlank() ? null : search.trim();
        String normalizedStatus = status == null || status.isBlank() ? null : status.trim();
        return vehicles.search(normalizedSearch, normalizedStatus);
    }

    public Vehicle get(Long id) {
        return vehicles.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vehicle not found"));
    }

    public Vehicle create(VehicleRequest request) {
        String regNo = request.regNo().trim();
        if (vehicles.existsByRegNoIgnoreCase(regNo)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Registration number already exists");
        }
        String status = request.status() == null || request.status().isBlank()
                ? "Available"
                : request.status().trim();
        return vehicles.save(new Vehicle(regNo, request.vehicleType().trim(),
                request.capacity(), status, request.adminId()));
    }

    public Vehicle update(Long id, VehicleRequest request) {
        Vehicle vehicle = get(id);
        String regNo = request.regNo().trim();
        if (vehicles.existsByRegNoIgnoreCaseAndIdNot(regNo, id)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Registration number already exists");
        }
        String status = request.status() == null || request.status().isBlank()
                ? vehicle.getStatus()
                : request.status().trim();
        vehicle.update(regNo, request.vehicleType().trim(), request.capacity(),
                status, request.adminId());
        return vehicles.save(vehicle);
    }

    public void delete(Long id) {
        vehicles.delete(get(id));
    }
}
