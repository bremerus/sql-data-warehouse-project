# Data catalog

## Overview
This gold layer is built to provide buisness ready data for analysing. It contains dimansional tables and fact tables.
---

### 1. **gold.dim_customers**
  - **Perpuse:** Provides all the usefull reachable data for the customers.
  - **Columns:**
| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_key     | Int           |A unique key for each Customer in this table.                                                  |
| customer_id      | Int           |A unique key starting from (11000, 11001 etc.) we can join gold.fact_sales via this key        |
| customer_number  | Nvarchar(50)  |A unique key it's basicly AW000 + customer_id (eg. AW00011001)                                 |
| first_name       | Nvarchar(50)  |Name of the customer                                                                           |
| last_name        | Nvarchar(50)  |Last name of the customer                                                                      |
| country          | NVARCHAR(50)  | Country of the customer (e.g., 'Greece').                                                     |
| marital_status   | NVARCHAR(50)  | Marital status of the customer (e.g., 'Married', 'Single').                                   |
| gender           | NVARCHAR(50)  | Gender of the customer (e.g., 'Male', 'Female', 'n/a').                                       |
| birthdate        | DATE          | Date of birth of the customer, presented as YYYY-MM-DD (e.g., 1971-10-06).                    |
| create_date      | DATE          | The date and time when the customer record was created in the system                          |                    

---

### 2. **gold.dim_products**
  - **Perpuse:** Provides all the usefull reachable data for products.
  - **Columns:**
| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_key         | INT           | A unique key for each product in this table.         |
| product_id          | INT           | A unique key that allows us join gold.fact_sales via this key            |
|product_number | NVARCHAR(50) | Alphanumeric code used to identify, categorize, and track inventory for the product.|
|product_name | NVARCHAR(50) | Descriptive name including key details like type, color, and size.|
|category_id | NVARCHAR(50) | Unique identifier linking the product to its high-level classification.|
|category | NVARCHAR(50) | Broad classification grouping related items together, such as Bikes or Components.|
|subcategory | NVARCHAR(50) | More specific classification of the product within its main category.|
|maintenance_required | NVARCHAR(50) | Indicates whether the product needs maintenance, usually storing values like Yes or No.|
|cost | INT | Base price or cost of the product in monetary units.|
|product_line | NVARCHAR(50) | Specific series or line the product belongs to, such as Road or Mountain.|
|start_date | DATE | Date when the product became available for sale or use.|

---

### 3. **gold.fact_sales**
  - **Perpuse:** Provides all the usefull reachable data for sales.
  - **Columns:**
| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
|order_number | NVARCHAR(50) | Unique alphanumeric code identifying each sales order.|
|product_key | INT | Key linking the order to the product table.|
|customer_key | INT | Key linking the order to the customer table.|
|order_date | DATE | Date when the order was placed.|
|shipping_date | DATE | Date when the order was shipped to the customer.|
|due_date | DATE | Date when payment for the order was due.|
|sales_amount | INT | Total monetary value of the sale for the line item.|
|quantity | INT | Number of product units ordered for the line item.|
|price | INT | Price per unit of the product for the line item.|
