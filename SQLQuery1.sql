DROP DATABASE IF EXISTS Coffee_Time
GO

CREATE DATABASE Coffee_Time
GO

CREATE TABLE Branches(
	id_branch INT PRIMARY KEY,
	branch_name NVARCHAR(20) UNIQUE,
	adress NVARCHAR(20) UNIQUE
)

CREATE TABLE Employers(
	id_employer INT PRIMARY KEY,
	first_name NVARCHAR(20),
	last_name NVARCHAR(20),
	sallary FLOAT CHECK (sallary >= 0),
	id_branch INT FOREIGN KEY REFERENCES Branches(id_branch)
)

CREATE TABLE Providers(
	id_provider INT PRIMARY KEY,
	provider_name NVARCHAR(20),
	adress NVARCHAR(20)
)

CREATE TABLE Products(
	id_product INT PRIMARY KEY,
	product_name NVARCHAR(20) UNIQUE,
	price FLOAT CHECK (price >= 0 AND price <= 100),
	id_provider INT FOREIGN KEY REFERENCES Providers(id_provider) 
)

CREATE TABLE Sales(
	id_sale INT PRIMARY KEY, 
	total_price float,
	id_employer INT FOREIGN KEY REFERENCES Employers(id_employer)
)

