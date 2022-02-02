DROP TABLE IF EXISTS Orders_Tmp

CREATE TABLE Orders_Tmp (
    id_order INT,
    product_name NVARCHAR(50),
    price FLOAT,
    quantity INT,
    total_price FLOAT,
    payment_type NVARCHAR(4),
    work_date DATE,
    cashier NVARCHAR(50),
    address NVARCHAR(50),
    id_payment INT
) ON [PRIMARY];
GO

WITH Orders_Tmpp (id_order, product_name, price, quantity, total_price,
                payment_type, work_date, cashier, address, id_payment)
AS (
        SELECT Orders.id_order, Products.product_name,
        Products.price, Orders.quantity, (Products.price*Orders.quantity) as 'total_price',
        Payments.payment_type, Schedule.work_date,
        Employers.employer_name as cashier, Subsidiaries.adress, Payments.id_payment
    FROM orders
        INNER JOIN Payments ON Orders.id_payment = Payments.id_payment
        INNER JOIN Products ON Orders.id_product = Products.id_product
        INNER JOIN Employers_Schedule Schedule ON Payments.id_subsidiary = Schedule.id_Schedule
        INNER JOIN Employers ON Employers.id_employer = Schedule.id_Employer
        INNER JOIN Subsidiaries ON Schedule.id_Subsidiary = Subsidiaries.id_Subsidiary
    )

    INSERT INTO Orders_Tmp
    SELECT * FROM Orders_Tmpp
GO

SELECT * FROM Orders_Tmp

