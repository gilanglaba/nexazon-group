DROP TABLE IF EXISTS 
    Warehouse, 
    Inventory_History, 
    Inventory, 
    Rating, 
    Product, 
    Seller, 
    Order_Detail,  
	"order",
    Payment_Transaction, 
    Address, 
    Payment_Detail, 
    Customer 
CASCADE;

CREATE TABLE Customer (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    is_email_verified BOOLEAN DEFAULT FALSE,
    Password VARCHAR(255) NOT NULL,
    Phone_number VARCHAR(20) UNIQUE NOT NULL,
    is_phone_number_verified BOOLEAN DEFAULT FALSE,
    Join_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Payment_Detail (
    Payment_detail_ID SERIAL PRIMARY KEY,
    payment_type VARCHAR(50) NOT NULL,
    Card_number VARCHAR(20) UNIQUE NOT NULL,
    Expired_date_month INT CHECK (Expired_date_month BETWEEN 1 AND 12),
    Expired_date_year INT CHECK (Expired_date_year >= EXTRACT(YEAR FROM CURRENT_DATE)),
    CVV INT CHECK (CVV BETWEEN 100 AND 999),
    is_main_method BOOLEAN DEFAULT FALSE,
    Customer_ID INT,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) 
);

CREATE TABLE Address (
    Address_1 VARCHAR(255) NOT NULL,
    Address_2 VARCHAR(255),
    City VARCHAR(100) NOT NULL,
    Zip_code VARCHAR(20) NOT NULL,
    State VARCHAR(100) NOT NULL,
    is_main_address BOOLEAN DEFAULT FALSE,
    Customer_ID INT,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) 
);

CREATE TABLE Payment_Transaction (
    Payment_Transaction_ID SERIAL PRIMARY KEY,
    Payment_status VARCHAR(50) CHECK (Payment_status IN ('Completed','Pending','Refunded','Failed')),
    Payment_amount DECIMAL(10,2) NOT NULL,
    Transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Payment_detail_ID INT,
    FOREIGN KEY (Payment_detail_ID) REFERENCES Payment_Detail(Payment_detail_ID) 
);

CREATE TABLE "order" (
    Order_ID SERIAL PRIMARY KEY,
    Total_item INT NOT NULL,
    Total_price DECIMAL(10,2) NOT NULL,
    Order_status VARCHAR(50) CHECK (Order_status IN ('Pending Payment','Processing','Shipped','Delivered','Returned','Cancelled')),
    Order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Customer_ID INT,
    Payment_Transaction_ID INT,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ,
    FOREIGN KEY (Payment_Transaction_ID) REFERENCES Payment_Transaction(Payment_Transaction_ID) 
);

	
CREATE TABLE Seller (
    Seller_ID SERIAL PRIMARY KEY,
    Seller_name VARCHAR(255) NOT NULL,
    Seller_category VARCHAR(255) NOT NULL,
    Join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Email VARCHAR(255) UNIQUE NOT NULL,
    is_email_verified BOOLEAN DEFAULT FALSE,
    Password VARCHAR(255) NOT NULL,
    Phone_number VARCHAR(20) UNIQUE NOT NULL,
    is_phone_number_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    Address_1 VARCHAR(255) NOT NULL,
    Address_2 VARCHAR(255),
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    Zip_code VARCHAR(20) NOT NULL
);

CREATE TABLE Product (
    Product_ID SERIAL PRIMARY KEY,
    Product_name VARCHAR(255) NOT NULL,
    Category VARCHAR(255) NOT NULL,
    Original_price DECIMAL(10,2) NOT NULL CHECK (Original_price >= 0),
    Final_price DECIMAL(10,2) NOT NULL CHECK (Final_price >= 0),
    Is_active BOOLEAN DEFAULT TRUE,
    Is_deleted BOOLEAN DEFAULT FALSE,
    Rating NUMERIC(2,1) CHECK (Rating BETWEEN 0 AND 5),
    Total_sold INT DEFAULT 0,
    Seller_ID INT,
    FOREIGN KEY (Seller_ID) REFERENCES Seller(Seller_ID) 
);


CREATE TABLE Order_Detail (
    Order_detail_ID SERIAL PRIMARY KEY,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Order_ID INT,
	Product_ID INT,
    FOREIGN KEY (Order_ID) REFERENCES "order"(Order_ID) ,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID) 
);

CREATE TABLE Warehouse (
    Warehouse_ID SERIAL PRIMARY KEY,
    Address_1 VARCHAR(255) NOT NULL,
    Address_2 VARCHAR(255),
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    Zip_code VARCHAR(20) NOT NULL,
	Seller_ID INT,
    FOREIGN KEY (Seller_ID) REFERENCES Seller(Seller_ID) 
);

CREATE TABLE Rating (
    Rating NUMERIC(2,1) CHECK (Rating BETWEEN 0 AND 5),
    Order_detail_ID INT,
    FOREIGN KEY (Order_detail_ID) REFERENCES Order_Detail(Order_detail_ID) 
);


CREATE TABLE Inventory (
    Inventory_ID SERIAL PRIMARY KEY,
    Current_quantity INT NOT NULL CHECK (Current_quantity >= 0),
    Product_ID INT,
	Warehouse_ID INT,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID) ,
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouse(Warehouse_ID) 
);

CREATE TABLE Inventory_History (
    Quantity_change INT NOT NULL,
    Reason TEXT NOT NULL,
    Update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Inventory_ID INT,
    FOREIGN KEY (Inventory_ID) REFERENCES Inventory(Inventory_ID) 
);
