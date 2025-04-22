-- 1. Revenue Analysis Queries

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

-- Revenue by Location and Time Period
SELECT 
    pl.name AS pickup_location,
    dl.name AS dropoff_location,
    TO_CHAR(p.payment_date, 'YYYY-MM') AS month,
    SUM(p.amount) AS total_revenue,
    COUNT(DISTINCT b.booking_id) AS number_of_bookings
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN rental_locations pl ON b.pickup_location_id = pl.location_id
JOIN rental_locations dl ON b.dropoff_location_id = dl.location_id
WHERE p.status = 'completed'
    AND p.payment_date BETWEEN :start_date AND :end_date
GROUP BY pl.name, dl.name, TO_CHAR(p.payment_date, 'YYYY-MM')
ORDER BY total_revenue DESC;

-- 2. Vehicle Utilization Queries

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

-- Maintenance Cost Analysis
SELECT 
    v.vehicle_id,
    v.make,
    v.model,
    v.mileage,
    COUNT(mr.maintenance_id) AS maintenance_count,
    SUM(mr.cost) AS total_maintenance_cost,
    ROUND(AVG(mr.cost), 2) AS average_maintenance_cost,
    MAX(mr.maintenance_date) AS last_maintenance_date
FROM vehicles v
LEFT JOIN maintenance_records mr ON v.vehicle_id = mr.vehicle_id
GROUP BY v.vehicle_id, v.make, v.model, v.mileage
ORDER BY total_maintenance_cost DESC;

-- 3. Customer Analysis Queries

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

-- Customer Segmentation
SELECT 
    CASE
        WHEN COUNT(DISTINCT b.booking_id) >= 10 THEN 'VIP'
        WHEN COUNT(DISTINCT b.booking_id) >= 5 THEN 'Regular'
        ELSE 'Occasional'
    END AS customer_segment,
    COUNT(DISTINCT c.customer_id) AS number_of_customers,
    ROUND(AVG(total_spent), 2) AS average_total_spent,
    ROUND(AVG(booking_count), 2) AS average_bookings
FROM (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT b.booking_id) AS booking_count,
        SUM(p.amount) AS total_spent
    FROM customers c
    JOIN bookings b ON c.customer_id = b.customer_id
    JOIN payments p ON b.booking_id = p.booking_id
    WHERE p.status = 'completed'
    GROUP BY c.customer_id
) AS customer_stats
JOIN customers c ON customer_stats.customer_id = c.customer_id
GROUP BY 
    CASE
        WHEN COUNT(DISTINCT b.booking_id) >= 10 THEN 'VIP'
        WHEN COUNT(DISTINCT b.booking_id) >= 5 THEN 'Regular'
        ELSE 'Occasional'
    END
ORDER BY average_total_spent DESC;

-- 4. Location Performance Analysis

-- Location Revenue and Utilization
SELECT 
    l.location_id,
    l.name AS location_name,
    l.city,
    l.state,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(p.amount) AS total_revenue,
    COUNT(DISTINCT CASE WHEN b.pickup_location_id = l.location_id THEN b.vehicle_id END) AS unique_vehicles_picked_up,
    COUNT(DISTINCT CASE WHEN b.dropoff_location_id = l.location_id THEN b.vehicle_id END) AS unique_vehicles_dropped_off
FROM rental_locations l
LEFT JOIN bookings b ON l.location_id IN (b.pickup_location_id, b.dropoff_location_id)
LEFT JOIN payments p ON b.booking_id = p.booking_id
WHERE p.status = 'completed'
GROUP BY l.location_id, l.name, l.city, l.state
ORDER BY total_revenue DESC;

-- 5. Vehicle Category Analysis

-- Category Performance Metrics
SELECT 
    vc.category_id,
    vc.name AS category_name,
    COUNT(DISTINCT v.vehicle_id) AS total_vehicles,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(p.amount) AS total_revenue,
    ROUND(AVG(p.amount), 2) AS average_booking_value
FROM vehicle_categories vc
LEFT JOIN vehicles v ON vc.category_id = v.category_id
LEFT JOIN bookings b ON v.vehicle_id = b.vehicle_id
LEFT JOIN payments p ON b.booking_id = p.booking_id
WHERE p.status = 'completed'
GROUP BY vc.category_id, vc.name
ORDER BY total_revenue DESC;

-- 6. Maintenance Analysis

