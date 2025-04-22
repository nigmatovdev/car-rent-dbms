-- =============================================
-- 1. Booking Creation Transaction
-- =============================================

-- Function Definition
CREATE OR REPLACE FUNCTION create_booking(
    p_customer_id INTEGER,
    p_vehicle_id INTEGER,
    p_pickup_location_id INTEGER,
    p_dropoff_location_id INTEGER,
    p_start_date TIMESTAMP WITH TIME ZONE,
    p_end_date TIMESTAMP WITH TIME ZONE,
    p_total_amount DECIMAL(10,2)
) RETURNS INTEGER AS $$
DECLARE
    v_booking_id INTEGER;
    v_vehicle_status TEXT;
BEGIN
    -- Check vehicle availability
    SELECT status INTO v_vehicle_status
    FROM vehicles
    WHERE vehicle_id = p_vehicle_id;

    IF v_vehicle_status != 'available' THEN
        RAISE EXCEPTION 'Vehicle is not available for booking';
    END IF;

    -- Create booking
    INSERT INTO bookings (
        customer_id,
        vehicle_id,
        pickup_location_id,
        dropoff_location_id,
        start_date,
        end_date,
        total_amount,
        status
    ) VALUES (
        p_customer_id,
        p_vehicle_id,
        p_pickup_location_id,
        p_dropoff_location_id,
        p_start_date,
        p_end_date,
        p_total_amount,
        'pending'
    ) RETURNING booking_id INTO v_booking_id;

    -- Update vehicle status
    UPDATE vehicles
    SET status = 'reserved',
        current_location_id = p_pickup_location_id
    WHERE vehicle_id = p_vehicle_id;

    RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql;

-- Implementation Example
DO $$
DECLARE
    v_booking_id INTEGER;
BEGIN
    -- Execute the transaction
    v_booking_id := create_booking(
        1,                      -- customer_id (John Doe)
        1,                      -- vehicle_id (Toyota Corolla)
        1,                      -- pickup_location_id (Downtown Branch)
        1,                      -- dropoff_location_id (Downtown Branch)
        CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
        (CURRENT_TIMESTAMP + INTERVAL '7 days') AT TIME ZONE 'UTC',
        210.00                 -- 7 days * 30.00 daily rate
    );
    
    -- Verify the result
    RAISE NOTICE 'Created booking with ID: %', v_booking_id;
END $$;

-- =============================================
-- 2. Payment Processing Transaction
-- =============================================

-- Function Definition
CREATE OR REPLACE FUNCTION process_payment(
    p_booking_id INTEGER,
    p_amount DECIMAL(10,2),
    p_payment_method payment_method,
    p_transaction_id TEXT
) RETURNS INTEGER AS $$
DECLARE
    v_payment_id INTEGER;
    v_booking_status booking_status;
BEGIN
    -- Check booking status
    SELECT status INTO v_booking_status
    FROM bookings
    WHERE booking_id = p_booking_id;

    IF v_booking_status != 'confirmed' THEN
        RAISE EXCEPTION 'Invalid booking status for payment. Booking must be confirmed.';
    END IF;

    -- Create payment record
    INSERT INTO payments (
        booking_id,
        amount,
        payment_method,
        payment_date,
        status,
        transaction_id
    ) VALUES (
        p_booking_id,
        p_amount,
        p_payment_method,
        CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
        'completed',
        p_transaction_id
    ) RETURNING payment_id INTO v_payment_id;

    -- Update booking status
    UPDATE bookings
    SET status = 'in_progress'
    WHERE booking_id = p_booking_id;

    RETURN v_payment_id;
END;
$$ LANGUAGE plpgsql;

-- Implementation Example
DO $$
DECLARE
    v_payment_id INTEGER;
BEGIN
    -- Execute the transaction
    v_payment_id := process_payment(
        1,                      -- booking_id (from previous step)
        210.00,                -- amount
        'credit_card'::payment_method,
        'TXN123456'            -- transaction_id
    );
    
    -- Verify the result
    RAISE NOTICE 'Processed payment with ID: %', v_payment_id;
END $$;

-- =============================================
-- 3. Rental Completion Transaction
-- =============================================

-- Function Definition
CREATE OR REPLACE FUNCTION complete_rental(
    p_booking_id INTEGER,
    p_actual_dropoff_date TIMESTAMP WITH TIME ZONE,
    p_final_mileage INTEGER,
    p_fuel_level_dropoff fuel_level,
    p_notes TEXT
) RETURNS INTEGER AS $$
DECLARE
    v_history_id INTEGER;
    v_vehicle_id INTEGER;
    v_customer_id INTEGER;
    v_initial_mileage INTEGER;
    v_start_date TIMESTAMP WITH TIME ZONE;
    v_booking_status booking_status;
