CREATE PROCEDURE Add_Order (
        @Id_Payment INT, 
        @Payment_Type NVARCHAR(4), 
        @Subsidiary_Name NVARCHAR(50),
        @Product_Name NVARCHAR(40), 
        @Quantity INT
        ) 
AS
BEGIN
    BEGIN TRANSACTION

        --find subsidiary id and check if exists
        DECLARE @id_subsidiary INT
        SET @Id_Subsidiary = (SELECT id_subsidiary FROM Subsidiaries
                    WHERE LOWER(Subsidiaries.subsidiary_name) = LOWER(@Subsidiary_Name) )

        IF (@Id_Subsidiary) IS NULL
            RAISERROR ('Unknown Subsidiary', 10, 1)

        --check if payment exists
        IF (SELECT Id_Payment FROM Payments
                WHERE Payments.Id_Payment = @Id_Payment) IS NULL
        BEGIN
            INSERT INTO Payments(Id_Payment, Payment_Type, Payment_Date, Id_Subsidiary)
            VALUES (@Id_Payment, @Payment_Type, GETDATE(), @Id_Subsidiary)
        END

        --find product id and check if exists
        DECLARE @id_product INT
        SET @id_product = (SELECT id_product FROM Products
                        WHERE LOWER(Products.product_name) = LOWER(@Product_Name))

        IF (@Id_Product) IS NULL
            RAISERROR ('Unknown Product', 10, 1)

        --insert into orders
        DECLARE @last_order_id INT
        SET @Last_Order_Id = (SELECT MAX(Id_Order) FROM Orders) + 1

        INSERT INTO Orders(Id_Order, Id_Product, Quantity, Id_Payment)
        VALUES (@Last_Order_Id, @Id_Product, @Quantity, @Id_Payment);

    COMMIT TRANSACTION
END
GO


EXEC Add_Order 26, 'CASH', 'Botanica', 'cappucino', 1
