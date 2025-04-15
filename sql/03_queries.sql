-- Complex Queries for Car Rental System

-- 1. Find available vehicles in a specific category with their rates
SELECT 
    v.vehicle_id,
    v.make,
    v.model,
    v.year,
    v.color,
    vc.name as category,
    vc.daily_rate,
    vc.weekly_rate,
    vc.monthly_rate
FROM 
    vehicles v
JOIN 
    vehicle_categories vc ON v.category_id = vc.category_id
WHERE 
    v.status = 'available'
ORDER BY 
    vc.daily_rate;

-- 2. Calculate total revenue by vehicle category for the last month
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

-- 3. Find customers with the most rentals and their total spending
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(b.booking_id) as total_rentals,
    SUM(b.total_amount) as total_spent,
    AVG(b.total_amount) as average_rental_cost
FROM 
    customers c
JOIN 
    bookings b ON c.customer_id = b.customer_id
WHERE 
    b.status = 'completed'
GROUP BY 
    c.customer_id, c.first_name, c.last_name
ORDER BY 
    total_rentals DESC
LIMIT 5;

-- 4. Find vehicles that need maintenance based on mileage
SELECT 
    v.vehicle_id,
    v.make,
    v.model,
    v.mileage,
    v.last_maintenance_date,
    v.status,
    CASE 
        WHEN v.mileage - (SELECT MAX(initial_mileage) 
                         FROM rental_history rh 
                         WHERE rh.vehicle_id = v.vehicle_id) > 5000 
        THEN 'Due for maintenance'
        ELSE 'Maintenance not due'
    END as maintenance_status
FROM 
    vehicles v
WHERE 
    v.status != 'maintenance'
ORDER BY 
    v.mileage DESC;

-- 5. Calculate utilization rate of vehicles
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

-- 6. Find most popular pickup and dropoff locations
SELECT 
    rl.name as location_name,
    COUNT(CASE WHEN b.pickup_location_id = rl.location_id THEN 1 END) as pickup_count,
    COUNT(CASE WHEN b.dropoff_location_id = rl.location_id THEN 1 END) as dropoff_count,
    COUNT(b.booking_id) as total_transactions
FROM 
    rental_locations rl
LEFT JOIN 
    bookings b ON rl.location_id = b.pickup_location_id OR rl.location_id = b.dropoff_location_id
GROUP BY 
    rl.location_id, rl.name
ORDER BY 
    total_transactions DESC;

-- 7. Find customers with upcoming bookings
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    b.booking_id,
    b.start_date,
    b.end_date,
    v.make,
    v.model,
    rl_pickup.name as pickup_location,
    rl_dropoff.name as dropoff_location
FROM 
    customers c
JOIN 
    bookings b ON c.customer_id = b.customer_id
JOIN 
    vehicles v ON b.vehicle_id = v.vehicle_id
JOIN 
    rental_locations rl_pickup ON b.pickup_location_id = rl_pickup.location_id
JOIN 
    rental_locations rl_dropoff ON b.dropoff_location_id = rl_dropoff.location_id
WHERE 
    b.start_date >= CURRENT_DATE
    AND b.status = 'confirmed'
ORDER BY 
    b.start_date;

-- 8. Calculate maintenance costs by vehicle
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

-- 9. Find vehicles with the highest revenue per day
SELECT 
    v.vehicle_id,
    v.make,
    v.model,
    COUNT(b.booking_id) as total_bookings,
    SUM(b.total_amount) as total_revenue,
    SUM(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/3600/24) as total_rental_days,
    (SUM(b.total_amount) / NULLIF(SUM(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/3600/24), 0)) as revenue_per_day
FROM 
    vehicles v
JOIN 
    bookings b ON v.vehicle_id = b.vehicle_id
WHERE 
    b.status = 'completed'
GROUP BY 
    v.vehicle_id, v.make, v.model
HAVING 
    SUM(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/3600/24) > 0
ORDER BY 
    revenue_per_day DESC;

-- 10. Find seasonal booking patterns
SELECT 
    EXTRACT(MONTH FROM b.start_date) as month,
    COUNT(b.booking_id) as total_bookings,
    SUM(b.total_amount) as total_revenue,
    AVG(b.total_amount) as average_booking_amount,
    COUNT(DISTINCT b.customer_id) as unique_customers
FROM 
    bookings b
WHERE 
    b.status = 'completed'
GROUP BY 
    EXTRACT(MONTH FROM b.start_date)
ORDER BY 
    month; 