BEGIN
    -- Check booking status
    SELECT status INTO v_booking_status
    FROM bookings
    WHERE booking_id = p_booking_id;

    IF v_booking_status != 'in_progress' THEN
        RAISE EXCEPTION 'Invalid booking status for completion. Booking must be in progress.';
    END IF;

    -- Get booking details
    SELECT 
        b.vehicle_id,
        b.customer_id,
        v.mileage,
        b.start_date
    INTO 
        v_vehicle_id,
        v_customer_id,
        v_initial_mileage,
        v_start_date
    FROM bookings b
    JOIN vehicles v ON b.vehicle_id = v.vehicle_id
    WHERE b.booking_id = p_booking_id;

    -- Create rental history record
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
        p_booking_id,
        v_vehicle_id,
        v_customer_id,
        v_start_date,
        p_actual_dropoff_date,
        v_initial_mileage,
        p_final_mileage,
        'full'::fuel_level,
        p_fuel_level_dropoff,
        p_notes
    ) RETURNING history_id INTO v_history_id;

    -- Update booking status
    UPDATE bookings
    SET status = 'completed'
    WHERE booking_id = p_booking_id;

    -- Update vehicle status and mileage
    UPDATE vehicles
    SET status = 'available',
        mileage = p_final_mileage
    WHERE vehicle_id = v_vehicle_id;

    RETURN v_history_id;
END;
$$ LANGUAGE plpgsql;

-- Implementation Example
DO $$
DECLARE
    v_history_id INTEGER;
BEGIN
    -- First update booking status to in_progress
    UPDATE bookings
    SET status = 'in_progress'
    WHERE booking_id = 1;

    -- Then execute the transaction
    v_history_id := complete_rental(
        1,                      -- booking_id
        CURRENT_TIMESTAMP AT TIME ZONE 'UTC',  -- actual_dropoff_date
        5500,                   -- final_mileage
        'full'::fuel_level,     -- Cast to enum type
        'No issues reported'    -- notes
    );
    
    -- Verify the result
    RAISE NOTICE 'Completed rental with history ID: %', v_history_id;
END $$;

-- =============================================
-- 4. Maintenance Scheduling Transaction
-- =============================================

-- Function Definition
CREATE OR REPLACE FUNCTION schedule_maintenance(
    p_vehicle_id INTEGER,
    p_maintenance_type maintenance_type,
    p_description TEXT,
    p_cost DECIMAL(10,2),
    p_mileage INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_maintenance_id INTEGER;
    v_vehicle_status vehicle_status;
BEGIN
    -- Check vehicle status
    SELECT status INTO v_vehicle_status
    FROM vehicles
    WHERE vehicle_id = p_vehicle_id;

    IF v_vehicle_status != 'available' THEN
        RAISE EXCEPTION 'Vehicle is not available for maintenance';
    END IF;

    -- Create maintenance record
    INSERT INTO maintenance_records (
        vehicle_id,
        maintenance_type,
        description,
        maintenance_date,
        cost,
        mileage,
        status
    ) VALUES (
        p_vehicle_id,
        p_maintenance_type,
        p_description,
        CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
        p_cost,
        p_mileage,
        'scheduled'::maintenance_status
    ) RETURNING maintenance_id INTO v_maintenance_id;

    -- Update vehicle status
    UPDATE vehicles
    SET status = 'maintenance'
    WHERE vehicle_id = p_vehicle_id;

    RETURN v_maintenance_id;
END;
$$ LANGUAGE plpgsql;

-- Implementation Example
DO $$
DECLARE
    v_maintenance_id INTEGER;
BEGIN
    -- Execute the transaction
    v_maintenance_id := schedule_maintenance(
        1,                      -- vehicle_id
        'routine'::maintenance_type,
        'Regular oil change',   -- description
        75.00,                 -- cost
        5500                   -- mileage
    );
    
    -- Verify the result
    RAISE NOTICE 'Scheduled maintenance with ID: %', v_maintenance_id;
END $$;

-- =============================================
-- 5. Vehicle Transfer Transaction
-- =============================================

-- Function Definition
CREATE OR REPLACE FUNCTION transfer_vehicle(
    p_vehicle_id INTEGER,
    p_new_location_id INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
    v_vehicle_status TEXT;
BEGIN
    -- Check vehicle status
    SELECT status INTO v_vehicle_status
    FROM vehicles
    WHERE vehicle_id = p_vehicle_id;

    IF v_vehicle_status != 'available' THEN
        RAISE EXCEPTION 'Vehicle is not available for transfer';
    END IF;

    -- Update vehicle location
    UPDATE vehicles
    SET current_location_id = p_new_location_id
    WHERE vehicle_id = p_vehicle_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Implementation Example
DO $$
DECLARE
    v_success BOOLEAN;
BEGIN
    -- Execute the transaction
    v_success := transfer_vehicle(
        1,                      -- vehicle_id
        2                       -- new_location_id (Airport Branch)
    );
    
    -- Verify the result
    RAISE NOTICE 'Vehicle transfer successful: %', v_success;
END $$; 