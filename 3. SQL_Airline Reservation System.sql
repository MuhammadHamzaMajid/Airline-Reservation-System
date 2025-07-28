CREATE TABLE Passengers(
  passenger_id SERIAL PRIMARY KEY,
  passenger_name VARCHAR(80) NOT NULL,
  passenger_email VARCHAR(80) NOT NULL,
  passenger_age INT NOT NULL,
  bank_card_no VARCHAR(20) NOT NULL
);
ALTER TABLE Passengers
ADD CONSTRAINT check_passenger_age
CHECK (passenger_age > 0);

CREATE TABLE Cities(
  city_id SERIAL PRIMARY KEY,
  city_name VARCHAR(30) NOT NULL
);

INSERT INTO Passengers (passenger_name, passenger_email, passenger_age, bank_card_no)
VALUES
('Ali', 'ali@gmail.com', 20, '1234-5678-9012-3456'),
('Hamza', 'hamza@gmail.com', 21, '7890-1234-5678-9012');

INSERT INTO Cities (city_name)
VALUES
('Dubai'), ('Lahore');

CREATE TABLE Payments(
  payment_id SERIAL PRIMARY KEY,
  passenger_id INT REFERENCES Passengers(passenger_id),
  payment_amount MONEY
);
INSERT INTO Payments(passenger_id, payment_amount)
VALUES (1, '$400');

CREATE TABLE Seat_Classes(
  class_id SERIAL PRIMARY KEY,
  class_name VARCHAR(15) NOT NULL
);
INSERT INTO Seat_Classes(class_name)
VALUES
('Economy'),('Business'),('First class');

CREATE TABLE Flights(
  flight_id SERIAL,
  city_from_id INT REFERENCES Cities(city_id),
  city_to_id INT REFERENCES Cities(city_id),
  flight_name VARCHAR(8) NOT NULL,
  flight_date DATE NOT NULL,
  flight_time TIME NOT NULL,
  eco_class_seats_available INT,
  eco_class_seats_reserved INT,
  business_class_seats_available INT,
  business_class_seats_reserved INT,
  first_class_seats_available INT,
  first_class_seats_reserved INT,
  PRIMARY KEY (flight_id, city_from_id, city_to_id)
);
ALTER TABLE Flights
ADD CONSTRAINT check_city_diff
CHECK (city_from_id <> city_to_id);
ALTER TABLE Flights
ADD CONSTRAINT check_seats_non_negative
CHECK (
  eco_class_seats_available >= 0 AND
  eco_class_seats_reserved >= 0 AND
  business_class_seats_available >= 0 AND
  business_class_seats_reserved >= 0 AND
  first_class_seats_available >= 0 AND
  first_class_seats_reserved >= 0
);


INSERT INTO Flights (city_from_id, city_to_id, flight_name, flight_date, flight_time, eco_class_seats_available, eco_class_seats_reserved, business_class_seats_available, business_class_seats_reserved, first_class_seats_available, first_class_seats_reserved)
VALUES
(1, 2, 'PK-212', '2025-06-01', '14:30:00', 30, 10, 10, 3, 2, 1),
(2, 1, 'PK-101', '2025-06-07', '02:40:00', 20, 20, 5, 8, 2, 1);



CREATE TABLE Seats(
  seat_id SERIAL,
  flight_id INT,
  city_from_id INT,
  city_to_id INT,
  seat_name VARCHAR(4) NOT NULL,
  seat_class_id INT REFERENCES Seat_Classes(class_id),
  seat_price MONEY NOT NULL,
  PRIMARY KEY(seat_id, flight_id, city_from_id, city_to_id),
  FOREIGN KEY(flight_id, city_from_id, city_to_id)
  REFERENCES Flights(flight_id, city_from_id, city_to_id)
);
ALTER TABLE Seats
ADD CONSTRAINT unique_flight_seat
UNIQUE (flight_id, city_from_id, city_to_id, seat_name);


