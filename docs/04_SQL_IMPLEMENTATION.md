# Car Rental System - SQL Implementation

## 1. Database Setup

### 1.1 Database Creation

```sql
CREATE DATABASE car_rental_system;
```

### 1.2 Enum Types

```sql
CREATE TYPE vehicle_status AS ENUM (
    'available',
    'reserved',
    'rented',
    'maintenance',
    'out_of_service'
);

CREATE TYPE booking_status AS ENUM (
    'pending',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled'
);

CREATE TYPE payment_status AS ENUM (
    'pending',
    'completed',
    'failed',
    'refunded'
);

CREATE TYPE payment_method AS ENUM (
    'credit_card',
    'debit_card',
    'cash',
    'bank_transfer'
);

CREATE TYPE fuel_level AS ENUM (
    'empty',
    'quarter',
    'half',
    'three_quarters',
    'full'
);

CREATE TYPE maintenance_type AS ENUM (
    'routine',
    'repair',
    'accident',
    'recall'
);

CREATE TYPE maintenance_status AS ENUM (
    'scheduled',
    'in_progress',
    'completed',
    'cancelled'
);
```

## 2. Table Creation

### 2.1 Core Tables

```sql
-- Vehicle Categories
CREATE TABLE vehicle_categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    daily_rate DECIMAL(10,2) NOT NULL,
    weekly_rate DECIMAL(10,2) NOT NULL,
    monthly_rate DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Rental Locations
CREATE TABLE rental_locations (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES vehicle_categories(category_id),
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    color VARCHAR(30) NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    vin VARCHAR(17) NOT NULL UNIQUE,
    mileage INTEGER NOT NULL DEFAULT 0,
    status vehicle_status NOT NULL DEFAULT 'available',
    current_location_id INTEGER REFERENCES rental_locations(location_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    license_state VARCHAR(50) NOT NULL,
    license_expiry DATE NOT NULL,
    date_of_birth DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (license_number, license_state)
);

-- Bookings
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id),
    pickup_location_id INTEGER NOT NULL REFERENCES rental_locations(location_id),
    dropoff_location_id INTEGER NOT NULL REFERENCES rental_locations(location_id),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status booking_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Payments
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES bookings(booking_id),
    amount DECIMAL(10,2) NOT NULL,
    payment_method payment_method NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status payment_status NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Rental History
CREATE TABLE rental_history (
    history_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES bookings(booking_id),
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id),
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    actual_pickup_date TIMESTAMP WITH TIME ZONE,
    actual_dropoff_date TIMESTAMP WITH TIME ZONE,
    initial_mileage INTEGER NOT NULL,
    final_mileage INTEGER,
    fuel_level_pickup fuel_level NOT NULL,
    fuel_level_dropoff fuel_level,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Maintenance Records
CREATE TABLE maintenance_records (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id),
    maintenance_type maintenance_type NOT NULL,
    description TEXT NOT NULL,
    maintenance_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completion_date TIMESTAMP WITH TIME ZONE,
    cost DECIMAL(10,2) NOT NULL,
    mileage INTEGER NOT NULL,
    status maintenance_status NOT NULL DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## 3. Indexes

### 3.1 Foreign Key Indexes

```sql
CREATE INDEX idx_vehicles_category ON vehicles(category_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_location ON vehicles(current_location_id);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_vehicle ON bookings(vehicle_id);
CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);
CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_rental_history_vehicle ON rental_history(vehicle_id);
CREATE INDEX idx_rental_history_customer ON rental_history(customer_id);
CREATE INDEX idx_maintenance_vehicle ON maintenance_records(vehicle_id);
```

## 4. Triggers and Functions

### 4.1 Updated At Trigger Function

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';
```

### 4.2 Updated At Triggers

