package com.smartmove.vehicle;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "VEHICLE")
public class Vehicle {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VEHICLE_ID", nullable = false)
    private Long id;

    @Column(name = "REG_NO", nullable = false, unique = true, length = 20)
    private String regNo;

    @Column(name = "VEHICLE_TYPE", nullable = false, length = 50)
    private String vehicleType;

    @Column(name = "CAPACITY", nullable = false, precision = 5)
    private int capacity;

    @Column(name = "STATUS", length = 20)
    private String status;

    @Column(name = "ADMIN_ID")
    private Long adminId;

    protected Vehicle() {
    }

    public Vehicle(String regNo, String vehicleType, int capacity, String status, Long adminId) {
        this.regNo = regNo;
        this.vehicleType = vehicleType;
        this.capacity = capacity;
        this.status = status;
        this.adminId = adminId;
    }

    public Long getId() {
        return id;
    }

    public String getRegNo() {
        return regNo;
    }

    public String getVehicleType() {
        return vehicleType;
    }

    public int getCapacity() {
        return capacity;
    }

    public String getStatus() {
        return status;
    }

    public Long getAdminId() {
        return adminId;
    }

    public void update(String regNo, String vehicleType, int capacity, String status, Long adminId) {
        this.regNo = regNo;
        this.vehicleType = vehicleType;
        this.capacity = capacity;
        this.status = status;
        this.adminId = adminId;
    }
}
