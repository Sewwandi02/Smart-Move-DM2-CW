-- List vehicles, optionally filtering registration/type and status.
SELECT vehicle_id, reg_no, vehicle_type, capacity, status, admin_id
FROM Vehicle
WHERE (:search IS NULL
       OR INSTR(UPPER(vehicle_type), UPPER(:search)) > 0
       OR INSTR(UPPER(reg_no), UPPER(:search)) > 0)
  AND (:status IS NULL OR UPPER(status) = UPPER(:status))
ORDER BY vehicle_id;

-- Read one vehicle.
SELECT vehicle_id, reg_no, vehicle_type, capacity, status, admin_id
FROM Vehicle
WHERE vehicle_id = :vehicle_id;

-- Create a vehicle; Oracle generates VEHICLE_ID.
INSERT INTO Vehicle (reg_no, vehicle_type, capacity, status, admin_id)
VALUES (:reg_no, :vehicle_type, :capacity, COALESCE(:status, 'Available'), :admin_id);

-- Update a vehicle.
UPDATE Vehicle
SET reg_no = :reg_no,
    vehicle_type = :vehicle_type,
    capacity = :capacity,
    status = COALESCE(:status, status),
    admin_id = :admin_id
WHERE vehicle_id = :vehicle_id;

-- Delete a vehicle.
DELETE FROM Vehicle
WHERE vehicle_id = :vehicle_id;
