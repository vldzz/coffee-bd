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


--------------------------------------------
/* Doesn't  count inserted rows in tables */
--------------------------------------------
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
	first_name NVARCHAR(25) NOT NULL,
	last_name NVARCHAR(25) NOT NULL,
	sallary FLOAT NOT NULL,
	id_subsidiary INT FOREIGN KEY REFERENCES Subsidiaries(id_subsidiary),
	CHECK (sallary >= 0)
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
	payment_date DATETIME NOT NULL, 
	id_subsiadary INT FOREIGN KEY REFERENCES Subsidiaries(id_subsidiary),
	id_employer INT FOREIGN KEY REFERENCES Employers(id_employer)
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
	(2, 'Botanica', 'str.Cuza Voda 128'),
	(3, 'Ciocana', 'str.Mircea cel Batran 26')

INSERT INTO Employers VALUES
	(1, 'Bolsoi', 'Valentina', 4800, 1),
	(2, 'Covrig', 'Petru', 5200, 3),
	(3, 'Frunza', 'Sanda', 5000, 2)


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

INSERT INTO Payments(id_payment, payment_type, payment_date, id_subsiadary, id_employer) VALUES
	(1, 'CARD', GETDATE(), 2, 3),
	(2, 'CASH', GETDATE(), 1, 1),
	(3, 'CARD', GETDATE(), 2, 3)


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
	Payments.payment_type, Payments.payment_date, 
	(Employers.first_name + ' ' + Employers.last_name) as cashier, Payments.id_payment
FROM orders 
INNER JOIN Payments ON Orders.id_payment = Payments.id_payment
INNER JOIN Products ON Orders.id_product = Products.id_product
INNER JOIN Employers ON Employers.id_employer = Payments.id_employer
GO


--------------------------------------------------------
/* View for getting all the orders from current month */
--------------------------------------------------------
CREATE VIEW Orders_Current_Month AS
SELECT * FROM Show_Orders
WHERE MONTH(payment_date) = MONTH(GETDATE())
GO








-- Vizualiare cat si de cati bani a cumparat

-- Tabel pentru adaousuri
--		americano + lapte + sirop vanilie


-- Celiku momentan poate lucra in 2 spoturi in aceiasi zi
-- Tabel payments, check !