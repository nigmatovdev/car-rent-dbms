# Car Rental System - Conceptual Design

## 1. Entity Analysis

### 1.1 Core Entities

#### Vehicle Categories

- **Attributes**:
  - `category_id` (Primary Key)
  - `name` (Economy, Standard, Premium, SUV, Van)
  - `description`
  - `daily_rate`, `weekly_rate`, `monthly_rate`
  - `created_at`, `updated_at` timestamps

#### Rental Locations

- **Attributes**:
  - `location_id` (Primary Key)
  - `name`
  - `address`, `city`, `state`, `zip_code`
  - `phone`, `email`
  - `is_active` status
  - `created_at`, `updated_at` timestamps

#### Vehicles

- **Attributes**:
  - `vehicle_id` (Primary Key)
  - `category_id` (Foreign Key)
  - `make`, `model`, `year`
  - `color`, `license_plate`, `vin`
  - `mileage`
  - `status` (available, reserved, rented, maintenance, out_of_service)
  - `current_location_id` (Foreign Key)
  - `created_at`, `updated_at` timestamps

#### Customers

- **Attributes**:
  - `customer_id` (Primary Key)
  - `first_name`, `last_name`
  - `email`, `phone`
  - `address`, `city`, `state`, `zip_code`
  - `license_number`, `license_state`, `license_expiry`
  - `date_of_birth`
  - `is_active` status
  - `created_at`, `updated_at` timestamps

#### Bookings

- **Attributes**:
  - `booking_id` (Primary Key)
  - `customer_id` (Foreign Key)
  - `vehicle_id` (Foreign Key)
  - `pickup_location_id`, `dropoff_location_id` (Foreign Keys)
  - `start_date`, `end_date`
  - `total_amount`
  - `status` (pending, confirmed, in_progress, completed, cancelled)
  - `notes`
  - `created_at`, `updated_at` timestamps

#### Payments

- **Attributes**:
  - `payment_id` (Primary Key)
  - `booking_id` (Foreign Key)
  - `amount`
  - `payment_method` (credit_card, debit_card, cash, bank_transfer)
  - `payment_date`
  - `status` (pending, completed, failed, refunded)
  - `transaction_id`
  - `notes`
  - `created_at`, `updated_at` timestamps

#### Rental History

- **Attributes**:
  - `history_id` (Primary Key)
  - `booking_id` (Foreign Key)
  - `vehicle_id` (Foreign Key)
  - `customer_id` (Foreign Key)
  - `actual_pickup_date`, `actual_dropoff_date`
  - `initial_mileage`, `final_mileage`
  - `fuel_level_pickup`, `fuel_level_dropoff` (empty, quarter, half, three_quarters, full)
  - `notes`
  - `created_at`, `updated_at` timestamps

#### Maintenance Records

- **Attributes**:
  - `maintenance_id` (Primary Key)
  - `vehicle_id` (Foreign Key)
  - `maintenance_type` (routine, repair, accident, recall)
  - `description`
  - `maintenance_date`, `completion_date`
  - `cost`
  - `mileage`
  - `status` (scheduled, in_progress, completed, cancelled)
  - `notes`
  - `created_at`, `updated_at` timestamps

## 2. Relationship Analysis

### 2.1 Core Relationships

1. **Vehicle to Category** (Many-to-One)

   - Each vehicle belongs to one category
   - Each category can have multiple vehicles

2. **Vehicle to Location** (Many-to-One)

   - Each vehicle is assigned to one location
   - Each location can have multiple vehicles

3. **Booking to Customer** (Many-to-One)

   - Each booking is made by one customer
   - Each customer can have multiple bookings

4. **Booking to Vehicle** (Many-to-One)

   - Each booking is for one vehicle
   - Each vehicle can have multiple bookings

5. **Payment to Booking** (Many-to-One)

   - Each payment is associated with one booking
   - Each booking can have multiple payments

6. **Rental History to Booking** (One-to-One)

   - Each rental history record corresponds to one booking
   - Each booking has one rental history record

7. **Maintenance to Vehicle** (Many-to-One)
   - Each maintenance record is for one vehicle
   - Each vehicle can have multiple maintenance records

## 3. Cardinality Constraints

