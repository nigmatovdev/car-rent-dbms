# Car Rental System - NoSQL Implementations

## 1. MongoDB Implementation

### 1.1 Collections Structure

```javascript
// Vehicles Collection
db.vehicles.createIndex({ make: 1, model: 1 });
db.vehicles.createIndex({ status: 1 });
db.vehicles.createIndex({ "current_location.id": 1 });

// Bookings Collection
db.bookings.createIndex({ "customer.id": 1 });
db.bookings.createIndex({ "vehicle.id": 1 });
db.bookings.createIndex({ "dates.start": 1, "dates.end": 1 });

// Customers Collection
db.customers.createIndex({ email: 1 }, { unique: true });
db.customers.createIndex({ "preferences.vehicle_types": 1 });
```

### 1.2 CRUD Operations

```javascript
// Create Vehicle
db.vehicles.insertOne({
  _id: "VH123456",
  make: "Toyota",
  model: "Camry",
  year: 2023,
  category: {
    name: "Standard",
    daily_rate: 45.0,
    weekly_rate: 270.0,
  },
  status: "available",
  location: {
    id: "LOC001",
    name: "Downtown Branch",
    address: "123 Main Street",
  },
});

// Update Vehicle Status
db.vehicles.updateOne(
  { _id: "VH123456" },
  {
    $set: {
      status: "rented",
      "location.id": "LOC002",
    },
  }
);

// Find Available Vehicles
db.vehicles.find({
  status: "available",
  "category.name": "Standard",
  "location.id": "LOC001",
});

// Aggregate Vehicle Utilization
db.bookings.aggregate([
  {
    $match: {
      "dates.start": { $gte: ISODate("2023-01-01") },
    },
  },
  {
    $group: {
      _id: "$vehicle.id",
      total_days: { $sum: { $subtract: ["$dates.end", "$dates.start"] } },
      booking_count: { $sum: 1 },
    },
  },
]);
```

## 2. Redis Implementation

### 2.1 Key Patterns

```redis
# Vehicle Status
vehicle:{id}:status
vehicle:{id}:location
vehicle:{id}:last_update

# Location Inventory
location:{id}:available_vehicles
location:{id}:total_vehicles

# Customer Sessions
session:{token}:customer_id
session:{token}:last_activity
session:{token}:current_booking
```

### 2.2 Common Operations

```redis
# Set Vehicle Status
SET vehicle:VH123456:status "available"
EXPIRE vehicle:VH123456:status 3600

# Update Location Inventory
INCR location:LOC001:available_vehicles
DECR location:LOC001:available_vehicles

# Manage Customer Session
HSET session:USER123
    "customer_id" "CUST001"
    "last_activity" "2023-03-01T10:00:00Z"
    "current_booking" "BK789012"
EXPIRE session:USER123 1800
```

## 3. Cassandra Implementation

### 3.1 Table Definitions

```sql
-- Vehicle Status Table
CREATE TABLE vehicle_status (
    vehicle_id TEXT,
    timestamp TIMESTAMP,
    status TEXT,
    location_id TEXT,
    mileage INT,
    PRIMARY KEY (vehicle_id, timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);

-- Booking History Table
CREATE TABLE booking_history (
    customer_id TEXT,
    booking_date TIMESTAMP,
    vehicle_id TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    amount DECIMAL,
    status TEXT,
    PRIMARY KEY (customer_id, booking_date)
) WITH CLUSTERING ORDER BY (booking_date DESC);

-- Location Inventory Table
CREATE TABLE location_inventory (
    location_id TEXT,
    date DATE,
    vehicle_id TEXT,
    status TEXT,
    PRIMARY KEY ((location_id, date), vehicle_id)
);
```

### 3.2 Common Queries

```sql
-- Get Latest Vehicle Status
SELECT * FROM vehicle_status
WHERE vehicle_id = 'VH123456'
LIMIT 1;

-- Get Customer Booking History
SELECT * FROM booking_history
WHERE customer_id = 'CUST001'
AND booking_date >= '2023-01-01';

-- Get Location Inventory
SELECT * FROM location_inventory
WHERE location_id = 'LOC001'
AND date = '2023-03-01';
```

## 4. Neo4j Implementation

### 4.1 Graph Schema

