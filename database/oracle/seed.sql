-- Optional sample vehicle records for a newly created development schema.
-- Identity-generated VEHICLE_ID values are assigned by Oracle.
INSERT INTO Vehicle (reg_no, vehicle_type, capacity, status)
VALUES ('SM-042', 'Volvo 9700', 48, 'Available');

INSERT INTO Vehicle (reg_no, vehicle_type, capacity, status)
VALUES ('SM-018', 'Mercedes Sprinter', 16, 'Maintenance');

COMMIT;
