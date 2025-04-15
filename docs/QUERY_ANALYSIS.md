# Query Execution Plan Analysis

## Query 1: Revenue by Vehicle Category

```sql
EXPLAIN ANALYZE
SELECT
    vc.name as category,
    COUNT(b.booking_id) as total_bookings,
    SUM(b.total_amount) as total_revenue,
    AVG(b.total_amount) as average_booking_amount
FROM
    bookings b
JOIN
    vehicles v ON b.vehicle_id = v.vehicle_id
JOIN
    vehicle_categories vc ON v.category_id = vc.category_id
WHERE
    b.start_date >= CURRENT_DATE - INTERVAL '1 month'
    AND b.status = 'completed'
GROUP BY
    vc.name
ORDER BY
    total_revenue DESC;
```

### Execution Plan Analysis:

1. Sequential scan on bookings table (costly)
2. Nested loop joins with vehicles and vehicle_categories
3. Hash aggregation for grouping
4. Sort operation for ordering

### Optimization Suggestions:

1. Create an index on bookings(start_date, status):

```sql
CREATE INDEX idx_bookings_date_status ON bookings(start_date, status);
```

2. Create a composite index on vehicles(category_id, vehicle_id):

```sql
CREATE INDEX idx_vehicles_category_vehicle ON vehicles(category_id, vehicle_id);
```

## Query 2: Vehicle Utilization Rate

```sql
EXPLAIN ANALYZE
SELECT
    v.vehicle_id,
    v.make,
    v.model,
    COUNT(b.booking_id) as total_bookings,
    SUM(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/3600/24) as total_rental_days,
    (SUM(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/3600/24) /
     EXTRACT(EPOCH FROM (CURRENT_DATE - MIN(b.start_date))/3600/24)) * 100 as utilization_rate
FROM
    vehicles v
LEFT JOIN
    bookings b ON v.vehicle_id = b.vehicle_id
WHERE
    b.status = 'completed'
GROUP BY
    v.vehicle_id, v.make, v.model
ORDER BY
    utilization_rate DESC;
```

### Execution Plan Analysis:

1. Sequential scan on vehicles
2. Hash left join with bookings
3. Complex calculations for date differences
4. Grouping and sorting operations

### Optimization Suggestions:

1. Create a materialized view for frequently accessed utilization data:

```sql
CREATE MATERIALIZED VIEW vehicle_utilization AS
SELECT
    v.vehicle_id,
    v.make,
    v.model,
    COUNT(b.booking_id) as total_bookings,
    SUM(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/3600/24) as total_rental_days
FROM
    vehicles v
LEFT JOIN
    bookings b ON v.vehicle_id = b.vehicle_id
WHERE
    b.status = 'completed'
GROUP BY
    v.vehicle_id, v.make, v.model;

CREATE INDEX idx_utilization_vehicle ON vehicle_utilization(vehicle_id);
```

2. Create an index on bookings(vehicle_id, status):

```sql
CREATE INDEX idx_bookings_vehicle_status ON bookings(vehicle_id, status);
```

## Query 3: Maintenance Cost Analysis

```sql
EXPLAIN ANALYZE
SELECT
    v.vehicle_id,
    v.make,
    v.model,
    COUNT(mr.maintenance_id) as total_maintenance_records,
    SUM(mr.cost) as total_maintenance_cost,
    AVG(mr.cost) as average_maintenance_cost
FROM
    vehicles v
JOIN
    maintenance_records mr ON v.vehicle_id = mr.vehicle_id
WHERE
    mr.status = 'completed'
GROUP BY
    v.vehicle_id, v.make, v.model
ORDER BY
    total_maintenance_cost DESC;
```

### Execution Plan Analysis:

1. Sequential scan on maintenance_records
2. Nested loop join with vehicles
3. Hash aggregation for grouping
4. Sort operation for ordering

### Optimization Suggestions:

1. Create a composite index on maintenance_records(vehicle_id, status):

```sql
CREATE INDEX idx_maintenance_vehicle_status ON maintenance_records(vehicle_id, status);
```

2. Create a partial index for completed maintenance records:

```sql
CREATE INDEX idx_maintenance_completed ON maintenance_records(vehicle_id)
WHERE status = 'completed';
```

## General Optimization Recommendations

1. **Index Strategy**:

   - Create indexes on frequently joined columns
   - Use composite indexes for common query patterns
   - Consider partial indexes for filtered queries
   - Regularly analyze and update statistics

2. **Query Optimization**:

   - Use appropriate join types (INNER, LEFT, etc.)
   - Minimize subqueries where possible
   - Use materialized views for complex calculations
   - Consider partitioning large tables

3. **Maintenance**:

   - Regularly vacuum and analyze tables
   - Monitor index usage
   - Update statistics after significant data changes
   - Consider table partitioning for large datasets

4. **Performance Monitoring**:
   - Set up query logging
   - Monitor slow queries
   - Track index usage
   - Analyze execution plans regularly
