-- ============================================
-- BASIS DATA SISTEM PEMESANAN MENU
-- Fitur: Menu, Keranjang, Checkout, Struk, WA
-- ============================================

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
CREATE TABLE keranjang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pelanggan_id INT NULL,
    session_id VARCHAR(128) NULL,
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_cart_session UNIQUE (pelanggan_id, session_id),
    INDEX idx_session (session_id),
    FOREIGN KEY (pelanggan_id) REFERENCES pelanggan(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL ITEM KERANJANG
-- ============================================
CREATE TABLE item_keranjang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    keranjang_id INT NOT NULL,
    produk_id INT NOT NULL,
    qty INT NOT NULL DEFAULT 1,
    harga_saat_tambah DECIMAL(10,2) NOT NULL,
    catatan VARCHAR(255),
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (keranjang_id) REFERENCES keranjang(id) ON DELETE CASCADE,
    FOREIGN KEY (produk_id) REFERENCES produk(id),
    INDEX idx_keranjang (keranjang_id),
    INDEX idx_produk (produk_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL PESANAN
-- ============================================
CREATE TABLE pesanan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nomor_pesanan VARCHAR(20) NOT NULL UNIQUE,
    pelanggan_id INT NOT NULL,
    alamat_id INT,
    status VARCHAR(30) DEFAULT 'pending',
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    ongkir DECIMAL(10,2) DEFAULT 0.00,
    catatan TEXT,
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pelanggan_id) REFERENCES pelanggan(id),
    FOREIGN KEY (alamat_id) REFERENCES alamat(id),
    INDEX idx_nomor (nomor_pesanan),
    INDEX idx_pelanggan (pelanggan_id),
    INDEX idx_status (status),
    INDEX idx_dibuat (dibuat_pada)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL ITEM PESANAN
-- ============================================
CREATE TABLE item_pesanan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pesanan_id INT NOT NULL,
    produk_id INT NOT NULL,
    qty INT NOT NULL,
    harga_satuan DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    catatan VARCHAR(255),
    FOREIGN KEY (pesanan_id) REFERENCES pesanan(id) ON DELETE CASCADE,
    FOREIGN KEY (produk_id) REFERENCES produk(id),
    INDEX idx_pesanan (pesanan_id),
    INDEX idx_produk (produk_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL PEMBAYARAN
-- ============================================
CREATE TABLE pembayaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pesanan_id INT NOT NULL,
    metode VARCHAR(50),
    status VARCHAR(30) DEFAULT 'unpaid',
    jumlah DECIMAL(12,2) NOT NULL,
    dibayar_pada DATETIME NULL,
    metadata JSON NULL,
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pesanan_id) REFERENCES pesanan(id),
    INDEX idx_pesanan (pesanan_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL STRUK
-- ============================================
CREATE TABLE struk (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pesanan_id INT NOT NULL UNIQUE,
    nomor_struk VARCHAR(30) NOT NULL UNIQUE,
    konten TEXT,
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pesanan_id) REFERENCES pesanan(id) ON DELETE CASCADE,
    INDEX idx_nomor_struk (nomor_struk)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABEL LOG WHATSAPP
-- ============================================
CREATE TABLE log_wa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pesanan_id INT,
    telepon_tujuan VARCHAR(32),
    pesan TEXT,
    wa_url VARCHAR(255),
    dikirim_pada DATETIME NULL,
    status VARCHAR(30) DEFAULT 'pending',
    dibuat_pada DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pesanan_id) REFERENCES pesanan(id),
    INDEX idx_pesanan (pesanan_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SAMPLE DATA
-- ============================================

-- Kategori
INSERT INTO kategori (nama, slug, deskripsi) VALUES
('Kebab', 'kebab', 'Aneka kebab dengan isian pilihan'),
('Burger', 'burger', 'Burger segar dengan daging berkualitas'),
('Minuman', 'minuman', 'Berbagai minuman segar'),
('Snack', 'snack', 'Camilan pelengkap');

-- Produk
INSERT INTO produk (kategori_id, nama, slug, deskripsi, harga, stok, aktif) VALUES
(1, 'Kebab Ayam', 'kebab-ayam', 'Kebab dengan isian ayam dan sayuran segar', 15000, 50, 1),
(1, 'Kebab Sapi', 'kebab-sapi', 'Kebab dengan isian daging sapi premium', 20000, 30, 1),
(2, 'Burger Beef', 'burger-beef', 'Burger dengan patty daging sapi 100%', 25000, 40, 1),
(2, 'Burger Chicken', 'burger-chicken', 'Burger dengan chicken crispy', 20000, 45, 1),
(3, 'Es Teh Manis', 'es-teh-manis', 'Es teh manis segar', 5000, 100, 1),
(3, 'Jus Jeruk', 'jus-jeruk', 'Jus jeruk segar tanpa gula tambahan', 10000, 50, 1),
(4, 'French Fries', 'french-fries', 'Kentang goreng crispy', 12000, 60, 1);

-- Pelanggan
INSERT INTO pelanggan (nama, email, telepon) VALUES
('John Doe', 'john@example.com', '628123456789'),
('Jane Smith', 'jane@example.com', '628987654321');

-- Alamat
INSERT INTO alamat (pelanggan_id, label, jalan, kota, kode_pos) VALUES
(1, 'Rumah', 'Jl. Merdeka No. 123', 'Jakarta', '12345'),
(2, 'Kantor', 'Jl. Sudirman No. 456', 'Jakarta', '12346');

-- ============================================
-- VIEW: Detail Keranjang
-- ============================================
CREATE OR REPLACE VIEW v_item_keranjang AS
SELECT 
    k.id AS keranjang_id,
    k.pelanggan_id,
    k.session_id,
    ik.id AS item_keranjang_id,
    ik.produk_id,
    p.nama AS nama_produk,
    p.url_gambar,
    ik.qty,
    ik.harga_saat_tambah,
    (ik.qty * ik.harga_saat_tambah) AS subtotal,
    ik.catatan
FROM keranjang k
JOIN item_keranjang ik ON k.id = ik.keranjang_id
JOIN produk p ON ik.produk_id = p.id;

-- ============================================
-- VIEW: Detail Pesanan
-- ============================================
CREATE OR REPLACE VIEW v_item_pesanan AS
SELECT 
    ps.id AS pesanan_id,
    ps.nomor_pesanan,
    ps.status,
    ps.total,
    ps.ongkir,
    ps.dibuat_pada AS tanggal_pesanan,
    pl.nama AS nama_pelanggan,
    pl.telepon AS telepon_pelanggan,
    a.jalan,
    a.kota,
    a.kode_pos,
    ip.produk_id,
    pr.nama AS nama_produk,
    ip.qty,
    ip.harga_satuan,
    ip.subtotal,
    ip.catatan AS catatan_item
FROM pesanan ps
JOIN pelanggan pl ON ps.pelanggan_id = pl.id
LEFT JOIN alamat a ON ps.alamat_id = a.id
JOIN item_pesanan ip ON ps.id = ip.pesanan_id
JOIN produk pr ON ip.produk_id = pr.id;

-- ============================================
-- STORED PROCEDURE: Generate Nomor Pesanan
-- ============================================
DELIMITER //
CREATE PROCEDURE sp_generate_nomor_pesanan(OUT new_nomor VARCHAR(20))
BEGIN
    DECLARE today VARCHAR(8);
    DECLARE seq INT;

    SET today = DATE_FORMAT(NOW(), '%Y%m%d');

    SELECT COALESCE(MAX(CAST(SUBSTRING(nomor_pesanan, 10) AS UNSIGNED)), 0) + 1
    INTO seq
    FROM pesanan
    WHERE nomor_pesanan LIKE CONCAT('ORD', today, '%');

    SET new_nomor = CONCAT('ORD', today, LPAD(seq, 4, '0'));
END //
DELIMITER ;

-- ============================================
-- STORED PROCEDURE: Process Checkout
-- ============================================
DELIMITER //
CREATE PROCEDURE sp_process_checkout(
    IN p_keranjang_id INT,
    IN p_pelanggan_id INT,
    IN p_alamat_id INT,
    IN p_ongkir DECIMAL(10,2),
    IN p_catatan TEXT,
    OUT p_pesanan_id INT,
    OUT p_nomor_pesanan VARCHAR(20)
)
BEGIN
    DECLARE v_total DECIMAL(12,2);

    START TRANSACTION;

    CALL sp_generate_nomor_pesanan(p_nomor_pesanan);

    INSERT INTO pesanan (nomor_pesanan, pelanggan_id, alamat_id, ongkir, catatan, total)
    VALUES (p_nomor_pesanan, p_pelanggan_id, p_alamat_id, p_ongkir, p_catatan, 0);

    SET p_pesanan_id = LAST_INSERT_ID();

    INSERT INTO item_pesanan (pesanan_id, produk_id, qty, harga_satuan, subtotal, catatan)
    SELECT p_pesanan_id, ik.produk_id, ik.qty, ik.harga_saat_tambah, (ik.qty*ik.harga_saat_tambah), ik.catatan
    FROM item_keranjang ik
    WHERE ik.keranjang_id = p_keranjang_id;

    SELECT COALESCE(SUM(subtotal),0) INTO v_total
    FROM item_pesanan
    WHERE pesanan_id = p_pesanan_id;

    UPDATE pesanan SET total = v_total + p_ongkir WHERE id = p_pesanan_id;

    DELETE FROM item_keranjang WHERE keranjang_id = p_keranjang_id;

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
