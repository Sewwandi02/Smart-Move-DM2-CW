package com.smartmove.vehicle;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {
    boolean existsByRegNoIgnoreCaseAndIdNot(String regNo, Long id);

    boolean existsByRegNoIgnoreCase(String regNo);

    @Query("""
            SELECT v FROM Vehicle v
            WHERE (:search IS NULL
                OR LOWER(v.vehicleType) LIKE LOWER(CONCAT('%', :search, '%'))
                OR LOWER(v.regNo) LIKE LOWER(CONCAT('%', :search, '%')))
              AND (:status IS NULL OR UPPER(v.status) = UPPER(:status))
            ORDER BY v.id
            """)
    List<Vehicle> search(@Param("search") String search, @Param("status") String status);
}
