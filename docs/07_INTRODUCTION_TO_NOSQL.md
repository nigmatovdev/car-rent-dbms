# Car Rental System - Introduction to NoSQL

## 1. NoSQL Overview

### 1.1 What is NoSQL?

NoSQL (Not Only SQL) databases are non-relational databases designed for:

- Flexible data models
- Horizontal scaling
- High performance
- High availability

### 1.2 Types of NoSQL Databases

1. **Document Databases**

   - Store data in JSON-like documents
   - Example: MongoDB, Couchbase
   - Good for: Customer profiles, booking history

2. **Key-Value Stores**

   - Simple key-value pairs
   - Example: Redis, DynamoDB
   - Good for: Caching, session management

3. **Column-Family Stores**

   - Store data in columns rather than rows
   - Example: Cassandra, HBase
   - Good for: Time-series data, analytics

4. **Graph Databases**
   - Store data in nodes and relationships
   - Example: Neo4j, ArangoDB
   - Good for: Customer relationships, location networks

## 2. NoSQL Data Models for Car Rental

### 2.1 Document Model (MongoDB)

```json
// Vehicle Document
{
  "_id": "VH123456",
  "make": "Toyota",
  "model": "Camry",
  "year": 2023,
  "category": {
    "name": "Standard",
    "daily_rate": 45.00,
    "weekly_rate": 270.00
  },
  "status": "available",
  "location": {
    "id": "LOC001",
    "name": "Downtown Branch",
    "address": "123 Main Street"
  },
  "maintenance_history": [
    {
      "date": "2023-01-10",
      "type": "routine",
      "cost": 75.00,
      "description": "Oil change"
    }
  ]
}

// Booking Document
{
  "_id": "BK789012",
  "customer": {
    "id": "CUST001",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "vehicle": {
    "id": "VH123456",
    "make": "Toyota",
    "model": "Camry"
  },
  "dates": {
    "start": "2023-03-01T10:00:00Z",
    "end": "2023-03-07T10:00:00Z"
  },
  "locations": {
    "pickup": "LOC001",
    "dropoff": "LOC001"
  },
  "payment": {
    "amount": 315.00,
    "method": "credit_card",
    "status": "completed"
  }
}
```

### 2.2 Key-Value Model (Redis)

```redis
# Vehicle Availability Cache
SET vehicle:VH123456:status "available"
SET vehicle:VH123456:location "LOC001"
SET vehicle:VH123456:last_update "2023-03-01T10:00:00Z"

# Location Vehicle Count
INCR location:LOC001:available_vehicles
INCR location:LOC001:total_vehicles

# Customer Session
HSET session:USER123
  "customer_id" "CUST001"
  "last_activity" "2023-03-01T10:00:00Z"
  "current_booking" "BK789012"
```

### 2.3 Column-Family Model (Cassandra)

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
```

### 2.4 Graph Model (Neo4j)

```cypher
// Create Vehicle Node
CREATE (v:Vehicle {
    id: 'VH123456',
    make: 'Toyota',
    model: 'Camry',
    status: 'available'
})

// Create Location Node
CREATE (l:Location {
    id: 'LOC001',
    name: 'Downtown Branch',
    address: '123 Main Street'
})

// Create Customer Node
CREATE (c:Customer {
    id: 'CUST001',
    name: 'John Doe',
    email: 'john@example.com'
})

// Create Relationships
CREATE (v)-[:LOCATED_AT]->(l)
CREATE (c)-[:BOOKED]->(v)
```

## 3. Use Cases for NoSQL in Car Rental

### 3.1 Real-time Vehicle Tracking

```json
// Vehicle Status Updates
{
  "vehicle_id": "VH123456",
  "timestamp": "2023-03-01T10:00:00Z",
  "location": {
    "latitude": 40.7128,
    "longitude": -74.006
  },
  "status": "in_use",
  "speed": 65,
  "fuel_level": 0.75
}
```

### 3.2 Customer Behavior Analysis

```json
// Customer Profile with Behavior Data
{
  "customer_id": "CUST001",
  "preferences": {
    "vehicle_types": ["SUV", "Premium"],
    "locations": ["Downtown", "Airport"],
    "payment_method": "credit_card"
  },
  "booking_patterns": {
    "average_duration": 7,
    "favorite_season": "summer",
    "last_booking": "2023-02-15"
  },
  "feedback": [
    {
      "rating": 5,
      "comment": "Excellent service",
      "date": "2023-02-20"
    }
  ]
}
```

### 3.3 Dynamic Pricing

```json
// Pricing Rules
{
  "vehicle_id": "VH123456",
  "base_rate": 45.0,
  "dynamic_factors": {
    "demand": 1.2,
    "season": 1.1,
    "duration": 0.9,
    "location": 1.05
  },
  "special_offers": [
    {
      "type": "weekend",
      "discount": 0.15,
      "valid_dates": ["2023-03-04", "2023-03-05"]
    }
  ]
}
```

## 4. Hybrid Approach

### 4.1 When to Use NoSQL vs SQL

**Use NoSQL for:**

- Real-time vehicle tracking
- Customer behavior analytics
- Session management
- Caching frequently accessed data
- Flexible schema requirements

**Use SQL for:**

- Transaction processing
- Financial records
- Customer master data
- Vehicle inventory
- Booking management

### 4.2 Integration Patterns

```json
// Example of Hybrid Data Flow
{
  "booking_created": {
    "sql_transaction": {
      "tables": ["bookings", "payments", "vehicles"],
      "operations": ["INSERT", "UPDATE"]
    },
    "nosql_updates": {
      "redis": ["vehicle_status", "location_inventory"],
      "mongodb": ["customer_profile", "booking_history"]
    }
  }
}
```

## 5. Implementation Considerations

### 5.1 Data Consistency

- Eventual consistency models
- Conflict resolution strategies
- Data synchronization patterns

### 5.2 Scalability

- Horizontal scaling
- Sharding strategies
- Replication patterns

### 5.3 Performance

- Caching strategies
- Index optimization
- Query patterns

### 5.4 Security

- Access control
- Data encryption
- Audit logging

## 6. Migration Strategy

### 6.1 Phased Approach

1. **Phase 1: Analytics**

   - Implement NoSQL for analytics
   - Keep core operations in SQL

2. **Phase 2: Real-time Features**

   - Add real-time tracking
   - Implement caching

3. **Phase 3: Customer Experience**
   - Enhance customer profiles
   - Add personalization

### 6.2 Data Synchronization

```json
// Synchronization Configuration
{
  "source": "postgresql",
  "target": "mongodb",
  "tables": [
    {
      "name": "vehicles",
      "sync_interval": "5m",
      "fields": ["id", "status", "location_id"]
    },
    {
      "name": "customers",
      "sync_interval": "1h",
      "fields": ["id", "preferences", "booking_history"]
    }
  ]
}
```
