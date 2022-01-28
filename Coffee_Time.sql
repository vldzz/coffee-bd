USE master
GO
IF exists(
	SELECT *FROM sys.databases WHERE name='Coffee_Time')
BEGIN
		ALTER DATABASE Coffee_Time SET single_user
		WITH ROLLBACK IMMEDIATE
		DROP DATABASE Coffee_Time
		END
GO
CREATE DATABASE Coffee_Time
GO
USE Coffee_Time
GO


-------------------------------------------
/* Gives all the rights to current user */
------------------------------------------
ALTER AUTHORIZATION
ON DATABASE :: Coffee_Time TO SA
GO


-------------------------------------------
/* Doesn't count inserted rows in tables */
-------------------------------------------
SET NOCOUNT ON;
GO


-----------------------------------------------------[TABLES SECTION]----------------------------------------------------------


CREATE TABLE Subsidiaries(
	id_subsidiary INT PRIMARY KEY,
	subsidiary_name NVARCHAR(50) UNIQUE NOT NULL,
	adress NVARCHAR(50)
)

CREATE TABLE Employers(
	id_employer INT PRIMARY KEY,
	employer_name NVARCHAR(50) NOT NULL,
	sallary FLOAT NOT NULL,
	CHECK (sallary >= 0)
)

CREATE TABLE Employers_Schedule (
    id_schedule INT PRIMARY KEY ,
    id_employer INT FOREIGN KEY REFERENCES Employers(id_Employer),
    id_subsidiary INT FOREIGN KEY REFERENCES Subsidiaries(id_Subsidiary),
    work_date DATE,
	start_work_hour DECIMAL(4,2),
	end_work_hour DECIMAL(4,2)
    UNIQUE (id_employer, id_subsidiary, work_date) 
)

CREATE TABLE Providers(
	id_provider INT PRIMARY KEY,
	provider_name NVARCHAR(25) NOT NULL,
	adress NVARCHAR(25)
)

CREATE TABLE Products(
	id_product INT PRIMARY KEY,
	product_name NVARCHAR(40) UNIQUE NOT NULL,
	price FLOAT NOT NULL,
	id_provider INT FOREIGN KEY REFERENCES Providers(id_provider),
	CHECK (price >= 0 AND price <= 100)
)

CREATE TABLE Payments(
	id_payment INT PRIMARY KEY,
	payment_type NVARCHAR(4) CHECK(payment_type='CASH' OR payment_type='CARD') NOT NULL,
    id_schedule INT FOREIGN KEY REFERENCES Employers_Schedule(id_Schedule)
)

CREATE TABLE Orders(
	id_order INT PRIMARY KEY,
	id_product INT FOREIGN KEY REFERENCES Products(id_product),
	quantity TINYINT DEFAULT 1 NOT NULL,
	id_payment INT FOREIGN KEY REFERENCES payments(id_payment),
	CHECK (quantity > 0)
)
GO


------------------------------------------------------[INSERT SECTION]----------------------------------------------------------


INSERT INTO Subsidiaries VALUES
	(1, 'Centru', 'str.Stefan cel Mare 47'),
	(2, 'Botanica', 'str.Cuza Voda 128'),
    (3, 'Ciocana', 'str.Mircea cel Batran 26')

INSERT INTO Employers (id_employer, employer_name, sallary) VALUES
	(1, 'Bolsoi Valentina', 4800),
	(2, 'Covrig Petru', 5200),
	(3, 'Frunza Sanda', 5000),
	(4, 'Zgardan Razvan', 8000)

INSERT INTO Employers_Schedule (id_schedule, id_employer, id_subsidiary, 
									work_date, start_work_hour, end_work_hour) VALUES
    (1, 1, 1, '2022-01-28', 10, 18),
    (2, 1, 1, '2022-01-29', 8, 16),
    (3, 3, 1, '2022-01-30', 12, 20),
    (4, 3, 1, '2022-01-21', 14, 22),
    (5, 2, 2, '2022-01-28', 12, 20),
    (6, 2, 2, '2022-01-29', 10, 18),
    (7, 4, 2, '2022-01-30', 8, 16),
    (8, 4, 2, '2022-01-31', 10, 18)

