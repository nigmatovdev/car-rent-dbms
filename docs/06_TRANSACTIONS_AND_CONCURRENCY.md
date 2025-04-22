# Car Rental System - Transactions and Concurrency

## 1. Transaction Management

### 1.1 Basic Transaction Structure

```sql
-- Simple transaction block
BEGIN;
    -- SQL statements
    INSERT INTO bookings (...) VALUES (...);
    UPDATE vehicles SET status = 'reserved' WHERE vehicle_id = 1;
    INSERT INTO payments (...) VALUES (...);
COMMIT;

-- Transaction with error handling
BEGIN;
    -- SQL statements
    INSERT INTO bookings (...) VALUES (...);
    UPDATE vehicles SET status = 'reserved' WHERE vehicle_id = 1;
    INSERT INTO payments (...) VALUES (...);
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE NOTICE 'Error in transaction: %', SQLERRM;
END;
```

### 1.2 Transaction Isolation Levels

```sql
-- Set transaction isolation level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- or
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- or
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Example with explicit isolation level
BEGIN;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- Critical operations
    SELECT * FROM vehicles WHERE status = 'available' FOR UPDATE;
    -- Update operations
COMMIT;
```

## 2. Concurrency Control

### 2.1 Row-Level Locking

```sql
-- Select for update (exclusive lock)
SELECT * FROM vehicles
WHERE vehicle_id = 1
FOR UPDATE;

-- Select for share (shared lock)
SELECT * FROM vehicles
WHERE category_id = 1
FOR SHARE;

-- Skip locked rows
SELECT * FROM vehicles
WHERE status = 'available'
FOR UPDATE SKIP LOCKED;
```

### 2.2 Table-Level Locking

```sql
-- Lock table in exclusive mode
LOCK TABLE vehicles IN EXCLUSIVE MODE;

-- Lock table in share mode
LOCK TABLE vehicle_categories IN SHARE MODE;

-- Lock multiple tables
LOCK TABLE vehicles, bookings IN EXCLUSIVE MODE;
```

## 3. Common Transaction Patterns

### 3.1 Booking Creation

```sql
DO $$
DECLARE
    v_booking_id INTEGER;
BEGIN
    -- Start transaction
    BEGIN;
        -- Check vehicle availability
        SELECT vehicle_id INTO v_vehicle_id
        FROM vehicles
        WHERE vehicle_id = 1
        AND status = 'available'
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Vehicle not available';
        END IF;

        -- Create booking
        INSERT INTO bookings (
            customer_id, vehicle_id, pickup_location_id,
            dropoff_location_id, start_date, end_date,
            total_amount, status
        ) VALUES (
            1, 1, 1, 1,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '7 days',
            210.00, 'pending'
        ) RETURNING booking_id INTO v_booking_id;

        -- Update vehicle status
        UPDATE vehicles
        SET status = 'reserved'
        WHERE vehicle_id = 1;

        -- Create payment record
        INSERT INTO payments (
            booking_id, amount, payment_method, status
        ) VALUES (
            v_booking_id, 210.00, 'credit_card', 'pending'
        );

        COMMIT;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE NOTICE 'Error creating booking: %', SQLERRM;
    END;
END $$;
```

### 3.2 Rental Completion

```sql
DO $$
DECLARE
    v_booking_id INTEGER := 1;
    v_vehicle_id INTEGER;
    v_final_mileage INTEGER := 5500;
    v_fuel_level fuel_level := 'full';
BEGIN
    -- Start transaction
    BEGIN;
        -- Get and lock booking
        SELECT vehicle_id INTO v_vehicle_id
        FROM bookings
        WHERE booking_id = v_booking_id
        AND status = 'in_progress'
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Invalid booking status';
        END IF;

        -- Update booking status
        UPDATE bookings
        SET status = 'completed'
        WHERE booking_id = v_booking_id;

        -- Update vehicle status and mileage
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
    END;
END $$;
```

### 3.3 Vehicle Transfer

```sql
DO $$
DECLARE
    v_vehicle_id INTEGER := 1;
    v_from_location INTEGER := 1;
    v_to_location INTEGER := 2;
BEGIN
    -- Start transaction
    BEGIN;
        -- Lock vehicle and check status
        SELECT status INTO v_status
        FROM vehicles
        WHERE vehicle_id = v_vehicle_id
        AND current_location_id = v_from_location
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Vehicle not found at source location';
        END IF;

        IF v_status != 'available' THEN
            RAISE EXCEPTION 'Vehicle not available for transfer';
        END IF;

        -- Update vehicle location
        UPDATE vehicles
        SET current_location_id = v_to_location
        WHERE vehicle_id = v_vehicle_id;

        -- Record transfer in history
        INSERT INTO vehicle_transfers (
            vehicle_id, from_location_id, to_location_id,
            transfer_date, status
        ) VALUES (
            v_vehicle_id, v_from_location, v_to_location,
            CURRENT_TIMESTAMP, 'completed'
        );

        COMMIT;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE NOTICE 'Error transferring vehicle: %', SQLERRM;
    END;
END $$;
```

## 4. Deadlock Prevention

### 4.1 Consistent Lock Ordering

```sql
-- Always lock in the same order: vehicles -> bookings -> payments
DO $$
BEGIN
    -- Lock vehicle first
    SELECT * FROM vehicles WHERE vehicle_id = 1 FOR UPDATE;

    -- Then lock booking
    SELECT * FROM bookings WHERE vehicle_id = 1 FOR UPDATE;

    -- Finally lock payment
    SELECT * FROM payments WHERE booking_id = 1 FOR UPDATE;
END $$;
```

### 4.2 Deadlock Detection

```sql
-- Set deadlock timeout
SET deadlock_timeout = '1s';

-- Check for deadlocks
SELECT pid, usename, query, wait_event_type, wait_event
FROM pg_stat_activity
WHERE wait_event_type = 'Lock';
```

## 5. Transaction Monitoring

### 5.1 Active Transactions

```sql
-- View active transactions
SELECT
    pid,
    usename,
    query,
    state,
    age(clock_timestamp(), xact_start) as duration
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;

-- View locks
SELECT
    locktype,
    relation::regclass,
    mode,
    transactionid,
    virtualtransaction,
    pid,
    usename
FROM pg_locks
WHERE pid != pg_backend_pid();
```

### 5.2 Transaction Statistics

```sql
-- Transaction statistics
SELECT
    datname,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted
FROM pg_stat_database
WHERE datname = 'car_rental_system';
```

## 6. Best Practices

### 6.1 Transaction Guidelines

1. **Keep transactions short**

   - Minimize the time locks are held
   - Reduce the chance of conflicts

2. **Use appropriate isolation levels**

   - READ COMMITTED for most operations
   - SERIALIZABLE for critical operations

3. **Handle errors properly**
   - Always include error handling
   - Rollback on errors
   - Provide meaningful error messages

### 6.2 Locking Guidelines

1. **Use row-level locks when possible**

   - More granular control
   - Better concurrency

2. **Acquire locks in consistent order**

   - Prevents deadlocks
   - Makes behavior predictable

3. **Release locks promptly**
   - Commit or rollback quickly
   - Don't hold locks during user interaction

### 6.3 Performance Considerations

1. **Monitor lock contention**

   - Watch for blocked transactions
   - Identify hot spots

2. **Use appropriate index types**

   - B-tree for most cases
   - Consider partial indexes

3. **Optimize transaction boundaries**
   - Group related operations
   - Split large transactions when possible
