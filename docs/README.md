# Car Rental System Database Documentation

## Project Overview

This project implements a comprehensive car rental management system using PostgreSQL. The system handles vehicle inventory, customer management, booking processing, payment tracking, and maintenance scheduling.

## Database Schema Design

### Entity-Relationship Diagram

The database consists of the following main entities:

1. Customers
2. Vehicles
3. Vehicle Categories
4. Rental Locations
5. Bookings
6. Payments
7. Rental History
8. Maintenance Records

### Relationships

- One-to-Many:

  - Vehicle Category to Vehicles
  - Customer to Bookings
  - Vehicle to Bookings
  - Rental Location to Bookings (pickup and dropoff)
  - Vehicle to Maintenance Records

- Many-to-Many:
  - Customers to Vehicles (through Bookings)
  - Vehicles to Rental Locations (through Bookings)

### Normalization

The database is normalized to 3NF (Third Normal Form):

1. All tables have a primary key
2. No repeating groups
3. All non-key attributes are dependent on the primary key
4. No transitive dependencies

## Table Descriptions

### 1. customers

Stores customer information including personal details and driver's license information.

### 2. vehicle_categories

Defines different vehicle categories with their respective rental rates.

### 3. vehicles

Contains detailed information about each vehicle in the fleet.

### 4. rental_locations

Manages different rental locations and their operating hours.

### 5. bookings

Tracks all rental bookings with their status and details.

### 6. payments

Records all payment transactions related to bookings.

### 7. rental_history

Maintains a history of completed rentals with vehicle condition details.

### 8. maintenance_records

Tracks all maintenance activities performed on vehicles.

## Key Features

### 1. Vehicle Management

- Track vehicle inventory
- Monitor vehicle status
- Schedule maintenance
- Record mileage and condition

### 2. Booking System

- Handle reservations
- Manage pickup and dropoff locations
- Track booking status
- Calculate rental costs

### 3. Customer Management

- Store customer information
- Track rental history
- Manage loyalty programs

### 4. Payment Processing

- Record payments
- Handle refunds
- Track transaction status

### 5. Maintenance Tracking

- Schedule regular maintenance
- Record service history
- Track maintenance costs

## Query Optimization

The database includes several optimized queries for:

1. Finding available vehicles
2. Calculating revenue
3. Tracking vehicle utilization
4. Managing maintenance schedules
5. Analyzing customer behavior

Indexes have been created on frequently queried columns to improve performance.

## Transaction Management

The system implements ACID-compliant transactions for:

1. Booking creation and payment processing
2. Vehicle return and maintenance scheduling
3. Booking cancellations and refunds
4. Vehicle transfers between locations
5. Loyalty program updates

## NoSQL Considerations

While this implementation uses PostgreSQL, a NoSQL solution could be beneficial for:

1. Storing vehicle sensor data
2. Managing real-time availability
3. Handling customer reviews and ratings
4. Storing vehicle images and documents

A document store like MongoDB would be suitable for these use cases due to:

- Flexible schema for varying data types
- Better performance for large binary data
- Easier scaling for high-volume data
- Better support for unstructured data

## Installation and Setup

1. Install PostgreSQL
2. Create the database:
   ```sql
   psql -U postgres -f car_rental_system/sql/01_schema.sql
   ```
3. Load sample data:
   ```sql
   psql -U postgres -d car_rental_system -f car_rental_system/sql/02_sample_data.sql
   ```

## Usage Examples

1. Find available vehicles:

   ```sql
   SELECT * FROM vehicles WHERE status = 'available';
   ```

2. Create a new booking:

   ```sql
   BEGIN;
   INSERT INTO bookings (...) VALUES (...);
   UPDATE vehicles SET status = 'rented' WHERE vehicle_id = X;
   INSERT INTO payments (...) VALUES (...);
   COMMIT;
   ```

3. Process vehicle return:
   ```sql
   BEGIN;
   UPDATE bookings SET status = 'completed' WHERE booking_id = X;
   UPDATE vehicles SET status = 'maintenance' WHERE vehicle_id = Y;
   INSERT INTO rental_history (...) VALUES (...);
   COMMIT;
   ```

## Performance Considerations

1. Indexes are created on frequently queried columns
2. Complex queries are optimized using appropriate JOINs
3. Transactions are used to maintain data integrity
4. Regular maintenance tasks are scheduled
5. Query execution plans are analyzed for optimization

## Security Considerations

1. Sensitive customer data is protected
2. Payment information is securely stored
3. Access controls are implemented
4. Regular backups are performed
5. Audit trails are maintained

## Future Enhancements

1. Implement real-time availability tracking
2. Add customer loyalty program features
3. Integrate with vehicle telematics
4. Add advanced reporting capabilities
5. Implement mobile app integration
