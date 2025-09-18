-- clinic_db.sql
-- Clinic Booking System - Database schema

CREATE DATABASE IF NOT EXISTS clinic_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinic_db;

-- Patients
CREATE TABLE IF NOT EXISTS patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(30),
    date_of_birth DATE,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Doctors
CREATE TABLE IF NOT EXISTS doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(30),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Specialties (many-to-many for doctors <-> specialties)
CREATE TABLE IF NOT EXISTS specialties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS doctor_specialties (
    doctor_id INT NOT NULL,
    specialty_id INT NOT NULL,
    PRIMARY KEY (doctor_id, specialty_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Services (type of appointment or procedure)
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) DEFAULT 0.00
) ENGINE=InnoDB;

-- Appointments (one patient -- many appointments; one doctor -- many appointments)
CREATE TABLE IF NOT EXISTS appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    service_id INT,
    appointment_time DATETIME NOT NULL,
    duration_minutes INT DEFAULT 30,
    status ENUM('scheduled','completed','cancelled','no_show') DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT uc_appointment UNIQUE (doctor_id, appointment_time) -- prevents double-booking exact time for same doctor
) ENGINE=InnoDB;

-- Optional: staff/users table for admin access
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin','reception','doctor') DEFAULT 'reception',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Useful indexes
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_time ON appointments(appointment_time);

-- Sample data (optional) - uncomment to use
INSERT INTO specialties (name, description) VALUES
('General Practice','General health care'),
('Pediatrics','Child health'),
('Dermatology','Skin specialist');

INSERT INTO doctors (first_name,last_name,email,phone,bio) VALUES
('Amelia','Kip','amelia.kip@example.com','+254700111222','GP with 5 years experience'),
('John','Mwangi','john.mwangi@example.com','+254700333444','Pediatrician');

INSERT INTO doctor_specialties (doctor_id, specialty_id) VALUES
(1,1),(2,2);

INSERT INTO services (name,description,price) VALUES
('Consultation','General consultation',30.00),
('Follow-up','Follow-up appointment',20.00);

INSERT INTO patients (first_name,last_name,email,phone,date_of_birth,address) VALUES
('Dinah','Nato','dinah.nato@example.com','+254700999888','2000-05-01','Nairobi, Kenya');

INSERT INTO appointments (patient_id,doctor_id,service_id,appointment_time,duration_minutes,status)
VALUES (1,1,1,'2025-10-01 09:30:00',30,'scheduled');