INSERT INTO Seats(flight_id, city_from_id, city_to_id, seat_name, seat_class_id, seat_price)
VALUES
(1, 1, 2, '1A', 1, '$200'),
(1, 1, 2, '1B', 1, '$205'),
(1, 1, 2, '1C', 1, '$210'),
(1, 1, 2, '2A', 1, '$200'),
(1, 1, 2, '2B', 1, '$205'),
(1, 1, 2, '2C', 1, '$205'),
(1, 1, 2, '3A', 1, '$205'),
(1, 1, 2, '3B', 1, '$205'),
(1, 1, 2, '4A', 2, '$300'),
(1, 1, 2, '4B', 2, '$300'),
(1, 1, 2, '5A', 3, '$400'),

(2, 2, 1, '1A', 1, '$205'),
(2, 2, 1, '1B', 1, '$205'),
(2, 2, 1, '1C', 1, '$200'),
(2, 2, 1, '2A', 1, '$210'),
(2, 2, 1, '2B', 1, '$215'),
(2, 2, 1, '2C', 1, '$205'),
(2, 2, 1, '2D', 1, '$205'),
(2, 2, 1, '3A', 2, '$310'),
(2, 2, 1, '3B', 2, '$310'),
(2, 2, 1, '4A', 3, '$400');


CREATE TABLE Reservations(
  reservation_id SERIAL PRIMARY KEY,
  passenger_id INT REFERENCES Passengers(passenger_id),
  seat_id INT,
  flight_id INT,
  city_from_id INT,
  city_to_id INT,
  payment_id INT REFERENCES Payments(payment_id),
  FOREIGN KEY (seat_id, flight_id, city_from_id, city_to_id) REFERENCES Seats(seat_id, flight_id, city_from_id, city_to_id)
);

INSERT INTO Reservations(passenger_id, seat_id, flight_id, city_from_id, city_to_id, payment_id)
VALUES
(1, 11, 1, 1, 2, 1);



--Stored CRUD Procedures Start From Here

--For the Passengers Table
--1. Add a Passenger(Create Operation)
CREATE FUNCTION add_passenger(p_name VARCHAR, p_email VARCHAR, p_age INT, p_card VARCHAR)
RETURNS VOID AS $$
BEGIN
  INSERT INTO Passengers(passenger_name, passenger_email, passenger_age, bank_card_no)
  VALUES (p_name, p_email, p_age, p_card);
END;
$$ LANGUAGE plpgsql;

