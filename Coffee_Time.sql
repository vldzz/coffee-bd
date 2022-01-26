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


CREATE TABLE Subsidiaries(
	id_subsidiary INT PRIMARY KEY,
	subsidiary_name NVARCHAR(20) UNIQUE NOT NULL,
	adress NVARCHAR(20) 
)

CREATE TABLE Employers(
	id_employer INT PRIMARY KEY,
	first_name NVARCHAR(20) NOT NULL,
	last_name NVARCHAR(20) NOT NULL,
	sallary FLOAT CHECK (sallary >= 0) NOT NULL,
	id_subsidiary INT FOREIGN KEY REFERENCES Subsidiaries(id_subsidiary)
)

CREATE TABLE Providers(
	id_provider INT PRIMARY KEY,
	provider_name NVARCHAR(20) NOT NULL,
	adress NVARCHAR(20)
)

CREATE TABLE Products(
	id_product INT PRIMARY KEY,
	product_name NVARCHAR(20) UNIQUE NOT NULL,
	price FLOAT NOT NULL,
	id_provider INT FOREIGN KEY REFERENCES Providers(id_provider) 
	CHECK (price >= 0 AND price <= 100)
)

CREATE TABLE Payments(
	id_payment INT PRIMARY KEY,
	quantity TINYINT DEFAULT 1 NOT NULL,
	id_product INT FOREIGN KEY REFERENCES Products(id_product)
	CHECK (quantity > 0)
)

CREATE TABLE Sales(
	id_sale INT PRIMARY KEY, 
	payment_type NVARCHAR(4) CHECK(payment_type='CASH' OR payment_type='CARD') NOT NULL,
	sale_date DATETIME NOT NULL, 
	id_subsiadary INT FOREIGN KEY REFERENCES Subsidiaries(id_subsidiary),
	id_employer INT FOREIGN KEY REFERENCES Employers(id_employer)
)

CREATE TABLE History(
	id_history INT PRIMARY KEY,
	date_payment DATETIME NOT NULL,


)



Select * FROM Sales


