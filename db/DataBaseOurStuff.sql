-- ============================================
-- BASIS DATA SISTEM PEMESANAN MENU
-- Fitur: Menu, Keranjang, Checkout, Struk, WA
-- ============================================

-- Buat basis data (opsional)
CREATE DATABASE IF NOT EXISTS sistem_pemesanan CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sistem_pemesanan;

-- ============================================
-- TABEL KATEGORI MENU
-- ============================================
CREATE TABLE kategori (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    slug VARCHAR(120) UNIQUE,
    deskripsi TEXT,
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL PRODUK / MENU
-- ============================================
CREATE TABLE produk (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kategori_id INT,
    nama VARCHAR(150) NOT NULL,
    slug VARCHAR(180) UNIQUE,
    deskripsi TEXT,
    harga DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    stok INT DEFAULT NULL,
    url_gambar VARCHAR(255),
    aktif TINYINT(1) DEFAULT 1,
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (kategori_id) REFERENCES kategori(id) ON DELETE SET NULL,
    INDEX idx_kategori (kategori_id),
    INDEX idx_slug (slug),
    INDEX idx_aktif (aktif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL PELANGGAN
-- ============================================
CREATE TABLE pelanggan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    telepon VARCHAR(32) NOT NULL,
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_telepon (telepon),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL ALAMAT
-- ============================================
CREATE TABLE alamat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pelanggan_id INT NOT NULL,
    label VARCHAR(50),
    jalan TEXT NOT NULL,
    kota VARCHAR(100),
    kode_pos VARCHAR(20),
    catatan TEXT,
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pelanggan_id) REFERENCES pelanggan(id) ON DELETE CASCADE,
    INDEX idx_pelanggan (pelanggan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL KERANJANG
-- ============================================
CREATE TABLE carts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    session_id VARCHAR(128) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_cart_session UNIQUE (customer_id, session_id),
    INDEX idx_session (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL ITEM KERANJANG
-- ============================================
CREATE TABLE cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    qty INT NOT NULL DEFAULT 1,
    price_at_add DECIMAL(10,2) NOT NULL,
    notes VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_cart (cart_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL PESANAN
-- ============================================
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    address_id INT,
    status VARCHAR(30) DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    shipping_fee DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (address_id) REFERENCES addresses(id),
    INDEX idx_order_number (order_number),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL ITEM PESANAN
-- ============================================
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    qty INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    notes VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL PEMBAYARAN
-- ============================================
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    method VARCHAR(50),
    status VARCHAR(30) DEFAULT 'unpaid',
    amount DECIMAL(12,2) NOT NULL,
    paid_at DATETIME NULL,
    metadata JSON NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_order (order_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL STRUK
-- ============================================
CREATE TABLE receipts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    receipt_number VARCHAR(30) NOT NULL UNIQUE,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_receipt_number (receipt_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL LOG WHATSAPP
-- ============================================
CREATE TABLE wa_outbound (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    phone_to VARCHAR(32),
    message TEXT,
    wa_url VARCHAR(255),
    sent_at DATETIME NULL,
    status VARCHAR(30) DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_order (order_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DATA SAMPLE (OPTIONAL)
-- ============================================

-- Sample Kategori
INSERT INTO categories (name, slug, description) VALUES
('Kebab', 'kebab', 'Aneka kebab dengan isian pilihan'),
('Burger', 'burger', 'Burger segar dengan daging berkualitas'),
('Minuman', 'minuman', 'Berbagai minuman segar'),
('Snack', 'snack', 'Camilan pelengkap');

-- Sample Produk
INSERT INTO products (category_id, name, slug, description, price, stock, is_active) VALUES
(1, 'Kebab Ayam', 'kebab-ayam', 'Kebab dengan isian ayam dan sayuran segar', 15000, 50, 1),
(1, 'Kebab Sapi', 'kebab-sapi', 'Kebab dengan isian daging sapi premium', 20000, 30, 1),
(2, 'Burger Beef', 'burger-beef', 'Burger dengan patty daging sapi 100%', 25000, 40, 1),
(2, 'Burger Chicken', 'burger-chicken', 'Burger dengan chicken crispy', 20000, 45, 1),
(3, 'Es Teh Manis', 'es-teh-manis', 'Es teh manis segar', 5000, 100, 1),
(3, 'Jus Jeruk', 'jus-jeruk', 'Jus jeruk segar tanpa gula tambahan', 10000, 50, 1),
(4, 'French Fries', 'french-fries', 'Kentang goreng crispy', 12000, 60, 1);

-- Sample Customer
INSERT INTO customers (name, email, phone) VALUES
('John Doe', 'john@example.com', '628123456789'),
('Jane Smith', 'jane@example.com', '628987654321');

-- Sample Alamat
INSERT INTO addresses (customer_id, label, street, city, postal_code) VALUES
(1, 'Rumah', 'Jl. Merdeka No. 123', 'Jakarta', '12345'),
(2, 'Kantor', 'Jl. Sudirman No. 456', 'Jakarta', '12346');

-- ============================================
-- VIEWS BERGUNA
-- ============================================

-- View untuk melihat keranjang dengan detail produk
CREATE OR REPLACE VIEW v_cart_details AS
SELECT 
    c.id AS cart_id,
    c.customer_id,
    c.session_id,
    ci.id AS cart_item_id,
    ci.product_id,
    p.name AS product_name,
    p.image_url,
    ci.qty,
    ci.price_at_add,
    (ci.qty * ci.price_at_add) AS subtotal,
    ci.notes
FROM carts c
JOIN cart_items ci ON c.id = ci.cart_id
JOIN products p ON ci.product_id = p.id;

-- View untuk melihat detail pesanan lengkap
CREATE OR REPLACE VIEW v_order_details AS
SELECT 
    o.id AS order_id,
    o.order_number,
    o.status,
    o.total_amount,
    o.shipping_fee,
    o.created_at AS order_date,
    c.name AS customer_name,
    c.phone AS customer_phone,
    c.email AS customer_email,
    a.street,
    a.city,
    a.postal_code,
    oi.product_id,
    p.name AS product_name,
    oi.qty,
    oi.unit_price,
    oi.subtotal,
    oi.notes AS item_notes
FROM orders o
JOIN customers c ON o.customer_id = c.id
LEFT JOIN addresses a ON o.address_id = a.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;

-- ============================================
-- STORED PROCEDURE: Generate Order Number
-- ============================================
DELIMITER //

CREATE PROCEDURE sp_generate_order_number(OUT new_order_number VARCHAR(20))
BEGIN
    DECLARE today VARCHAR(8);
    DECLARE seq INT;
    
    SET today = DATE_FORMAT(NOW(), '%Y%m%d');
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(order_number, 10) AS UNSIGNED)), 0) + 1
    INTO seq
    FROM orders
    WHERE order_number LIKE CONCAT('ORD', today, '%');
    
    SET new_order_number = CONCAT('ORD', today, LPAD(seq, 4, '0'));
END //

DELIMITER ;

-- ============================================
-- STORED PROCEDURE: Process Checkout
-- ============================================
DELIMITER //

CREATE PROCEDURE sp_process_checkout(
    IN p_cart_id INT,
    IN p_customer_id INT,
    IN p_address_id INT,
    IN p_shipping_fee DECIMAL(10,2),
    IN p_notes TEXT,
    OUT p_order_id INT,
    OUT p_order_number VARCHAR(20)
)
BEGIN
    DECLARE v_total DECIMAL(12,2);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Generate order number
    CALL sp_generate_order_number(p_order_number);
    
    -- Create order
    INSERT INTO orders (order_number, customer_id, address_id, shipping_fee, notes, total_amount)
    VALUES (p_order_number, p_customer_id, p_address_id, p_shipping_fee, p_notes, 0);
    
    SET p_order_id = LAST_INSERT_ID();
    
    -- Copy cart items to order items
    INSERT INTO order_items (order_id, product_id, qty, unit_price, subtotal, notes)
    SELECT 
        p_order_id,
        ci.product_id,
        ci.qty,
        ci.price_at_add,
        (ci.qty * ci.price_at_add),
        ci.notes
    FROM cart_items ci
    WHERE ci.cart_id = p_cart_id;
    
    -- Calculate total
    SELECT COALESCE(SUM(subtotal), 0) INTO v_total
    FROM order_items
    WHERE order_id = p_order_id;
    
    -- Update order total
    UPDATE orders 
    SET total_amount = v_total + p_shipping_fee
    WHERE id = p_order_id;
    
    -- Clear cart
    DELETE FROM cart_items WHERE cart_id = p_cart_id;
    
    -- Commit transaction
    COMMIT;
END //

DELIMITER ;

-- ============================================
-- FUNCTION: Format Rupiah
-- ============================================
DELIMITER //

CREATE FUNCTION fn_format_rupiah(amount DECIMAL(12,2))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    RETURN CONCAT('Rp ', FORMAT(amount, 0, 'id_ID'));
END //

DELIMITER ;

-- ============================================
-- CONTOH PENGGUNAAN
-- ============================================

-- Contoh 1: Tambah item ke keranjang
/*
-- Buat keranjang baru
INSERT INTO carts (session_id) VALUES ('sess_abc123');
SET @cart_id = LAST_INSERT_ID();

-- Tambah item ke keranjang
INSERT INTO cart_items (cart_id, product_id, qty, price_at_add, notes)
VALUES (@cart_id, 1, 2, 15000, 'Pedas');
*/

-- Contoh 2: Proses checkout
/*
CALL sp_process_checkout(
    @cart_id,           -- cart_id
    1,                  -- customer_id
    1,                  -- address_id
    5000,              -- shipping_fee
    'Kirim sore hari',  -- notes
    @new_order_id,      -- output: order_id
    @new_order_number   -- output: order_number
);

SELECT @new_order_id, @new_order_number;
*/

-- Contoh 3: Generate receipt
/*
INSERT INTO receipts (order_id, receipt_number, content)
VALUES (
    @new_order_id,
    CONCAT('RCP', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(@new_order_id, 4, '0')),
    JSON_OBJECT(
        'order_number', @new_order_number,
        'customer_name', 'John Doe',
        'total', 35000
    )
);
*/

-- Contoh 4: Generate WhatsApp link
/*
INSERT INTO wa_outbound (order_id, phone_to, message, status)
SELECT 
    o.id,
    c.phone,
    CONCAT(
        'Halo, saya ', c.name, '. ',
        'Saya sudah melakukan pesanan dengan nomor *', o.order_number, '*. ',
        'Total: Rp ', FORMAT(o.total_amount, 0), '. ',
        'Alamat: ', a.street, ', ', a.city, '. ',
        'Mohon konfirmasi ya.'
    ),
    'pending'
FROM orders o
JOIN customers c ON o.customer_id = c.id
LEFT JOIN addresses a ON o.address_id = a.id
WHERE o.id = @new_order_id;
*/