### 3.1 Mandatory Relationships

1. **Vehicle-Category**

   - Every vehicle must belong to a category
   - Every category must have at least one vehicle

2. **Vehicle-Location**

   - Every vehicle must be assigned to a location
   - Every location must have at least one vehicle

3. **Booking-Customer**

   - Every booking must be made by a customer
   - Every customer must have at least one booking

4. **Booking-Vehicle**
   - Every booking must be for a vehicle
   - Every vehicle must have at least one booking

### 3.2 Optional Relationships

1. **Payment-Booking**

   - A booking may have multiple payments
   - A payment must be associated with a booking

2. **Maintenance-Vehicle**
   - A vehicle may have multiple maintenance records
   - A maintenance record must be for a vehicle

## 4. Business Rules

### 4.1 Vehicle Management

1. **Status Transitions**

   - Available → Reserved → Rented → Available
   - Available → Maintenance → Available
   - Any status → Out of Service

2. **Location Rules**
   - Vehicles can only be transferred between active locations
   - Each location must maintain minimum vehicle inventory

### 4.2 Booking Management

1. **Booking Rules**

   - Start date must be before end date
   - Vehicle must be available at start date
   - Customer must have valid license
   - Booking must be paid before start date

2. **Payment Rules**
   - Payment amount must match booking total
   - Payment must be completed before rental start
   - Refunds only allowed for cancelled bookings

### 4.3 Maintenance Rules

1. **Scheduling Rules**

   - Maintenance must be scheduled in advance
   - Vehicle must be available for maintenance
   - Maintenance duration must be specified

2. **Cost Rules**
   - Maintenance costs must be recorded
   - Cost must be positive
   - Completion date must be after start date

## 5. Data Integrity Constraints

### 5.1 Primary Keys

- All entities have unique identifier fields
- Composite keys used where appropriate

### 5.2 Foreign Keys

- All relationships enforced through foreign keys
- Cascading updates and deletes where appropriate

### 5.3 Check Constraints

- Date validations (start_date < end_date)
- Amount validations (positive values)
- Status transitions
- Email format validation
- Phone number format validation

### 5.4 Unique Constraints

- Vehicle license plates
- Customer emails
- Customer license numbers (per state)
- Payment transaction IDs

## 6. Entity Lifecycle

### 6.1 Vehicle Lifecycle

1. **Acquisition**

   - Add to inventory
   - Assign category
   - Set initial location
   - Record specifications

2. **Operation**

   - Status updates
   - Location transfers
   - Maintenance scheduling
   - Rental history tracking

3. **Retirement**
   - Mark as out of service
   - Archive records
   - Update inventory

### 6.2 Customer Lifecycle

1. **Registration**

   - Create customer record
   - Verify license
   - Set up payment methods

2. **Activity**

   - Booking history
   - Payment records
   - Rental history
   - Status updates

3. **Inactivity**
   - Mark as inactive
   - Archive records
   - Retain history

## 7. Data Volume Considerations

### 7.1 Expected Volumes

1. **Vehicles**

   - Initial: 50-100 vehicles
   - Growth: 10-20% annually
   - Peak: 200-300 vehicles

2. **Customers**

   - Initial: 500-1000 customers
   - Growth: 20-30% annually
   - Peak: 5000-10000 customers

3. **Bookings**

   - Daily: 50-100 bookings
   - Monthly: 1500-3000 bookings
   - Annual: 18000-36000 bookings

4. **Maintenance Records**
   - Monthly: 20-40 records
   - Annual: 240-480 records
   - Per vehicle: 4-6 records annually

### 7.2 Storage Requirements

1. **Database Size**

   - Initial: 1-2 GB
   - Annual growth: 500 MB - 1 GB
   - 5-year projection: 3-7 GB

2. **Backup Requirements**
   - Daily incremental backups
   - Weekly full backups
   - Monthly archive backups
   - 3-month retention period

### 7.3 Performance Considerations

1. **Query Performance**

   - Booking queries: < 1 second
   - Report generation: < 5 seconds
   - Analytics queries: < 10 seconds

2. **Concurrency**
   - Support for 50+ concurrent users
   - Handle 100+ transactions per minute
   - Maintain data consistency under load