INSERT INTO Providers(id_provider, provider_name, adress) VALUES
	(1, 'JDK', 'str 31 august 99'),
	(2, 'CoffeSomeName', 'str. Dacia 43'),
	(3, 'SiropMd', 'str. Stefan cel mare 65'),
	(4, 'Linella', 'str. Titulescu 3')

INSERT INTO Products(id_product, product_name, price, id_provider) VALUES
	(1, 'americano', 17, 2),
	(2, 'cappucino', 22, 1),
	(3, 'mochaccino', 25, 3),
	(4, 'croasant', 15, 2),
	(5, 'ceai negru', 20, 2)

INSERT INTO Payments(id_payment, payment_type, id_schedule) VALUES
	(1, 'CARD', 1),
	(2, 'CASH', 2),
	(3, 'CARD', 2)

INSERT INTO Orders(id_order, id_product, quantity, id_payment) VALUES
	(1, 1, 1, 1),
	(2, 2, 2, 2),
	(3, 1, 5, 2),
	(4, 2, 5, 3),
	(5, 3, 2, 3)
GO


------------------------------------------------------[SELECT SECTION]----------------------------------------------------------


--------------------------------------------
/* A view that shows all the orders done */
-------------------------------------------
CREATE VIEW Show_Orders AS
    SELECT Orders.id_order, Products.product_name,
        Products.price, Orders.quantity, (Products.price*Orders.quantity) as 'total_price',
        Payments.payment_type, Schedule.work_date,
        Employers.employer_name as cashier, Subsidiaries.Adress, Payments.id_payment
    FROM orders
    INNER JOIN Payments ON Orders.id_payment = Payments.id_payment
    INNER JOIN Products ON Orders.id_product = Products.id_product
    INNER JOIN Employers_Schedule Schedule ON Payments.id_Schedule = Schedule.id_Schedule
    INNER JOIN Employers ON Employers.id_employer = Schedule.id_Employer
    INNER JOIN Subsidiaries ON Schedule.id_Subsidiary = Subsidiaries.id_Subsidiary
GO


-----------------------------------------------------
/* A view that shows all orders from current month */
-----------------------------------------------------
CREATE VIEW Orders_Current_Month AS
    SELECT * FROM Show_Orders
    WHERE MONTH(work_date) = MONTH(GETDATE())
GO


--------------------------------------------------------------------
/* A view that shows all employer's schedule, and additional info */
--------------------------------------------------------------------
CREATE VIEW Schedule AS
    SELECT id_schedule, E.employer_name, S.adress, work_date
    FROM Employers_Schedule
    INNER JOIN Employers E ON E.id_Employer = Employers_Schedule.id_Employer
    INNER JOIN Subsidiaries S ON Employers_Schedule.id_Subsidiary = S.id_Subsidiary
GO


------------------------------------
/* A view that shows all payments */
------------------------------------
CREATE VIEW Payment_Statistics AS
    SELECT id_Payment, SUM(total_price) AS 'Paid',
           FORMAT(work_date, 'dd-MM-yyyy') AS 'payment_date',
           Adress, Cashier FROM Show_Orders
    GROUP BY id_Payment, work_date, Adress, Cashier
GO


----------------------------------------------
/* A view that shows all payments for today */
----------------------------------------------
CREATE VIEW Payments_For_Today AS
    SELECT id_Payment, Paid, Payment_Date, Adress, Cashier
    FROM Payment_Statistics
    WHERE DAY(payment_date) = DAY(GETDATE())
GO


------------------------------------------------------
/* A view that shows all payments for current month */
------------------------------------------------------
CREATE VIEW Payments_Current_Month AS
    SELECT id_Payment, Paid, Payment_Date, Adress, Cashier
    FROM Payment_Statistics
    WHERE MONTH(payment_date) = MONTH(GETDATE())
GO



SELECT * FROM Employers_Schedule
ORDER BY work_date 