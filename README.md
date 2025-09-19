# Airline Reservation System

This project implements a simple Airline Reservation System using **PostgreSQL**. It includes tables, constraints, stored procedures (CRUD), and views to manage passengers, flights, seats, cities, payments, and reservations.

---

## Table of Contents

- [Database Schema](#database-schema)  
- [Tables](#tables)  
- [Stored Procedures](#stored-procedures)  
- [Views](#views)  
- [Setup Instructions](#setup-instructions)  
- [Example Queries](#example-queries)

---

## Database Schema

The database consists of the following tables:

1. **Passengers** – Stores passenger details  
2. **Cities** – Stores city names  
3. **Payments** – Stores payment information linked to passengers  
4. **Seat_Classes** – Stores different seat classes (Economy, Business, First Class)  
5. **Flights** – Stores flight information with seat availability per class  
6. **Seats** – Stores seat details per flight  
7. **Reservations** – Stores reservations linking passengers, seats, flights, and payments  

---

## Tables

### Passengers
- `passenger_id` (PK, SERIAL)  
- `passenger_name` (VARCHAR)  
- `passenger_email` (VARCHAR)  
- `passenger_age` (INT, must be > 0)  
- `bank_card_no` (VARCHAR)  

### Cities
- `city_id` (PK, SERIAL)  
- `city_name` (VARCHAR)  

### Payments
- `payment_id` (PK, SERIAL)  
- `passenger_id` (FK → Passengers)  
- `payment_amount` (MONEY)  

### Seat_Classes
- `class_id` (PK, SERIAL)  
- `class_name` (VARCHAR)  

### Flights
- `flight_id` (PK, SERIAL)  
- `city_from_id` (FK → Cities)  
- `city_to_id` (FK → Cities, must differ from city_from_id)  
- `flight_name` (VARCHAR)  
- `flight_date` (DATE)  
- `flight_time` (TIME)  
- Seat availability & reserved count per class  

### Seats
- `seat_id` (PK, SERIAL)  
- `flight_id`, `city_from_id`, `city_to_id` (FK → Flights)  
- `seat_name`  
- `seat_class_id` (FK → Seat_Classes)  
- `seat_price`  

### Reservations
- `reservation_id` (PK, SERIAL)  
- `passenger_id` (FK → Passengers)  
- `seat_id` (FK → Seats)  
- `flight_id`, `city_from_id`, `city_to_id` (FK → Flights/Seats)  
- `payment_id` (FK → Payments)  

---

## Stored Procedures

### Passengers
- `add_passenger(name, email, age, card)` – Create  
- `get_all_passengers()` – Read all  
- `get_passenger_by_name(name)` – Read by name  
- `update_passenger_data(id, name, email, age, card)` – Update  
- `delete_passenger(id)` – Delete  

### Cities
- `add_city(name)`  
- `get_all_cities()`  
- `get_city_by_name(name)`  
- `update_city_name(id, name)`  
- `remove_city(id)`  

### Payments
- `add_payment(passenger_id, amount)`  
- `get_all_payments()`  
- `get_payment_by_id(id)`  
- `update_payment(id, amount)`  
- `delete_payment(id)`  

### Seat_Classes
- `get_seat_classes()`  
- `get_class_by_name(name)`  
- `update_class_name(id, name)`  

### Flights
- `add_flight(city_from, city_to, name, date, time, eco_av, eco_res, bus_av, bus_res, first_av, first_res)`  
- `get_flight_data(id)`  
- `update_timing(id, time)`  
- `update_date(id, date)`  
- `update_flight_seats_availability(id, eco_av, eco_res, bus_av, bus_res, first_av, first_res)`  
- `delete_flight(id)`  

### Seats
- `add_seat(flight_id, city_from, city_to, seat_name, seat_class_id, seat_price)`  
- `get_all_seats()`  
- `get_a_flight_seat(name, flight_id)`  
- `update_seat_price(name, flight_id, price)`  

### Reservations
- `add_reservation(passenger_id, seat_id, flight_id, city_from, city_to, payment_id)`  
- `get_reservation(id)`  
- `delete_reservation(id)`  

---

## Views

- `view_reservations_details` – Detailed reservation info  
- `view_flight_seats` – Flight and seat availability  
- `view_payments_summary` – Payments summary with passenger info  
- `view_seat_details_per_flight` – Seat details per flight  

---

## Setup Instructions

1. Install PostgreSQL.  
2. Create a database, e.g., `airline_db`.  
3. Run the provided SQL script to create tables, insert sample data, and create functions & views.  
4. Use `SELECT` statements or stored procedures to interact with the system.

---

## Example Queries

```sql
-- Get all passengers
SELECT * FROM get_all_passengers();

-- Add a new flight
SELECT add_flight(1, 2, 'PK-303', '2025-09-20', '10:00', 50, 0, 10, 0, 5, 0);

-- Check reservation details
SELECT * FROM view_reservations_details;

-- Update seat price
SELECT update_seat_price('1A', 1, '$220');
