package com.smartmove.vehicle;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/vehicles")
public class VehicleController {
    private final VehicleService vehicles;

    public VehicleController(VehicleService vehicles) {
        this.vehicles = vehicles;
    }

    @GetMapping
    public List<Vehicle> list(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status) {
        return vehicles.list(search, status);
    }

    @GetMapping("/{id}")
    public Vehicle get(@PathVariable Long id) {
        return vehicles.get(id);
    }

    @PostMapping
    public ResponseEntity<Vehicle> create(@Valid @RequestBody VehicleRequest request) {
        Vehicle created = vehicles.create(request);
        return ResponseEntity.created(URI.create("/api/v1/vehicles/" + created.getId())).body(created);
    }

    @PutMapping("/{id}")
    public Vehicle update(@PathVariable Long id, @Valid @RequestBody VehicleRequest request) {
        return vehicles.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        vehicles.delete(id);
        return ResponseEntity.noContent().build();
    }
}
