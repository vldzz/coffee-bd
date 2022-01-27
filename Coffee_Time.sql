SET DATEFORMAT dmy
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
	name NVARCHAR(50) NOT NULL,
	sallary FLOAT NOT NULL,
-- 	id_subsidiary INT FOREIGN KEY REFERENCES Subsidiaries(id_subsidiary),
	CHECK (sallary >= 0)
)

CREATE TABLE Employers_Schedule (
    id_Schedule INT PRIMARY KEY ,
    Id_Employer INT FOREIGN KEY REFERENCES Employers(Id_Employer),
    Id_Subsidiary INT FOREIGN KEY REFERENCES Subsidiaries(Id_Subsidiary),
    Date_ DATE,

    UNIQUE (Id_Employer, Id_Subsidiary, Date_)
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
-- 	payment_date DATETIME NOT NULL,
-- 	id_subsiadary INT FOREIGN KEY REFERENCES Subsidiaries(id_subsidiary)
-- 	id_employer INT FOREIGN KEY REFERENCES Employers(id_employer)
    id_schedule INT FOREIGN KEY REFERENCES Employers_Schedule(Id_Schedule)
)

CREATE TABLE Orders(
	id_order INT PRIMARY KEY,
	id_product INT FOREIGN KEY REFERENCES Products(id_product),
	quantity TINYINT DEFAULT 1 NOT NULL,
	id_payment INT FOREIGN KEY REFERENCES payments(id_payment),
	CHECK (quantity > 0)
)

------------------------------------------------------[INSERT SECTION]----------------------------------------------------------

INSERT INTO Subsidiaries VALUES
	(1, 'Centru', 'str.Stefan cel Mare 47'),
	(2, 'Botanica', 'str.Cuza Voda 128')
  (3, 'Ciocana', 'str.Mircea cel Batran 26')

INSERT INTO Employers (id_employer, name, sallary) VALUES
	(1, 'Bolsoi Valentina', 4800),
	(2, 'Covrig Petru', 5200),
	(3, 'Frunza Sanda', 5000),
	(4, 'Zgardan Razvan', 8000)

INSERT INTO Employers_Schedule (Id_Schedule, id_employer, id_subsidiary, date_) VALUES
    (1, 1, 1, '2022-01-28'),
    (2, 1, 1, '2022-01-29'),
    (3, 3, 1, '2022-01-30'),
    (4, 3, 1, '2022-01-21'),
    (5, 2, 2, '2022-01-28'),
    (6, 2, 2, '2022-01-29'),
    (7, 4, 2, '2022-01-30'),
    (8, 4, 2, '2022-01-31')


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

INSERT INTO Payments(id_payment, payment_type, Id_Schedule) VALUES
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
        Payments.payment_type, Schedule.Date_,
        Employers.Name as cashier, Subsidiaries.Adress, Payments.id_payment
    FROM orders
    INNER JOIN Payments ON Orders.id_payment = Payments.id_payment
    INNER JOIN Products ON Orders.id_product = Products.id_product
    INNER JOIN Employers_Schedule Schedule ON Payments.Id_Schedule = Schedule.Id_Schedule
    INNER JOIN Employers ON Employers.id_employer = Schedule.Id_Employer
    INNER JOIN Subsidiaries ON Schedule.Id_Subsidiary = Subsidiaries.Id_Subsidiary


GO
-----------------------------------------------------
/* A view that shows all orders from current month */
-----------------------------------------------------
CREATE VIEW Orders_Current_Month AS
    SELECT * FROM Show_Orders
    WHERE MONTH(Date_) = MONTH(GETDATE())
GO
--------------------------------------------------------------------
/* A view that shows all employer's schedule, and additional info */
--------------------------------------------------------------------
CREATE VIEW Schedule AS
    SELECT id_schedule, E.Name, S.Adress, date_
    FROM Employers_Schedule
    INNER JOIN Employers E ON E.Id_Employer = Employers_Schedule.Id_Employer
    INNER JOIN Subsidiaries S ON Employers_Schedule.Id_Subsidiary = S.Id_Subsidiary
GO


------------------------------------
/* A view that shows all payments */
------------------------------------
CREATE VIEW Payment_Statistics AS
    SELECT Id_Payment, SUM(total_price) AS 'Paid',
           FORMAT(Date_, 'dd-MM-yyyy') AS 'payment_date',
           Adress, Cashier FROM Show_Orders
    GROUP BY Id_Payment, Date_, Adress, Cashier
GO

----------------------------------------------
/* A view that shows all payments for today */
----------------------------------------------
CREATE VIEW Payments_For_Today AS
    SELECT Id_Payment, Paid, Payment_Date, Adress, Cashier
    FROM Payment_Statistics
    WHERE DAY(payment_date) = DAY(GETDATE())
GO

------------------------------------------------------
/* A view that shows all payments for current month */
------------------------------------------------------
CREATE VIEW Payments_Current_Month AS
    SELECT Id_Payment, Paid, Payment_Date, Adress, Cashier
    FROM Payment_Statistics
    WHERE MONTH(payment_date) = MONTH(GETDATE())
GO

-- Tabel pentru adaousuri
--		americano + lapte + sirop vanilie


-- Celiku momentan poate lucra in 2 spoturi in aceiasi zi
-- Tabel payments, check !


SELECT * FROM Payments_Current_Month