```cypher
// Create Constraints
CREATE CONSTRAINT vehicle_id IF NOT EXISTS
FOR (v:Vehicle) REQUIRE v.id IS UNIQUE;

CREATE CONSTRAINT customer_id IF NOT EXISTS
FOR (c:Customer) REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT location_id IF NOT EXISTS
FOR (l:Location) REQUIRE l.id IS UNIQUE;

// Create Indexes
CREATE INDEX vehicle_make IF NOT EXISTS
FOR (v:Vehicle) ON (v.make, v.model);

CREATE INDEX customer_email IF NOT EXISTS
FOR (c:Customer) ON (c.email);
```

### 4.2 Common Queries

```cypher
// Find Available Vehicles at Location
MATCH (v:Vehicle)-[:LOCATED_AT]->(l:Location)
WHERE l.id = 'LOC001' AND v.status = 'available'
RETURN v;

// Get Customer Rental History
MATCH (c:Customer)-[r:RENTED]->(v:Vehicle)
WHERE c.id = 'CUST001'
RETURN v, r.booking_date, r.amount
ORDER BY r.booking_date DESC;

// Find Popular Vehicle Categories
MATCH (c:Customer)-[r:RENTED]->(v:Vehicle)
RETURN v.category, COUNT(r) as rental_count
ORDER BY rental_count DESC;
```

## 5. Implementation Patterns

### 5.1 Event Sourcing

```javascript
// Event Store (MongoDB)
{
    _id: ObjectId(),
    event_type: "VEHICLE_STATUS_CHANGED",
    vehicle_id: "VH123456",
    timestamp: ISODate("2023-03-01T10:00:00Z"),
    data: {
        old_status: "available",
        new_status: "rented",
        location_id: "LOC002"
    }
}

// Projection (Redis)
SET vehicle:VH123456:status "rented"
SET vehicle:VH123456:location "LOC002"
```

### 5.2 CQRS Pattern

```javascript
// Command Side (MongoDB)
db.bookings.insertOne({
    _id: "BK789012",
    customer_id: "CUST001",
    vehicle_id: "VH123456",
    dates: {
        start: ISODate("2023-03-01T10:00:00Z"),
        end: ISODate("2023-03-07T10:00:00Z")
    }
});

// Query Side (Redis)
HSET booking:BK789012
    "status" "confirmed"
    "customer_name" "John Doe"
    "vehicle_make" "Toyota"
    "vehicle_model" "Camry"
```

### 5.3 Cache-Aside Pattern

```javascript
// Application Logic
async function getVehicleStatus(vehicleId) {
  // 1. Try Redis Cache
  let status = await redis.get(`vehicle:${vehicleId}:status`);

  if (!status) {
    // 2. Query MongoDB
    const vehicle = await db.vehicles.findOne({ _id: vehicleId });
    status = vehicle.status;

    // 3. Update Cache
    await redis.set(`vehicle:${vehicleId}:status`, status);
    await redis.expire(`vehicle:${vehicleId}:status`, 3600);
  }

  return status;
}
```

## 6. Performance Optimization

### 6.1 Indexing Strategies

```javascript
// MongoDB Compound Index
db.bookings.createIndex({
    "vehicle.id": 1,
    "dates.start": 1,
    "dates.end": 1
});

// Cassandra Materialized View
CREATE MATERIALIZED VIEW vehicle_status_by_location AS
SELECT * FROM vehicle_status
WHERE location_id IS NOT NULL
PRIMARY KEY (location_id, timestamp, vehicle_id);
```

### 6.2 Query Optimization

```javascript
// MongoDB Aggregation Pipeline
db.bookings.aggregate([
  {
    $match: {
      "dates.start": { $gte: ISODate("2023-01-01") },
    },
  },
  {
    $lookup: {
      from: "vehicles",
      localField: "vehicle.id",
      foreignField: "_id",
      as: "vehicle_details",
    },
  },
  {
    $unwind: "$vehicle_details",
  },
  {
    $group: {
      _id: "$vehicle_details.category.name",
      total_revenue: { $sum: "$payment.amount" },
      booking_count: { $sum: 1 },
    },
  },
]);
```

### 6.3 Data Partitioning

```sql
-- Cassandra Partitioning
CREATE TABLE vehicle_status (
    vehicle_id TEXT,
    timestamp TIMESTAMP,
    status TEXT,
    location_id TEXT,
    PRIMARY KEY ((vehicle_id, date_bucket(timestamp)), timestamp)
);

-- MongoDB Sharding
sh.shardCollection("car_rental.bookings", { "vehicle_id": 1 });
sh.shardCollection("car_rental.vehicles", { "location_id": 1 });
```
