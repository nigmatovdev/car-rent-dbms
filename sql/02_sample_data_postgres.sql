-- Insert vehicle categories
INSERT INTO vehicle_categories (name, description, daily_rate, weekly_rate, monthly_rate) VALUES
('Economy', 'Compact and fuel-efficient vehicles', 30.00, 180.00, 600.00),
('Standard', 'Mid-size sedans and SUVs', 45.00, 270.00, 900.00),
('Premium', 'Luxury vehicles with advanced features', 75.00, 450.00, 1500.00),
('SUV', 'Sport Utility Vehicles', 60.00, 360.00, 1200.00),
('Van', 'Passenger and cargo vans', 80.00, 480.00, 1600.00);

-- Insert rental locations
INSERT INTO rental_locations (name, address, city, state, zip_code, phone, email) VALUES
('Downtown Branch', '123 Main Street', 'New York', 'NY', '10001', '212-555-1001', 'downtown@carrental.com'),
('Airport Branch', '456 Airport Road', 'New York', 'NY', '10002', '212-555-1002', 'airport@carrental.com'),
('Suburban Branch', '789 Oak Avenue', 'Brooklyn', 'NY', '11201', '718-555-1003', 'suburban@carrental.com');

-- Insert customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, zip_code, license_number, license_state, license_expiry, date_of_birth) VALUES
('John', 'Doe', 'john.doe@email.com', '212-555-1001', '123 Main St', 'New York', 'NY', '10001', 'DL12345678', 'NY', '2025-12-31', '1980-01-15'),
('Jane', 'Smith', 'jane.smith@email.com', '212-555-1002', '456 Oak Ave', 'Brooklyn', 'NY', '11201', 'DL23456789', 'NY', '2024-11-30', '1985-05-20'),
('Robert', 'Johnson', 'robert.johnson@email.com', '212-555-1003', '789 Pine St', 'Queens', 'NY', '11301', 'DL34567890', 'NY', '2023-10-15', '1990-08-10'),
('Emily', 'Williams', 'emily.williams@email.com', '212-555-1004', '321 Elm St', 'Bronx', 'NY', '10451', 'DL45678901', 'NY', '2024-09-20', '1988-03-25'),
('Michael', 'Brown', 'michael.brown@email.com', '212-555-1005', '654 Maple Ave', 'Staten Island', 'NY', '10301', 'DL56789012', 'NY', '2025-08-05', '1982-11-30');

-- Insert vehicles
INSERT INTO vehicles (category_id, make, model, year, color, license_plate, vin, mileage, status, current_location_id) VALUES
(1, 'Toyota', 'Corolla', 2023, 'Silver', 'ABC123', '1HGCM82633A123456', 5000, 'available', 1),
(1, 'Honda', 'Civic', 2023, 'Blue', 'DEF456', '2HGCM82633A123457', 3000, 'available', 2),
(2, 'Toyota', 'Camry', 2023, 'Black', 'GHI789', '3HGCM82633A123458', 2000, 'available', 1),
(2, 'Honda', 'Accord', 2023, 'White', 'JKL012', '4HGCM82633A123459', 4000, 'available', 3),
(3, 'BMW', '3 Series', 2023, 'Gray', 'MNO345', '5HGCM82633A123460', 1000, 'available', 2),
(3, 'Mercedes', 'C-Class', 2023, 'Black', 'PQR678', '6HGCM82633A123461', 1500, 'available', 1),
(4, 'Toyota', 'RAV4', 2023, 'Red', 'STU901', '7HGCM82633A123462', 2500, 'available', 3),
(4, 'Honda', 'CR-V', 2023, 'Silver', 'VWX234', '8HGCM82633A123463', 3500, 'available', 2),
(5, 'Toyota', 'Sienna', 2023, 'White', 'YZA567', '9HGCM82633A123464', 2000, 'available', 1),
(5, 'Honda', 'Odyssey', 2023, 'Blue', 'BCD890', '0HGCM82633A123465', 3000, 'available', 3);

