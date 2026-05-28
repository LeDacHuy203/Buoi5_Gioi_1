-- =========================================
-- TẠO DATABASE
-- =========================================
CREATE DATABASE sales_practice_gioi;
-- =========================================
-- TẠO SCHEMA
-- =========================================
CREATE SCHEMA session05;

-- Chuyển sang schema session05
SET search_path TO session05;

-- =========================================
-- TẠO BẢNG CUSTOMERS
-- =========================================
CREATE TABLE customers
(
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city          VARCHAR(100) NOT NULL
);

-- =========================================
-- TẠO BẢNG ORDERS
-- =========================================
CREATE TABLE orders
(
    order_id    INT PRIMARY KEY,
    customer_id INT,
    order_date  DATE           NOT NULL,
    total_price NUMERIC(12, 2) NOT NULL CHECK (total_price >= 0),
    FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)

);

-- =========================================
-- TẠO BẢNG ORDER_ITEMS
-- =========================================
CREATE TABLE order_items
(
    item_id    SERIAL PRIMARY KEY,
    order_id   INT            NOT NULL,
    product_id INT            NOT NULL,
    quantity   INT            NOT NULL CHECK (quantity > 0),
    price      NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    FOREIGN KEY (order_id)
        REFERENCES orders (order_id)

);

-- =========================================
-- THÊM DỮ LIỆU CUSTOMERS
-- =========================================
INSERT INTO customers (customer_name, city)
VALUES ('Nguyen Van A', 'Hà Nội'),
       ('Tran Thi B', 'Đà Nẵng'),
       ('Le Van C', 'Hồ Chí Minh'),
       ('Pham Thi D', 'Hà Nội');

-- =========================================
-- THÊM DỮ LIỆU ORDERS
-- =========================================
INSERT INTO orders (order_id, customer_id, order_date, total_price)
VALUES (101, 1, '2024-12-20', 3000),
       (102, 2, '2025-01-05', 1500),
       (103, 1, '2025-02-10', 2500),
       (104, 3, '2025-02-15', 4000),
       (105, 4, '2025-03-01', 800);

-- =========================================
-- THÊM DỮ LIỆU ORDER_ITEMS
-- =========================================
INSERT INTO order_items (item_id, order_id, product_id, quantity, price)
VALUES (1, 101, 1, 2, 1500),
       (2, 102, 2, 1, 1500),
       (3, 103, 3, 5, 500),
       (4, 104, 2, 4, 1000);

-- =========================================
-- KIỂM TRA DỮ LIỆU
-- =========================================
SELECT *
FROM customers;

SELECT *
FROM orders;

SELECT *
FROM order_items;

-- 1.Viết truy vấn hiển thị tổng doanh thu và tổng số đơn hàng của mỗi khách hàng:
-- Chỉ hiển thị khách hàng có tổng doanh thu > 2000
-- Dùng ALIAS: total_revenue và order_count
SELECT c.customer_name,
       sum(o.total_price) as total_revenue,
       count(o.order_id)  as order_count
FROM customers c
         JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING sum(o.total_price) > 2000;
-- 2. Viết truy vấn con (Subquery) để tìm doanh thu trung bình của tất cả khách hàng
-- Sau đó hiển thị những khách hàng có doanh thu lớn hơn mức trung bình đó
SELECT c.customer_id, c.customer_name, c.city, sum(o.total_price)
FROM orders o
         JOIN customers c on o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
HAVING sum(o.total_price) > (SELECT avg(customer_revenue)
                             FROM (SELECT sum(o.total_price) as customer_revenue
                                   FROM orders o
                                   GROUP BY customer_id) as avg_table)
;
-- 3.Dùng HAVING + GROUP BY để lọc ra thành phố có tổng doanh thu cao nhất
SELECT c.city,
       sum(o.total_price) as total_revenue
FROM customers c
         JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
HAVING sum(o.total_price) = (SELECT sum(o.total_price) as total_revenue
                             FROM customers c
                                      JOIN orders o ON c.customer_id = o.customer_id
                             GROUP BY c.city
                             order by sum(o.total_price) DESC
                             LIMIT 1);
-- 4. (Mở rộng) Hãy dùng INNER JOIN giữa customers, orders, order_items để hiển thị chi tiết:
-- Tên khách hàng, tên thành phố, tổng sản phẩm đã mua, tổng chi tiêu

SELECT c.customer_name, c.city, count(o.order_id), sum(o.total_price)
FROM customers c
         JOIN orders o ON o.customer_id = c.customer_id
         JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id;

