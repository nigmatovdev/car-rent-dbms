-- Transaction Examples for Car Rental System

-- Transaction 1: Complete a rental booking with payment
BEGIN;

-- 1. Create a new booking
INSERT INTO bookings (
    customer_id,
    vehicle_id,
    pickup_location_id,
    dropoff_location_id,
    start_date,
    end_date,
    status,
    total_amount
) VALUES (
    1,  -- customer_id
    2,  -- vehicle_id
    1,  -- pickup_location_id
    2,  -- dropoff_location_id
    '2023-06-01 10:00:00',
    '2023-06-05 10:00:00',
    'confirmed',
    180.00
) RETURNING booking_id;

-- 2. Update vehicle status
UPDATE vehicles
SET status = 'rented'
WHERE vehicle_id = 2;

-- 3. Record the payment
INSERT INTO payments (
    booking_id,
    amount,
    payment_method,
    status,
    transaction_id
) VALUES (
    currval('bookings_booking_id_seq'),
    180.00,
    'credit_card',
    'completed',
    'TXN987654321'
);

COMMIT;

-- Transaction 2: Handle vehicle return and maintenance
BEGIN;

-- 1. Update booking status
UPDATE bookings
SET status = 'completed'
WHERE booking_id = 2;

-- 2. Update vehicle status and mileage
UPDATE vehicles
SET 
    status = 'maintenance',
    mileage = mileage + 500
WHERE vehicle_id = 1;

-- 3. Record maintenance
INSERT INTO maintenance_records (
    vehicle_id,
    maintenance_type,
    description,
    cost,
    maintenance_date,
    next_maintenance_date,
    status
) VALUES (
    1,
    'Regular Service',
    'Post-rental inspection and cleaning',
    75.00,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '6 months',
    'scheduled'
);

-- 4. Update rental history
INSERT INTO rental_history (
    booking_id,
    vehicle_id,
    customer_id,
    actual_pickup_date,
    actual_dropoff_date,
    initial_mileage,
    final_mileage,
    fuel_level_pickup,
    fuel_level_dropoff,
    notes
) VALUES (
    2,
    1,
    2,
    '2023-05-10 14:30:00',
    CURRENT_TIMESTAMP,
    14000,
    14500,
    100.00,
    85.00,
    'Vehicle returned in good condition'
);

COMMIT;

-- Transaction 3: Handle booking cancellation with refund
BEGIN;

-- 1. Update booking status
UPDATE bookings
SET status = 'cancelled'
WHERE booking_id = 3;

-- 2. Update vehicle status
UPDATE vehicles
SET status = 'available'
WHERE vehicle_id = 4;

-- 3. Process refund
INSERT INTO payments (
    booking_id,
    amount,
    payment_method,
    status,
    transaction_id
) VALUES (
    3,
    -475.00,  -- Negative amount for refund
    'credit_card',
    'refunded',
    'TXN345678901-REF'
);

-- 4. Update original payment status
UPDATE payments
SET status = 'refunded'
WHERE booking_id = 3 AND status = 'pending';

COMMIT;

-- Transaction 4: Handle vehicle transfer between locations
BEGIN;

-- 1. Update vehicle status
UPDATE vehicles
SET status = 'maintenance'
WHERE vehicle_id = 6;

-- 2. Create maintenance record for transfer
INSERT INTO maintenance_records (
    vehicle_id,
    maintenance_type,
    description,
    cost,
    maintenance_date,
    next_maintenance_date,
    status
) VALUES (
    6,
    'Location Transfer',
    'Vehicle transfer from Beach Branch to Downtown Branch',
    0.00,
    CURRENT_DATE,
    CURRENT_DATE,
    'completed'
);

-- 3. Update vehicle status after transfer
UPDATE vehicles
SET 
    status = 'available',
    last_maintenance_date = CURRENT_DATE
WHERE vehicle_id = 6;

COMMIT;

-- Transaction 5: Handle customer loyalty program update
BEGIN;

-- 1. Create a new booking with loyalty discount
INSERT INTO bookings (
    customer_id,
    vehicle_id,
    pickup_location_id,
    dropoff_location_id,
    start_date,
    end_date,
    status,
    total_amount
) VALUES (
    5,  -- customer_id
    3,  -- vehicle_id
    3,  -- pickup_location_id
    3,  -- dropoff_location_id
    '2023-06-10 09:00:00',
    '2023-06-15 09:00:00',
    'confirmed',
    260.00 * 0.9  -- 10% loyalty discount
) RETURNING booking_id;

-- 2. Update vehicle status
UPDATE vehicles
SET status = 'reserved'
WHERE vehicle_id = 3;

-- 3. Record the payment with loyalty discount
INSERT INTO payments (
    booking_id,
    amount,
    payment_method,
    status,
    transaction_id
) VALUES (
    currval('bookings_booking_id_seq'),
    234.00,  -- Amount after 10% discount
    'credit_card',
    'completed',
    'TXN567890123-LOYALTY'
);

COMMIT; 