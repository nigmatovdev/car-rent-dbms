# Car Rental System - Logical Design

## 1. Table Definitions

### 1.1 Vehicle Categories

```sql
CREATE TABLE vehicle_categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    daily_rate DECIMAL(10,2) NOT NULL,
    weekly_rate DECIMAL(10,2) NOT NULL,
    monthly_rate DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 1.2 Rental Locations

```sql
CREATE TABLE rental_locations (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 1.3 Vehicles

```sql
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES vehicle_categories(category_id),
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    color VARCHAR(30) NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    vin VARCHAR(17) NOT NULL UNIQUE,
    mileage INTEGER NOT NULL DEFAULT 0,
    status vehicle_status NOT NULL DEFAULT 'available',
    current_location_id INTEGER REFERENCES rental_locations(location_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 1.4 Customers

```sql
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    license_state VARCHAR(50) NOT NULL,
    license_expiry DATE NOT NULL,
    date_of_birth DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (license_number, license_state)
);
```

### 1.5 Bookings

```sql
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id),
    pickup_location_id INTEGER NOT NULL REFERENCES rental_locations(location_id),
    dropoff_location_id INTEGER NOT NULL REFERENCES rental_locations(location_id),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status booking_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 1.6 Payments

```sql
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES bookings(booking_id),
    amount DECIMAL(10,2) NOT NULL,
    payment_method payment_method NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status payment_status NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 1.7 Rental History

```sql
CREATE TABLE rental_history (
    history_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES bookings(booking_id),
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id),
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    actual_pickup_date TIMESTAMP WITH TIME ZONE,
    actual_dropoff_date TIMESTAMP WITH TIME ZONE,
    initial_mileage INTEGER NOT NULL,
    final_mileage INTEGER,
    fuel_level_pickup fuel_level NOT NULL,
    fuel_level_dropoff fuel_level,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 1.8 Maintenance Records

```sql
CREATE TABLE maintenance_records (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id),
    maintenance_type maintenance_type NOT NULL,
    description TEXT NOT NULL,
    maintenance_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completion_date TIMESTAMP WITH TIME ZONE,
    cost DECIMAL(10,2) NOT NULL,
    mileage INTEGER NOT NULL,
    status maintenance_status NOT NULL DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## 2. Normalization Analysis

### 2.1 First Normal Form (1NF)

- All tables have atomic values
- No repeating groups
- Primary keys defined for all tables
- All attributes are single-valued

### 2.2 Second Normal Form (2NF)

- All tables are in 1NF
- No partial dependencies
- All non-key attributes depend on the entire primary key
- Foreign keys properly defined

### 2.3 Third Normal Form (3NF)

- All tables are in 2NF
- No transitive dependencies
- All attributes depend directly on the primary key
- Proper separation of concerns

## 3. Indexes

### 3.1 Primary Indexes

- All primary keys are indexed by default
- SERIAL columns for auto-incrementing IDs

### 3.2 Foreign Key Indexes

```sql
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

### 3.3 Composite Indexes

- Booking dates for efficient date range queries
- Customer and vehicle combinations for rental history
- Location and status combinations for vehicle availability

## 4. Data Types and Sizes

### 4.1 Numeric Types

- DECIMAL(10,2) for monetary values
- INTEGER for IDs and counts
- SERIAL for auto-incrementing IDs

### 4.2 String Types

- VARCHAR(50) for names and short text
- VARCHAR(100) for emails and addresses
- VARCHAR(200) for full addresses
- TEXT for long descriptions and notes

### 4.3 Date/Time Types

- TIMESTAMP WITH TIME ZONE for all temporal data
- DATE for birth dates and license expiry

### 4.4 Boolean Types

- BOOLEAN for status flags
- Default values set appropriately

## 5. Performance Considerations

### 5.1 Query Optimization

- Indexes on frequently queried columns
- Composite indexes for common join conditions
- Proper data types for efficient storage

### 5.2 Transaction Management

- Appropriate isolation levels
- Proper locking strategies
- Efficient transaction boundaries

### 5.3 Data Access Patterns

- Read-heavy operations for booking queries
- Write-heavy operations for rental transactions
- Mixed workload for maintenance records

### 5.4 Scalability Considerations

- Partitioning strategy for large tables
- Index maintenance procedures
- Backup and recovery procedures

## 6. Security Considerations

### 6.1 Data Protection

- Sensitive data encryption
- Access control mechanisms
- Audit logging

### 6.2 User Roles

- Customer access
- Staff access
- Administrative access
- Maintenance staff access

### 6.3 Data Privacy

- Personal information protection
- Payment data security
- License information security

## 7. Maintenance Procedures

### 7.1 Regular Maintenance

- Index rebuilding
- Statistics updates
- Vacuum operations

### 7.2 Backup Procedures

- Daily incremental backups
- Weekly full backups
- Monthly archive backups

### 7.3 Recovery Procedures

- Point-in-time recovery
- Transaction log management
- Disaster recovery planning
