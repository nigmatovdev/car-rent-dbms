# Entity-Relationship Diagram for Car Rental System

```
+----------------+       +----------------+       +----------------+
|   CUSTOMERS    |       |    VEHICLES    |       | VEHICLE_CATEGORIES |
+----------------+       +----------------+       +----------------+
| customer_id PK |       | vehicle_id PK  |       | category_id PK |
| first_name     |       | make           |       | name           |
| last_name      |       | model          |       | description    |
| email          |       | year           |       | daily_rate     |
| phone          |       | color          |       | weekly_rate    |
| address        |       | license_plate  |       | monthly_rate   |
| driver_license |       | vin            |       +----------------+
| date_of_birth  |       | category_id FK |--------------^
| created_at     |       | status         |       |
+----------------+       | mileage        |       |
        |                | last_maintenance|      |
        |                | created_at      |      |
        |                +----------------+      |
        |                        |               |
        |                        |               |
        v                        v               |
+----------------+       +----------------+      |
|   BOOKINGS     |       | RENTAL_HISTORY |      |
+----------------+       +----------------+      |
| booking_id PK  |       | history_id PK  |      |
| customer_id FK |-------| booking_id FK  |      |
| vehicle_id FK  |-------| vehicle_id FK  |------+
| pickup_loc_id FK|      | customer_id FK |      |
| dropoff_loc_id FK|     | actual_pickup  |      |
| start_date     |       | actual_dropoff |      |
| end_date       |       | initial_mileage|      |
| status         |       | final_mileage  |      |
| total_amount   |       | fuel_level_pick|      |
| created_at     |       | fuel_level_drop|      |
+----------------+       | notes          |      |
        |                | created_at     |      |
        |                +----------------+      |
        |                        |               |
        |                        |               |
        v                        v               |
+----------------+       +----------------+      |
|   PAYMENTS     |       | MAINTENANCE_RECORDS | |
+----------------+       +----------------+      |
| payment_id PK  |       | maintenance_id PK   | |
| booking_id FK  |       | vehicle_id FK  |------+
| amount         |       | maintenance_type|     |
| payment_method |       | description    |     |
| payment_date   |       | cost           |     |
| status         |       | maintenance_date|    |
| transaction_id |       | next_maintenance|    |
+----------------+       | status         |     |
                        | created_at     |     |
                        +----------------+     |
                                               |
                        +----------------+     |
                        | RENTAL_LOCATIONS|    |
                        +----------------+     |
                        | location_id PK |     |
                        | name           |     |
                        | address        |     |
                        | phone          |     |
                        | email          |     |
                        | operating_hours|     |
                        +----------------+     |
```

## Relationship Types

1. One-to-Many Relationships:

   - Vehicle Category → Vehicles (1:N)
   - Customer → Bookings (1:N)
   - Vehicle → Bookings (1:N)
   - Rental Location → Bookings (1:N) [both pickup and dropoff]
   - Vehicle → Maintenance Records (1:N)

2. Many-to-Many Relationships:
   - Customers ↔ Vehicles (through Bookings)
   - Vehicles ↔ Rental Locations (through Bookings)

## Cardinality Constraints

- Each vehicle belongs to exactly one category
- Each booking is associated with exactly one customer and one vehicle
- Each rental location can have multiple bookings (both pickup and dropoff)
- Each vehicle can have multiple maintenance records
- Each customer can have multiple bookings
- Each booking can have multiple payments (for partial payments or refunds)
