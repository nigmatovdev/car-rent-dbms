# Car Rental System - Query Processing and Optimization

## 1. Query Processing Overview

### 1.1 Query Lifecycle

1. **Parsing**

   - SQL text is parsed into a parse tree
   - Syntax and semantic validation
   - Example: `SELECT * FROM vehicles WHERE status = 'available'`

2. **Rewriting**

   - Query tree is transformed
   - View expansion
   - Rule application
   - Example: View `available_vehicles` is expanded into base table query

3. **Planning**

   - Generate execution plan
   - Cost-based optimization
   - Join ordering
   - Example: Choose between nested loop, hash join, or merge join

4. **Execution**
   - Plan execution
   - Result generation
   - Example: Execute the chosen plan and return results

### 1.2 Query Types

1. **Simple Queries**

   ```sql
   -- Single table lookup
   SELECT * FROM vehicles WHERE vehicle_id = 1;

   -- Status check
   SELECT status FROM vehicles WHERE license_plate = 'ABC123';
   ```

2. **Join Queries**

   ```sql
   -- Vehicle with category
   SELECT v.*, vc.name as category_name
   FROM vehicles v
   JOIN vehicle_categories vc ON v.category_id = vc.category_id;
   ```

3. **Aggregation Queries**
   ```sql
   -- Revenue by category
   SELECT vc.name, SUM(p.amount) as total_revenue
   FROM payments p
   JOIN bookings b ON p.booking_id = b.booking_id
   JOIN vehicles v ON b.vehicle_id = v.vehicle_id
   JOIN vehicle_categories vc ON v.category_id = vc.category_id
   GROUP BY vc.name;
   ```

## 2. Index Optimization

### 2.1 Existing Indexes

```sql
-- Primary key indexes (automatically created)
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

### 2.2 Additional Recommended Indexes

```sql
-- Composite index for date range queries
CREATE INDEX idx_bookings_date_range ON bookings(start_date, end_date);

-- Partial index for active vehicles
CREATE INDEX idx_vehicles_active ON vehicles(vehicle_id)
WHERE status IN ('available', 'reserved');

-- Partial index for completed payments
CREATE INDEX idx_payments_completed ON payments(booking_id, amount)
WHERE status = 'completed';

-- Expression index for case-insensitive search
CREATE INDEX idx_customers_email_lower ON customers(lower(email));
```

### 2.3 Index Usage Analysis

```sql
-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public';

-- Check unused indexes
SELECT schemaname, tablename, indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

## 3. Query Optimization Techniques

### 3.1 Join Optimization

```sql
-- Use explicit join order
SELECT v.*, vc.name as category_name
FROM vehicles v
INNER JOIN vehicle_categories vc ON v.category_id = vc.category_id
WHERE v.status = 'available';

-- Use appropriate join type
SELECT b.*, c.first_name, c.last_name
FROM bookings b
LEFT JOIN customers c ON b.customer_id = c.customer_id
WHERE b.status = 'completed';
```

### 3.2 Subquery Optimization

```sql
-- Use EXISTS instead of IN for large datasets
SELECT v.*
FROM vehicles v
WHERE EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.vehicle_id = v.vehicle_id
    AND b.status = 'completed'
);

-- Use CTEs for complex queries
WITH vehicle_revenue AS (
    SELECT v.vehicle_id, SUM(p.amount) as total_revenue
    FROM vehicles v
    JOIN bookings b ON v.vehicle_id = b.vehicle_id
    JOIN payments p ON b.booking_id = p.booking_id
    WHERE p.status = 'completed'
    GROUP BY v.vehicle_id
)
SELECT v.*, vr.total_revenue
FROM vehicles v
LEFT JOIN vehicle_revenue vr ON v.vehicle_id = vr.vehicle_id;
```

### 3.3 Aggregation Optimization

