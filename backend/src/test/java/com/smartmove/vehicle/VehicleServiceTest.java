package com.smartmove.vehicle;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class VehicleServiceTest {
    @Mock
    private VehicleRepository vehicles;

    @InjectMocks
    private VehicleService service;

    @Test
    void createUsesOracleDefaultStatusAndTrimsSchemaFields() {
        VehicleRequest request = new VehicleRequest(" SM-042 ", " Volvo 9700 ", 48, null, null);
        when(vehicles.save(any(Vehicle.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Vehicle created = service.create(request);

        ArgumentCaptor<Vehicle> captor = ArgumentCaptor.forClass(Vehicle.class);
        verify(vehicles).save(captor.capture());
        assertNull(created.getId());
        assertEquals("SM-042", captor.getValue().getRegNo());
        assertEquals("Volvo 9700", captor.getValue().getVehicleType());
        assertEquals("Available", captor.getValue().getStatus());
    }
}