-- Insert bookings
INSERT INTO bookings (customer_id, vehicle_id, pickup_location_id, dropoff_location_id, start_date, end_date, total_amount, status) VALUES
(1, 1, 1, 1, '2023-01-01 10:00:00+00', '2023-01-07 10:00:00+00', 210.00, 'completed'),
(2, 3, 2, 2, '2023-01-15 11:00:00+00', '2023-01-22 11:00:00+00', 315.00, 'completed'),
(3, 5, 1, 1, '2023-02-01 12:00:00+00', '2023-02-07 12:00:00+00', 525.00, 'completed'),
(4, 7, 3, 3, '2023-02-15 13:00:00+00', '2023-02-22 13:00:00+00', 420.00, 'completed'),
(5, 9, 2, 2, '2023-03-01 14:00:00+00', '2023-03-07 14:00:00+00', 560.00, 'completed');

-- Insert payments
INSERT INTO payments (booking_id, amount, payment_method, payment_date, status, transaction_id) VALUES
(1, 210.00, 'credit_card', '2023-01-01 10:00:00+00', 'completed', 'TXN123456'),
(2, 315.00, 'credit_card', '2023-01-15 11:00:00+00', 'completed', 'TXN234567'),
(3, 525.00, 'credit_card', '2023-02-01 12:00:00+00', 'completed', 'TXN345678'),
(4, 420.00, 'credit_card', '2023-02-15 13:00:00+00', 'completed', 'TXN456789'),
(5, 560.00, 'credit_card', '2023-03-01 14:00:00+00', 'completed', 'TXN567890');

-- Insert rental history
INSERT INTO rental_history (booking_id, vehicle_id, customer_id, actual_pickup_date, actual_dropoff_date, initial_mileage, final_mileage, fuel_level_pickup, fuel_level_dropoff, notes) VALUES
(1, 1, 1, '2023-01-01 10:00:00+00', '2023-01-07 10:00:00+00', 5000, 5500, 'full', 'full', 'No issues reported'),
(2, 3, 2, '2023-01-15 11:00:00+00', '2023-01-22 11:00:00+00', 2000, 2500, 'full', 'three_quarters', 'Minor scratch on rear bumper'),
(3, 5, 3, '2023-02-01 12:00:00+00', '2023-02-07 12:00:00+00', 1000, 1500, 'full', 'half', 'Vehicle returned with low fuel'),
(4, 7, 4, '2023-02-15 13:00:00+00', '2023-02-22 13:00:00+00', 2500, 3000, 'full', 'full', 'No issues reported'),
(5, 9, 5, '2023-03-01 14:00:00+00', '2023-03-07 14:00:00+00', 2000, 2500, 'full', 'quarter', 'Vehicle returned with low fuel');

-- Insert maintenance records
INSERT INTO maintenance_records (vehicle_id, maintenance_type, description, maintenance_date, completion_date, cost, mileage, status) VALUES
(1, 'routine', 'Regular oil change and inspection', '2023-01-10 09:00:00+00', '2023-01-10 10:00:00+00', 75.00, 5500, 'completed'),
(3, 'repair', 'Replace rear bumper', '2023-01-25 10:00:00+00', '2023-01-25 12:00:00+00', 250.00, 2500, 'completed'),
(5, 'routine', 'Regular service and inspection', '2023-02-10 11:00:00+00', '2023-02-10 12:00:00+00', 150.00, 1500, 'completed'),
(7, 'routine', 'Tire rotation and alignment', '2023-02-25 13:00:00+00', '2023-02-25 14:00:00+00', 100.00, 3000, 'completed'),
(9, 'routine', 'Regular service and inspection', '2023-03-10 14:00:00+00', '2023-03-10 15:00:00+00', 150.00, 2500, 'completed'); 