```sql
-- Use materialized views for frequent aggregations
CREATE MATERIALIZED VIEW monthly_revenue AS
SELECT
    TO_CHAR(p.payment_date, 'YYYY-MM') AS month,
    vc.name AS category,
    SUM(p.amount) AS total_revenue
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
JOIN vehicle_categories vc ON v.category_id = vc.category_id
WHERE p.status = 'completed'
GROUP BY TO_CHAR(p.payment_date, 'YYYY-MM'), vc.name;

-- Refresh materialized view
REFRESH MATERIALIZED VIEW monthly_revenue;
```

## 4. Performance Monitoring

### 4.1 Query Analysis

```sql
-- Enable query logging
ALTER SYSTEM SET log_min_duration_statement = '1000';
ALTER SYSTEM SET log_statement = 'all';

-- Analyze query performance
EXPLAIN ANALYZE
SELECT v.*, vc.name as category_name
FROM vehicles v
JOIN vehicle_categories vc ON v.category_id = vc.category_id
WHERE v.status = 'available';
```

### 4.2 Statistics Collection

```sql
-- Update statistics
ANALYZE vehicles;
ANALYZE bookings;
ANALYZE payments;

-- Check table statistics
SELECT schemaname, tablename, n_live_tup, n_dead_tup, last_vacuum, last_analyze
FROM pg_stat_user_tables
WHERE schemaname = 'public';
```

### 4.3 Performance Metrics

```sql
-- Check table access patterns
SELECT schemaname, tablename, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch
FROM pg_stat_user_tables
WHERE schemaname = 'public';

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public';
```

## 5. Query Tuning Examples

### 5.1 Vehicle Availability Query

```sql
-- Original query
SELECT v.*, vc.name as category_name
FROM vehicles v
JOIN vehicle_categories vc ON v.category_id = vc.category_id
WHERE v.status = 'available'
AND v.current_location_id = 1;

-- Optimized query with index hint
SELECT v.*, vc.name as category_name
FROM vehicles v
JOIN vehicle_categories vc ON v.category_id = vc.category_id
WHERE v.status = 'available'
AND v.current_location_id = 1
ORDER BY v.vehicle_id;
```

### 5.2 Booking History Query

```sql
-- Original query
SELECT b.*, c.first_name, c.last_name, v.make, v.model
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
WHERE b.status = 'completed'
AND b.start_date >= CURRENT_DATE - INTERVAL '30 days';

-- Optimized query with date range index
SELECT b.*, c.first_name, c.last_name, v.make, v.model
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
WHERE b.status = 'completed'
AND b.start_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY b.start_date DESC;
```

### 5.3 Revenue Analysis Query

```sql
-- Original query
SELECT
    vc.name AS category,
    TO_CHAR(p.payment_date, 'YYYY-MM') AS month,
    SUM(p.amount) AS total_revenue
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
JOIN vehicle_categories vc ON v.category_id = vc.category_id
WHERE p.status = 'completed'
GROUP BY vc.name, TO_CHAR(p.payment_date, 'YYYY-MM');

-- Optimized query with materialized view
SELECT * FROM monthly_revenue
ORDER BY month DESC, total_revenue DESC;
```

## 6. Maintenance and Monitoring

### 6.1 Regular Maintenance

```sql
-- Vacuum analyze tables
VACUUM ANALYZE vehicles;
VACUUM ANALYZE bookings;
VACUUM ANALYZE payments;

-- Rebuild indexes
REINDEX TABLE vehicles;
REINDEX TABLE bookings;
REINDEX TABLE payments;
```

### 6.2 Performance Monitoring

```sql
-- Check table bloat
SELECT schemaname, tablename, n_live_tup, n_dead_tup,
       (n_dead_tup * 100.0 / (n_live_tup + n_dead_tup)) as dead_tup_percent
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY dead_tup_percent DESC;

-- Check index bloat
SELECT schemaname, tablename, indexname,
       pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexrelid) DESC;
```

### 6.3 Query Performance Monitoring

```sql
-- Enable slow query logging
ALTER SYSTEM SET log_min_duration_statement = '1000';
ALTER SYSTEM SET log_statement = 'all';

-- Check long-running queries
SELECT pid, age(clock_timestamp(), query_start), usename, query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY age(clock_timestamp(), query_start) DESC;
```