```sql
CREATE TRIGGER update_vehicle_categories_updated_at
    BEFORE UPDATE ON vehicle_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rental_locations_updated_at
    BEFORE UPDATE ON rental_locations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at
    BEFORE UPDATE ON vehicles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
    BEFORE UPDATE ON bookings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rental_history_updated_at
    BEFORE UPDATE ON rental_history
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maintenance_records_updated_at
    BEFORE UPDATE ON maintenance_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

## 5. Sample Data

### 5.1 Vehicle Categories

```sql
INSERT INTO vehicle_categories (name, description, daily_rate, weekly_rate, monthly_rate) VALUES
('Economy', 'Compact and fuel-efficient vehicles', 30.00, 180.00, 600.00),
('Standard', 'Mid-size sedans and SUVs', 45.00, 270.00, 900.00),
('Premium', 'Luxury vehicles with advanced features', 75.00, 450.00, 1500.00),
('SUV', 'Sport Utility Vehicles', 60.00, 360.00, 1200.00),
('Van', 'Passenger and cargo vans', 80.00, 480.00, 1600.00);
```

### 5.2 Rental Locations

```sql
INSERT INTO rental_locations (name, address, city, state, zip_code, phone, email) VALUES
('Downtown Branch', '123 Main Street', 'New York', 'NY', '10001', '212-555-1001', 'downtown@carrental.com'),
('Airport Branch', '456 Airport Road', 'New York', 'NY', '10002', '212-555-1002', 'airport@carrental.com'),
('Suburban Branch', '789 Oak Avenue', 'Brooklyn', 'NY', '11201', '718-555-1003', 'suburban@carrental.com');
```

### 5.3 Customers

```sql
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, zip_code, license_number, license_state, license_expiry, date_of_birth) VALUES
('John', 'Doe', 'john.doe@email.com', '212-555-1001', '123 Main St', 'New York', 'NY', '10001', 'DL12345678', 'NY', '2025-12-31', '1980-01-15'),
('Jane', 'Smith', 'jane.smith@email.com', '212-555-1002', '456 Oak Ave', 'Brooklyn', 'NY', '11201', 'DL23456789', 'NY', '2024-11-30', '1985-05-20'),
('Robert', 'Johnson', 'robert.johnson@email.com', '212-555-1003', '789 Pine St', 'Queens', 'NY', '11301', 'DL34567890', 'NY', '2023-10-15', '1990-08-10');
```

### 5.4 Vehicles

```sql
INSERT INTO vehicles (category_id, make, model, year, color, license_plate, vin, mileage, status, current_location_id) VALUES
(1, 'Toyota', 'Corolla', 2023, 'Silver', 'ABC123', '1HGCM82633A123456', 5000, 'available', 1),
(1, 'Honda', 'Civic', 2023, 'Blue', 'DEF456', '2HGCM82633A123457', 3000, 'available', 2),
(2, 'Toyota', 'Camry', 2023, 'Black', 'GHI789', '3HGCM82633A123458', 2000, 'available', 1);
```

### 5.5 Bookings

```sql
INSERT INTO bookings (customer_id, vehicle_id, pickup_location_id, dropoff_location_id, start_date, end_date, total_amount, status) VALUES
(1, 1, 1, 1, '2023-01-01 10:00:00+00', '2023-01-07 10:00:00+00', 210.00, 'completed'),
(2, 3, 2, 2, '2023-01-15 11:00:00+00', '2023-01-22 11:00:00+00', 315.00, 'completed'),
(3, 5, 1, 1, '2023-02-01 12:00:00+00', '2023-02-07 12:00:00+00', 525.00, 'completed');
```

### 5.6 Payments

```sql
INSERT INTO payments (booking_id, amount, payment_method, payment_date, status, transaction_id) VALUES
(1, 210.00, 'credit_card', '2023-01-01 10:00:00+00', 'completed', 'TXN123456'),
(2, 315.00, 'credit_card', '2023-01-15 11:00:00+00', 'completed', 'TXN234567'),
(3, 525.00, 'credit_card', '2023-02-01 12:00:00+00', 'completed', 'TXN345678');
```

### 5.7 Rental History

```sql
INSERT INTO rental_history (booking_id, vehicle_id, customer_id, actual_pickup_date, actual_dropoff_date, initial_mileage, final_mileage, fuel_level_pickup, fuel_level_dropoff, notes) VALUES
(1, 1, 1, '2023-01-01 10:00:00+00', '2023-01-07 10:00:00+00', 5000, 5500, 'full', 'full', 'No issues reported'),
(2, 3, 2, '2023-01-15 11:00:00+00', '2023-01-22 11:00:00+00', 2000, 2500, 'full', 'three_quarters', 'Minor scratch on rear bumper'),
(3, 5, 3, '2023-02-01 12:00:00+00', '2023-02-07 12:00:00+00', 1000, 1500, 'full', 'half', 'Vehicle returned with low fuel');
```

### 5.8 Maintenance Records

```sql
INSERT INTO maintenance_records (vehicle_id, maintenance_type, description, maintenance_date, completion_date, cost, mileage, status) VALUES
(1, 'routine', 'Regular oil change and inspection', '2023-01-10 09:00:00+00', '2023-01-10 10:00:00+00', 75.00, 5500, 'completed'),
(3, 'repair', 'Replace rear bumper', '2023-01-25 10:00:00+00', '2023-01-25 12:00:00+00', 250.00, 2500, 'completed'),
(5, 'routine', 'Regular service and inspection', '2023-02-10 11:00:00+00', '2023-02-10 12:00:00+00', 150.00, 1500, 'completed');
```

## 6. Complex Queries

### 6.1 Revenue Analysis

```sql
-- Monthly Revenue by Vehicle Category
SELECT
    vc.name AS category,
    TO_CHAR(p.payment_date, 'YYYY-MM') AS month,
    SUM(p.amount) AS total_revenue,
    COUNT(DISTINCT b.booking_id) AS number_of_bookings,
    ROUND(AVG(p.amount), 2) AS average_booking_value
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
JOIN vehicle_categories vc ON v.category_id = vc.category_id
WHERE p.status = 'completed'
GROUP BY vc.name, TO_CHAR(p.payment_date, 'YYYY-MM')
ORDER BY month DESC, total_revenue DESC;
```

### 6.2 Vehicle Utilization

```sql
-- Vehicle Utilization Rate
SELECT
    v.vehicle_id,
    v.make,
    v.model,
    v.license_plate,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/86400)::INTEGER AS total_rental_days,
    ROUND((COUNT(DISTINCT b.booking_id) * 100.0 /
          (SELECT COUNT(*) FROM bookings WHERE status = 'completed')), 2) AS utilization_percentage
