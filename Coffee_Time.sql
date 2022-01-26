USE master
GO
IF EXISTS(SELECT *
          FROM sys.databases
          WHERE name = 'Coffee_Time')
    BEGIN
        ALTER DATABASE coffee_time SET SINGLE_USER WITH ROLLBACK IMMEDIATE
        DROP DATABASE coffee_time
    END
GO
CREATE DATABASE coffee_time
GO
USE coffee_time
GO


CREATE TABLE subsidiaries (
    id_subsidiary   INT PRIMARY KEY,
    subsidiary_name NVARCHAR(20) UNIQUE NOT NULL,
    adress          NVARCHAR(20)
)

CREATE TABLE employers (
    id_employer   INT PRIMARY KEY,
    first_name    NVARCHAR(20)               NOT NULL,
    last_name     NVARCHAR(20)               NOT NULL,
    sallary       FLOAT CHECK (sallary >= 0) NOT NULL,
    id_subsidiary INT FOREIGN KEY REFERENCES subsidiaries (id_subsidiary)
)

CREATE TABLE providers (
    id_provider   INT PRIMARY KEY,
    provider_name NVARCHAR(20) NOT NULL,
    adress        NVARCHAR(20)
)

CREATE TABLE products (
    id_product   INT PRIMARY KEY,
    product_name NVARCHAR(20) UNIQUE NOT NULL,
    price        FLOAT               NOT NULL,
    id_provider  INT FOREIGN KEY REFERENCES providers (id_provider) CHECK (price >= 0 AND price <= 100)
)

CREATE TABLE payments (
    id_payment INT PRIMARY KEY,
    quantity   TINYINT DEFAULT 1 NOT NULL,
    id_product INT FOREIGN KEY REFERENCES products (id_product) CHECK (quantity > 0)
)

CREATE TABLE sales (
    id_sale       INT PRIMARY KEY,
    payment_type  NVARCHAR(4) CHECK (payment_type = 'CASH' OR payment_type = 'CARD') NOT NULL,
    sale_date     DATETIME                                                           NOT NULL,
    id_subsiadary INT FOREIGN KEY REFERENCES subsidiaries (id_subsidiary),
    id_employer   INT FOREIGN KEY REFERENCES employers (id_employer)
)

CREATE TABLE history (
    id_history   INT PRIMARY KEY,
    date_payment DATETIME NOT NULL,


)


SELECT *
FROM sales

