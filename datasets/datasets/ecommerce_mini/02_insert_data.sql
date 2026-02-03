-- =====================================================
-- Ecommerce Mini Dataset - Sample Data
-- =====================================================

-- Insert customers
INSERT INTO customers (full_name, email, city, signup_date) VALUES
('Amit Sharma', 'amit@gmail.com', 'Delhi', '2025-01-05'),
('Neha Verma', 'neha@gmail.com', 'Mumbai', '2025-01-12'),
('Rahul Singh', 'rahul@gmail.com', 'Delhi', '2025-02-10'),
('Pooja Mehta', 'pooja@gmail.com', 'Bangalore', '2025-02-15'),
('Karan Gupta', 'karan@gmail.com', 'Mumbai', '2025-03-01');

-- Insert products
INSERT INTO products (product_name, category, price) VALUES
('Wireless Mouse', 'Accessories', 799.00),
('Mechanical Keyboard', 'Accessories', 2499.00),
('Laptop Stand', 'Accessories', 1299.00),
('USB-C Hub', 'Accessories', 1999.00),
('Noise Cancelling Headphones', 'Electronics', 8999.00);

-- Insert orders
INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2025-03-05', 'Delivered'),
(2, '2025-03-06', 'Delivered'),
(3, '2025-03-10', 'Shipped'),
(1, '2025-03-15', 'Returned'),
(4, '2025-03-18', 'Cancelled'),
(5, '2025-03-20', 'Delivered');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 799.00),
(1, 3, 1, 1299.00),
(2, 2, 1, 2499.00),
(3, 4, 2, 1999.00),
(4, 1, 1, 799.00),
(5, 5, 1, 8999.00),
(6, 2, 1, 2499.00),
(6, 3, 1, 1299.00);