-- Maintenance Cost by Vehicle Category
SELECT 
    vc.name AS category,
    COUNT(mr.maintenance_id) AS total_maintenance_records,
    SUM(mr.cost) AS total_maintenance_cost,
    ROUND(AVG(mr.cost), 2) AS average_maintenance_cost,
    COUNT(DISTINCT CASE WHEN mr.maintenance_type = 'routine' THEN mr.maintenance_id END) AS routine_maintenance_count,
    COUNT(DISTINCT CASE WHEN mr.maintenance_type = 'repair' THEN mr.maintenance_id END) AS repair_count
FROM vehicle_categories vc
JOIN vehicles v ON vc.category_id = v.category_id
JOIN maintenance_records mr ON v.vehicle_id = mr.vehicle_id
GROUP BY vc.name
ORDER BY total_maintenance_cost DESC;

-- 7. Booking Pattern Analysis

-- Seasonal Booking Trends
SELECT 
    EXTRACT(MONTH FROM b.start_date) AS month,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(p.amount) AS total_revenue,
    ROUND(AVG(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/86400), 2) AS average_rental_duration
FROM bookings b
JOIN payments p ON b.booking_id = p.booking_id
WHERE p.status = 'completed'
GROUP BY EXTRACT(MONTH FROM b.start_date)
ORDER BY month;

-- 8. Vehicle Performance Metrics

-- Vehicle Performance by Category
SELECT 
    vc.name AS category,
    ROUND(AVG(rh.final_mileage - rh.initial_mileage), 2) AS average_mileage_per_rental,
    ROUND(AVG(CASE 
        WHEN rh.fuel_level_dropoff = 'full' THEN 1
        WHEN rh.fuel_level_dropoff = 'three_quarters' THEN 0.75
        WHEN rh.fuel_level_dropoff = 'half' THEN 0.5
        WHEN rh.fuel_level_dropoff = 'quarter' THEN 0.25
        ELSE 0
    END), 2) AS average_fuel_level_at_return
FROM vehicle_categories vc
JOIN vehicles v ON vc.category_id = v.category_id
JOIN rental_history rh ON v.vehicle_id = rh.vehicle_id
GROUP BY vc.name
ORDER BY average_mileage_per_rental DESC;

-- 9. Revenue by Vehicle
SELECT 
    v.vehicle_id,
    v.make,
    v.model,
    v.license_plate,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(p.amount) AS total_revenue,
    ROUND(AVG(p.amount), 2) AS average_booking_value
FROM vehicles v
JOIN bookings b ON v.vehicle_id = b.vehicle_id
JOIN payments p ON b.booking_id = p.booking_id
WHERE p.status = 'completed'
GROUP BY v.vehicle_id, v.make, v.model, v.license_plate
ORDER BY total_revenue DESC;

-- 10. Customer Booking Frequency
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    ROUND(AVG(EXTRACT(EPOCH FROM (b.end_date - b.start_date))/86400), 2) AS average_rental_duration,
    COUNT(DISTINCT v.category_id) AS different_categories_rented
FROM customers c
JOIN bookings b ON c.customer_id = b.customer_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_bookings DESC;

-- 11. Maintenance Frequency
SELECT 
    v.vehicle_id,
    v.make,
    v.model,
    v.mileage,
    COUNT(mr.maintenance_id) AS maintenance_count,
    ROUND(AVG(EXTRACT(EPOCH FROM (mr.completion_date - mr.maintenance_date))/86400), 2) AS average_maintenance_duration,
    SUM(mr.cost) AS total_maintenance_cost
FROM vehicles v
JOIN maintenance_records mr ON v.vehicle_id = mr.vehicle_id
GROUP BY v.vehicle_id, v.make, v.model, v.mileage
ORDER BY maintenance_count DESC;

-- 12. Location Vehicle Distribution
SELECT 
    l.name AS location_name,
    l.city,
    l.state,
    COUNT(DISTINCT v.vehicle_id) AS total_vehicles,
    COUNT(DISTINCT CASE WHEN v.status = 'available' THEN v.vehicle_id END) AS available_vehicles,
    COUNT(DISTINCT CASE WHEN v.status = 'rented' THEN v.vehicle_id END) AS rented_vehicles,
    COUNT(DISTINCT CASE WHEN v.status = 'maintenance' THEN v.vehicle_id END) AS maintenance_vehicles
FROM rental_locations l
LEFT JOIN vehicles v ON l.location_id = v.current_location_id
GROUP BY l.location_id, l.name, l.city, l.state
ORDER BY total_vehicles DESC; 