FROM vehicles v
LEFT JOIN bookings b ON v.vehicle_id = b.vehicle_id AND b.status = 'completed'
GROUP BY v.vehicle_id, v.make, v.model, v.license_plate
ORDER BY utilization_percentage DESC;
```

### 6.3 Customer Analysis

```sql
-- Customer Loyalty Analysis
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(p.amount) AS total_spent,
    MIN(b.start_date) AS first_booking_date,
    MAX(b.start_date) AS last_booking_date,
    COUNT(DISTINCT v.category_id) AS different_categories_rented
FROM customers c
JOIN bookings b ON c.customer_id = b.customer_id
JOIN payments p ON b.booking_id = p.booking_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
WHERE p.status = 'completed'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
```

## 7. Transaction Examples

### 7.1 Booking Creation

```sql
DO $$
DECLARE
    v_booking_id INTEGER;
BEGIN
    -- Create booking
    INSERT INTO bookings (
        customer_id, vehicle_id, pickup_location_id, dropoff_location_id,
        start_date, end_date, total_amount, status
    ) VALUES (
        1, 1, 1, 1,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '7 days',
        210.00, 'pending'
    ) RETURNING booking_id INTO v_booking_id;

    -- Update vehicle status
    UPDATE vehicles
    SET status = 'reserved'
    WHERE vehicle_id = 1;

    -- Create payment
    INSERT INTO payments (
        booking_id, amount, payment_method, status
    ) VALUES (
        v_booking_id, 210.00, 'credit_card', 'pending'
    );

    COMMIT;
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE NOTICE 'Error creating booking: %', SQLERRM;
END $$;
```

### 7.2 Rental Completion

```sql
DO $$
DECLARE
    v_booking_id INTEGER := 1;
    v_vehicle_id INTEGER;
    v_final_mileage INTEGER := 5500;
    v_fuel_level fuel_level := 'full';
BEGIN
    -- Get vehicle ID
    SELECT vehicle_id INTO v_vehicle_id
    FROM bookings
    WHERE booking_id = v_booking_id;

    -- Update booking status
    UPDATE bookings
    SET status = 'completed'
    WHERE booking_id = v_booking_id;

    -- Update vehicle status
    UPDATE vehicles
    SET status = 'available',
        mileage = v_final_mileage
    WHERE vehicle_id = v_vehicle_id;

    -- Update rental history
    UPDATE rental_history
    SET actual_dropoff_date = CURRENT_TIMESTAMP,
        final_mileage = v_final_mileage,
        fuel_level_dropoff = v_fuel_level
    WHERE booking_id = v_booking_id;

    COMMIT;
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE NOTICE 'Error completing rental: %', SQLERRM;
END $$;
```

## 8. Maintenance Procedures

### 8.1 Regular Maintenance

```sql
-- Rebuild indexes
REINDEX TABLE vehicles;
REINDEX TABLE bookings;
REINDEX TABLE payments;

-- Update statistics
ANALYZE vehicles;
ANALYZE bookings;
ANALYZE payments;

-- Vacuum tables
VACUUM ANALYZE vehicles;
VACUUM ANALYZE bookings;
VACUUM ANALYZE payments;
```

### 8.2 Backup Procedures

```sql
-- Create backup
pg_dump -U postgres -d car_rental_system -F c -f backup.dump

-- Restore from backup
pg_restore -U postgres -d car_rental_system backup.dump
```