--2a. Get all Passengers' Data(Read Operation)
CREATE FUNCTION get_all_passengers()
RETURNS TABLE(id INT, name VARCHAR, email VARCHAR, age INT, card_no VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Passengers;
END;
$$ LANGUAGE plpgsql;

--2b. Get one Passenger's Data by name(another Read Operation)
CREATE OR REPLACE FUNCTION get_passenger_by_name(p_name VARCHAR)
RETURNS TABLE(id int, name VARCHAR, email VARCHAR, age INT, card_no VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Passengers WHERE passenger_name = p_name;
END;
$$ LANGUAGE plpgsql;

--3. Update a Passenger's Data(Update Operation)
CREATE FUNCTION update_passenger_data(p_id INT, p_name VARCHAR, p_email VARCHAR, p_age INT, p_card VARCHAR)
RETURNS VOID AS $$
BEGIN
  UPDATE Passengers
  SET passenger_name = p_name,
      passenger_email = p_email,
	  passenger_age = p_age,
	  bank_card_no = p_card
  WHERE passenger_id = p_id;
END;
$$ LANGUAGE plpgsql;

--4. Delete a Passenger's Data(Delete Operation)
CREATE FUNCTION delete_passenger(p_id INT)
RETURNS VOID AS $$
BEGIN 
  DELETE FROM Passengers WHERE passenger_id = p_id;
  --the alter statement renumbers the passenger_ids after removal of one passenger's data(one row)
  --ALTER SEQUENCE passengers_passenger_id_seq RESTART WITH 1;
  --we can use this incase we want to renumber the passengers altogether
END;
$$ LANGUAGE plpgsql;


--For the Cities Table
--1. Add a City(Create Operation)
CREATE FUNCTION add_city(c_name VARCHAR)
RETURNS VOID AS $$
BEGIN
  INSERT INTO Cities(city_name)
  VALUES (c_name);
END;
$$ LANGUAGE plpgsql;

--2a. Get all the Cities(Read Operation)
CREATE FUNCTION get_all_cities()
RETURNS TABLE(id INT, c_name VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Cities;
END;
$$ LANGUAGE plpgsql;

--2b. Get a city by name(Another Read Operation)
CREATE FUNCTION get_city_by_name(c_name VARCHAR)
RETURNS TABLE(id INT, name VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Cities WHERE city_name = c_name;
END;
$$ LANGUAGE plpgsql;

--3. Update a City's Name(Update Operation)
CREATE FUNCTION update_city_name(c_id INT, c_name VARCHAR)
RETURNS VOID AS $$
BEGIN
  UPDATE Cities
  SET city_name = c_name WHERE city_id = c_id;
END;
$$ LANGUAGE plpgsql;
  
--4. Delete a City(Delete Operation)
CREATE FUNCTION remove_city(c_id INT)
RETURNS VOID AS $$
BEGIN
  DELETE FROM Cities WHERE city_id = c_id;
END;
$$ LANGUAGE plpgsql;


--For the Payments Table
--1. Add a payment(Create Operation)
CREATE FUNCTION add_payment(p_id INT, amount MONEY)
RETURNS VOID AS $$
BEGIN
  INSERT INTO Payments(passenger_id, payment_amount)
  VALUES (p_id, amount);
END;
$$ LANGUAGE plpgsql;

--2a. Get all payments(Read Operation)
CREATE FUNCTION get_all_payments()
RETURNS TABLE(id INT, passenger_id INT, amount MONEY) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Payments;
END;
$$ LANGUAGE plpgsql;

--2b. Get payment by id(Another Read Operation)
CREATE FUNCTION get_payment_by_id(p_id INT)
RETURNS TABLE(id INT, passenger_id INT, amount MONEY) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Payments WHERE payment_id = p_id;
END;
$$ LANGUAGE plpgsql;

--3. Update Payment(In case of human errors while data loading)
CREATE FUNCTION update_payment(p_id INT, amount MONEY)
RETURNS VOID AS $$
BEGIN
  UPDATE Payments
  SET payment_amount = amount WHERE payment_id = p_id;
END;
$$ LANGUAGE plpgsql;

--4. Delete Payment(Delete Operation)
CREATE FUNCTION delete_payment(p_id INT)
RETURNS VOID AS $$
BEGIN
  DELETE FROM Payments WHERE payment_id = p_id;
END;
$$ LANGUAGE plpgsql;


--For Seat_Classes
--2a. Get all seat classes(Read Operation)
CREATE FUNCTION get_seat_classes()
RETURNS TABLE(id INT, class VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Seat_Classes;
END;
$$ LANGUAGE plpgsql;

--2b. Get a specific seat_class by name(Another Read Operation)
CREATE FUNCTION get_class_by_name(name VARCHAR)
RETURNS TABLE(id INT, c_name VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Seat_Classes WHERE class_name = name;
END;
$$ LANGUAGE plpgsql;

--3. Update Class Name(Update Operation)
CREATE FUNCTION update_class_name(id INT, name VARCHAR)
RETURNS VOID AS $$
BEGIN
  UPDATE Seat_Classes
  SET class_name = name WHERE class_id = id;
END;
$$ LANGUAGE plpgsql;


--For Flights
--1. Add a flight(Create Operation)
CREATE OR REPLACE FUNCTION add_flight(city_fro INT, city_to INT, name VARCHAR, date DATE, f_time TIME, eco_av INT, eco_res INT, bus_av INT, bus_res INT, first_av INT, first_res INT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO Flights (city_from_id, city_to_id, flight_name, flight_date, flight_time, eco_class_seats_available, eco_class_seats_reserved, business_class_seats_available, business_class_seats_reserved, first_class_seats_available, first_class_seats_reserved)
  VALUES(city_fro, city_to, name, date, f_time, eco_av, eco_res, bus_av, bus_res, first_av, first_res);
END;
$$ LANGUAGE plpgsql;

--2. Get Flight Data(Read Operation)
CREATE FUNCTION get_flight_data(id INT)
RETURNS TABLE(f_id INT, city_fro INT, city_to INT, name VARCHAR, date DATE, f_time TIME, eco_av INT, eco_res INT, bus_av INT, bus_res INT, first_av INT, first_res INT) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Flights WHERE flight_id = id;
END;
$$ LANGUAGE plpgsql;

--3a. Update flight timing
CREATE OR REPLACE FUNCTION update_timing(id INT, f_time TIME)
RETURNS VOID AS $$
BEGIN
  UPDATE Flights
  SET flight_time = f_time
  WHERE flight_id = id;
END;
$$ LANGUAGE plpgsql;

--3b. Update flight date
CREATE FUNCTION update_date(id INT, f_date DATE)
RETURNS VOID AS $$
BEGIN
  UPDATE Flights
  SET flight_date = f_date
  WHERE flight_id = id;
END;
$$ LANGUAGE plpgsql;
  
--3c. Update seats availability
CREATE FUNCTION update_flight_seats_availability(id INT, eco_av INT, eco_res INT, bus_av INT, bus_res INT, first_av INT, first_res INT)
RETURNS VOID AS $$
BEGIN
  UPDATE Flights
  SET
  eco_class_seats_available = eco_av,
  eco_class_seats_reserved = eco_res,
  business_class_seats_available = bus_av,
  business_class_seats_reserved = bus_res,
  first_class_seats_available = first_av,
  first_class_seats_reserved = first_res
  WHERE flight_id = id;
END;
$$ LANGUAGE plpgsql;

--4. Delete flight(Delete Operation)
CREATE FUNCTION delete_flight(id INT)
RETURNS VOID AS $$
BEGIN
  DELETE FROM Flights WHERE flight_id = id;
END;
$$ LANGUAGE plpgsql;


--For Seats Table
--1. Add a Seat
CREATE FUNCTION add_seat(p_flight_id INT, p_city_from_id INT, p_city_to_id INT, p_seat_name VARCHAR, p_seat_class_id INT, p_seat_price MONEY)
RETURNS VOID AS $$
BEGIN
   INSERT INTO Seats (flight_id, city_from_id, city_to_id, seat_name, seat_class_id, seat_price)
   VALUES (p_flight_id, p_city_from_id, p_city_to_id, p_seat_name, p_seat_class_id, p_seat_price);
END;
$$ LANGUAGE plpgsql;

--2a. Get all seats
CREATE OR REPLACE FUNCTION get_all_seats()
RETURNS TABLE(id INT, flight_id INT, city_fro INT, city_to INT, seat_name VARCHAR, s_class_id INT, price MONEY) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Seats;
END;
$$ LANGUAGE plpgsql;

--2b. Get a specific seat
CREATE FUNCTION get_a_flight_seat(name VARCHAR, f_id INT)
RETURNS TABLE(id INT, flight_id INT, city_fro INT, city_to INT, seat_name VARCHAR, s_class_id INT, price MONEY) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Seats WHERE seat_name = name AND flight_id = f_id;
END;
$$ LANGUAGE plpgsql;

--3. Update Seat Price
CREATE FUNCTION update_seat_price(name VARCHAR, f_id INT, price MONEY)
RETURNS VOID AS $$
BEGIN
  UPDATE Seats
  SET seat_price = price WHERE seat_name = name AND flight_id = f_id;
END;
$$ LANGUAGE plpgsql;
  

--For the Reservations
--1. Add a Reservation
CREATE OR REPLACE FUNCTION add_reservation(p_id INT, s_id INT, f_id INT, city_fro INT, city_to INT, pay_id INT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO Reservations(passenger_id, seat_id, flight_id, city_from_id, city_to_id, payment_id)
  VALUES(p_id, s_id, f_id, city_fro, city_to, pay_id);
END;
$$ LANGUAGE plpgsql;

--2. Get a Reservation
CREATE FUNCTION get_reservation(id INT)
RETURNS TABLE(r_id INT, p_id INT, s_id INT, f_id INT, city_fro INT, city_to INT, pay_id INT) AS $$
BEGIN
  RETURN QUERY SELECT * FROM Reservations WHERE reservation_id = id;
END;
$$ LANGUAGE plpgsql;

--3. Delete a Reservation
CREATE OR REPLACE FUNCTION delete_reservation(id INT)
RETURNS VOID AS $$
BEGIN
  DELETE FROM Reservations WHERE reservation_id = id;
END;
$$ LANGUAGE plpgsql;


--View Reservation Details
CREATE OR REPLACE VIEW view_reservations_details AS
SELECT 
  r.reservation_id,
  p.passenger_name,
  p.passenger_email,
  f.flight_name,
  f.flight_date,
  f.flight_time,
  sf.city_name AS city_from,
  st.city_name AS city_to,
  s.seat_name,
  sc.class_name AS seat_class,
  s.seat_price,
  pay.payment_amount
FROM Reservations r
JOIN Passengers p ON r.passenger_id = p.passenger_id
JOIN Payments pay ON r.payment_id = pay.payment_id
JOIN Seats s ON r.seat_id = s.seat_id 
             AND r.flight_id = s.flight_id 
             AND r.city_from_id = s.city_from_id 
             AND r.city_to_id = s.city_to_id
JOIN Seat_Classes sc ON s.seat_class_id = sc.class_id
JOIN Flights f ON r.flight_id = f.flight_id AND r.city_from_id = f.city_from_id AND r.city_to_id = f.city_to_id
JOIN Cities sf ON f.city_from_id = sf.city_id
JOIN Cities st ON f.city_to_id = st.city_id;

SELECT * 
FROM view_reservations_details;


--View flight details
CREATE OR REPLACE VIEW view_flight_seats AS
SELECT 
  f.flight_id,
  f.flight_name,
  f.flight_date,
  sf.city_name AS from_city,
  st.city_name AS to_city,
  f.eco_class_seats_available,
  f.eco_class_seats_reserved,
  f.business_class_seats_available,
  f.business_class_seats_reserved,
  f.first_class_seats_available,
  f.first_class_seats_reserved
FROM Flights f
JOIN Cities sf ON f.city_from_id = sf.city_id
JOIN Cities st ON f.city_to_id = st.city_id;

SELECT * FROM view_flight_seats;


--View payments Summary
CREATE OR REPLACE VIEW view_payments_summary AS
SELECT 
  pay.payment_id,
  p.passenger_name,
  p.passenger_email,
  pay.payment_amount
FROM Payments pay
JOIN Passengers p ON pay.passenger_id = p.passenger_id;

SELECT * FROM view_payments_summary;


--View seat_details_per_flight
CREATE OR REPLACE VIEW view_seat_details_per_flight AS
SELECT 
  s.seat_id,
  s.seat_name,
  sc.class_name AS seat_class,
  s.seat_price,
  f.flight_name,
  f.flight_date,
  sf.city_name AS from_city,
  st.city_name AS to_city
FROM Seats s
JOIN Seat_Classes sc ON s.seat_class_id = sc.class_id
JOIN Flights f ON s.flight_id = f.flight_id AND s.city_from_id = f.city_from_id AND s.city_to_id = f.city_to_id
JOIN Cities sf ON f.city_from_id = sf.city_id
JOIN Cities st ON f.city_to_id = st.city_id;

SELECT * FROM view_seat_details_per_flight;