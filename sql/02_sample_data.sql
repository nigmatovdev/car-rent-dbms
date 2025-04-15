-- Sample data for Car Rental System

-- Insert vehicle categories
INSERT INTO vehicle_categories (name, description, daily_rate, weekly_rate, monthly_rate) VALUES
('Economy', 'Compact and fuel-efficient vehicles', 45.00, 280.00, 1000.00),
('Standard', 'Mid-size sedans and SUVs', 65.00, 400.00, 1500.00),
('Premium', 'Luxury vehicles and large SUVs', 95.00, 600.00, 2200.00),
('Luxury', 'High-end luxury vehicles', 150.00, 900.00, 3200.00),
('Commercial', 'Vans and trucks', 80.00, 500.00, 1800.00);

-- Insert rental locations
INSERT INTO rental_locations (name, address, phone, email, operating_hours) VALUES
('Downtown Branch', '123 Main St, City Center', '+1-555-0101', 'downtown@carrental.com', 'Mon-Sun: 8:00-20:00'),
('Airport Branch', '456 Airport Rd, Terminal 2', '+1-555-0102', 'airport@carrental.com', '24/7'),
('Suburban Branch', '789 Oak Ave, Suburbia', '+1-555-0103', 'suburban@carrental.com', 'Mon-Sat: 9:00-18:00'),
('Beach Branch', '321 Coastal Hwy, Beachfront', '+1-555-0104', 'beach@carrental.com', 'Mon-Sun: 7:00-21:00'),
('University Branch', '654 Campus Dr, University District', '+1-555-0105', 'university@carrental.com', 'Mon-Fri: 8:00-19:00');

-- Insert customers
INSERT INTO customers (first_name, last_name, email, phone, address, driver_license_number, date_of_birth) VALUES
('John', 'Smith', 'john.smith@email.com', '+1-555-0201', '100 Park Ave, Apt 4B', 'DL12345678', '1985-06-15'),
('Sarah', 'Johnson', 'sarah.j@email.com', '+1-555-0202', '200 Oak St, Unit 12', 'DL23456789', '1990-03-22'),
('Michael', 'Brown', 'm.brown@email.com', '+1-555-0203', '300 Pine Rd, House 5', 'DL34567890', '1978-11-30'),
('Emily', 'Davis', 'emily.d@email.com', '+1-555-0204', '400 Maple Dr, Suite 8', 'DL45678901', '1995-08-10'),
('David', 'Wilson', 'd.wilson@email.com', '+1-555-0205', '500 Cedar Ln, Apt 3A', 'DL56789012', '1982-04-25');

-- Insert vehicles
INSERT INTO vehicles (make, model, year, color, license_plate, vin, category_id, status, mileage, last_maintenance_date) VALUES
('Toyota', 'Corolla', 2022, 'Silver', 'ABC123', '1HGCM82633A123456', 1, 'available', 15000, '2023-01-15'),
('Honda', 'Civic', 2023, 'Blue', 'DEF456', '2HGCM82633B234567', 1, 'available', 5000, '2023-03-20'),
('Ford', 'Explorer', 2022, 'Black', 'GHI789', '3FCM82633C345678', 2, 'rented', 25000, '2023-02-10'),
('BMW', '5 Series', 2023, 'White', 'JKL012', '4BMW82633D456789', 3, 'available', 8000, '2023-04-05'),
('Mercedes', 'S-Class', 2023, 'Black', 'MNO345', '5MBC82633E567890', 4, 'maintenance', 12000, '2023-01-30'),
('Chevrolet', 'Express', 2022, 'Red', 'PQR678', '6CHE82633F678901', 5, 'available', 30000, '2023-03-15');

-- Insert bookings
INSERT INTO bookings (customer_id, vehicle_id, pickup_location_id, dropoff_location_id, start_date, end_date, status, total_amount) VALUES
(1, 3, 1, 2, '2023-05-01 10:00:00', '2023-05-05 10:00:00', 'completed', 260.00),
(2, 1, 2, 2, '2023-05-10 14:00:00', '2023-05-12 14:00:00', 'confirmed', 90.00),
(3, 4, 3, 1, '2023-05-15 09:00:00', '2023-05-20 09:00:00', 'pending', 475.00),
(4, 2, 1, 3, '2023-05-20 16:00:00', '2023-05-25 16:00:00', 'confirmed', 225.00),
(5, 6, 4, 4, '2023-05-25 11:00:00', '2023-05-30 11:00:00', 'pending', 400.00);

-- Insert payments
INSERT INTO payments (booking_id, amount, payment_method, status, transaction_id) VALUES
(1, 260.00, 'credit_card', 'completed', 'TXN123456789'),
(2, 90.00, 'credit_card', 'completed', 'TXN234567890'),
(3, 475.00, 'credit_card', 'pending', 'TXN345678901'),
(4, 225.00, 'credit_card', 'completed', 'TXN456789012'),
(5, 400.00, 'credit_card', 'pending', 'TXN567890123');

-- Insert rental history
INSERT INTO rental_history (booking_id, vehicle_id, customer_id, actual_pickup_date, actual_dropoff_date, initial_mileage, final_mileage, fuel_level_pickup, fuel_level_dropoff, notes) VALUES
(1, 3, 1, '2023-05-01 10:15:00', '2023-05-05 09:45:00', 24000, 24500, 100.00, 75.00, 'Vehicle returned in good condition'),
(2, 1, 2, '2023-05-10 14:30:00', '2023-05-12 13:45:00', 14000, 14200, 100.00, 80.00, 'Minor scratch on rear bumper'),
(3, 4, 3, '2023-05-15 09:15:00', '2023-05-20 08:30:00', 7000, 7500, 100.00, 65.00, 'Vehicle needs cleaning'),
(4, 2, 4, '2023-05-20 16:20:00', '2023-05-25 15:45:00', 4000, 4500, 100.00, 70.00, 'All good'),
(5, 6, 5, '2023-05-25 11:10:00', '2023-05-30 10:30:00', 29000, 29500, 100.00, 60.00, 'Vehicle needs maintenance');

-- Insert maintenance records
INSERT INTO maintenance_records (vehicle_id, maintenance_type, description, cost, maintenance_date, next_maintenance_date, status) VALUES
(5, 'Regular Service', 'Oil change, filter replacement, and inspection', 150.00, '2023-01-30', '2023-07-30', 'completed'),
(1, 'Tire Rotation', 'Tire rotation and alignment check', 75.00, '2023-01-15', '2023-07-15', 'completed'),
(3, 'Brake Service', 'Brake pad replacement and system check', 300.00, '2023-02-10', '2023-08-10', 'completed'),
(6, 'Transmission Service', 'Transmission fluid change and inspection', 200.00, '2023-03-15', '2023-09-15', 'completed'),
(4, 'Battery Replacement', 'New battery installation', 250.00, '2023-04-05', '2025-04-05', 'completed'); 