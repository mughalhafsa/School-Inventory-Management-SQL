
SET FOREIGN_KEY_CHECKS = 0;
SET autocommit = 0;

-- TABLES

CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    designation VARCHAR(50)
);

CREATE TABLE vendor (
    vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    contact VARCHAR(50)
);

CREATE TABLE category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE subcategory (
    subcategory_id INT AUTO_INCREMENT PRIMARY KEY,
    subcategory_name VARCHAR(50) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE
);

CREATE TABLE location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE sublocation (
    sublocation_id INT AUTO_INCREMENT PRIMARY KEY,
    sublocation_name VARCHAR(50) NOT NULL,
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES location(location_id) ON DELETE CASCADE
);

CREATE TABLE purchase (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT,
    purchase_date DATE NOT NULL,
    invoice_number VARCHAR(50) UNIQUE,
    total_amount DECIMAL(10,2) CHECK (total_amount >= 0),
    received_by INT,
    FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_id) ON DELETE SET NULL,
    FOREIGN KEY (received_by) REFERENCES staff(staff_id) ON DELETE SET NULL
);

CREATE TABLE material (
    material_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category_id INT,
    subcategory_id INT,
    description VARCHAR(200),
    date_added DATE DEFAULT (CURRENT_DATE),
    unit_price DECIMAL(10,2) CHECK (unit_price >= 0),
    purchase_id INT,
    minimum_quantity INT DEFAULT 0 CHECK (minimum_quantity >= 0),
    CONSTRAINT unique_material UNIQUE (item_name, category_id),
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE SET NULL,
    FOREIGN KEY (subcategory_id) REFERENCES subcategory(subcategory_id) ON DELETE SET NULL,
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id) ON DELETE SET NULL
);

CREATE TABLE material_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    material_id INT,
    action_type ENUM('Add','Remove','Move','Consume','Issue','Return') NOT NULL,
    source_location_id INT,
    location_id INT,
    sublocation_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    reason VARCHAR(100),
    log_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (material_id) REFERENCES material(material_id) ON DELETE CASCADE,
    FOREIGN KEY (source_location_id) REFERENCES location(location_id) ON DELETE SET NULL,
    FOREIGN KEY (location_id) REFERENCES location(location_id) ON DELETE SET NULL,
    FOREIGN KEY (sublocation_id) REFERENCES sublocation(sublocation_id) ON DELETE SET NULL
);

CREATE TABLE asset_issuance (
    issuance_id INT AUTO_INCREMENT PRIMARY KEY,
    material_id INT,
    staff_id INT,
    issued_quantity INT NOT NULL CHECK (issued_quantity > 0),
    issue_date DATE DEFAULT (CURRENT_DATE),
    return_date DATE,
    status ENUM('Issued','Returned') DEFAULT 'Issued',
    FOREIGN KEY (material_id) REFERENCES material(material_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- INDEXES
CREATE INDEX idx_material_category ON material(category_id);
CREATE INDEX idx_material_subcategory ON material(subcategory_id);
CREATE INDEX idx_log_material ON material_log(material_id);
CREATE INDEX idx_log_date ON material_log(log_date);
CREATE INDEX idx_log_action ON material_log(action_type);
CREATE INDEX idx_log_location ON material_log(location_id);
CREATE INDEX idx_issuance_staff ON asset_issuance(staff_id);
CREATE INDEX idx_issuance_status ON asset_issuance(status);

-- DATA (correct order — all vendors first, then purchases)

INSERT INTO staff (staff_name, department, designation) VALUES
('Hafsa Mughal','IT','IT Incharge'),
('Ali Ahmed','Admin','Admin Officer'),
('Sara Khan','Accounts','Accountant');

-- All vendors first
INSERT INTO vendor (vendor_name, contact) VALUES
('Al-Fatah Store','051-1234567'),
('Tech Zone','051-9876543'),
('Office Mart','051-5556677'),
('School Supplies Co','051-7778899');

INSERT INTO category (category_name) VALUES
('Electrical'),('IT'),('Furniture & Fixture'),
('Tools'),('Plants & Pots'),('Stationery'),
('Janitorial'),('Kitchen & Grocery');

INSERT INTO subcategory (subcategory_name, category_id) VALUES
('Chair',3),('Table',3),('Spare',1),('Spare',2),
('Indoor Plants',5),('Pens & Markers',6),
('Cleaning Supplies',7),('Grocery Items',8);

INSERT INTO location (location_name) VALUES
('Room 1'),('Room 2'),('Room 3'),('Room 4'),('Room 24');

INSERT INTO sublocation (sublocation_name, location_id) VALUES
('Section 1',1),('Section 2',1),('Section 1',3);

-- All purchases (vendor 4 now exists)
INSERT INTO purchase (vendor_id, purchase_date, invoice_number, total_amount, received_by) VALUES
(1,'2026-01-05','INV-001',15000.00,1),
(2,'2026-02-01','INV-002',45000.00,2),
(3,'2026-03-01','INV-003',5000.00,1),
(4,'2026-07-10','INV-004',12000.00,1);

INSERT INTO material (item_name, category_id, subcategory_id, description, date_added, unit_price, purchase_id, minimum_quantity) VALUES
('Office Chair',3,1,'Revolving chair','2026-01-10',2500.00,1,5),
('Wooden Table',3,2,'Study table','2026-01-12',3000.00,1,3),
('Cable Spare',1,3,'HDMI cables','2026-02-01',500.00,2,10),
('Router Spare',2,4,'WiFi routers','2026-02-05',8000.00,2,2),
('Screwdriver Set',4,NULL,'Tools set','2026-03-01',800.00,3,2),
('Plant Pot (Gamla)',5,5,'Decorative pot','2026-01-01',300.00,1,5),
('Whiteboard',3,2,'Wall mounted board','2026-03-15',4000.00,3,1),
('Extension Cord',1,3,'Power extension','2026-04-01',600.00,2,3),
('Stapler',4,NULL,'Office stapler','2026-05-10',400.00,3,2),
('Marker Pens',6,6,'Whiteboard markers','2026-01-15',150.00,1,20),
('Floor Cleaner',7,7,'Liquid floor cleaner','2026-02-10',200.00,1,10),
('Sugar',8,8,'Kitchen sugar 1kg','2026-03-05',180.00,3,5),
('Whiteboard Eraser',6,6,'Felt eraser','2026-07-10',50.00,4,15),
('Dustbin',7,7,'Plastic dustbin','2026-07-10',300.00,4,3),
('Tea Bags',8,8,'Kitchen tea bags','2026-07-10',250.00,4,10);

INSERT INTO material_log (material_id, action_type, source_location_id, location_id, sublocation_id, quantity, reason, log_date) VALUES
(1,'Add',NULL,1,1,20,NULL,'2026-01-10'),
(1,'Move',1,2,NULL,5,'Moved to Room 2','2026-01-15'),
(2,'Add',NULL,1,2,10,NULL,'2026-01-12'),
(3,'Add',NULL,3,3,15,NULL,'2026-02-01'),
(3,'Consume',NULL,3,3,4,'Used in lab','2026-02-10'),
(4,'Add',NULL,3,3,8,NULL,'2026-02-05'),
(4,'Remove',NULL,3,3,2,'Damaged','2026-02-20'),
(5,'Add',NULL,1,NULL,5,NULL,'2026-03-01'),
(1,'Add',NULL,2,NULL,10,NULL,'2026-06-30'),
(1,'Consume',NULL,2,NULL,3,'Weekly use','2026-07-07'),
(6,'Add',NULL,5,NULL,2,NULL,'2026-01-01'),
(10,'Add',NULL,1,1,50,NULL,'2026-01-15'),
(10,'Consume',NULL,1,1,45,'Used in classrooms','2026-06-30'),
(11,'Add',NULL,1,NULL,20,NULL,'2026-02-10'),
(11,'Consume',NULL,1,NULL,18,'Monthly cleaning','2026-06-30'),
(12,'Add',NULL,1,NULL,10,NULL,'2026-03-05'),
(12,'Consume',NULL,1,NULL,8,'Monthly use','2026-06-30'),
(4,'Issue',NULL,1,NULL,1,'Issued to IT Dept','2026-02-10'),
(4,'Return',NULL,1,NULL,1,'Returned by IT','2026-03-15'),
(13,'Add',NULL,1,1,30,NULL,'2026-07-10'),
(14,'Add',NULL,2,NULL,5,NULL,'2026-07-10'),
(15,'Add',NULL,1,NULL,8,NULL,'2026-07-10'),
(13,'Issue',NULL,1,1,2,'Issued to Admin','2026-07-10'),
(7,'Issue',NULL,1,NULL,1,'Issued to Accounts','2026-07-10'),
(10,'Consume',NULL,1,1,4,'Used in staff room','2026-07-10'),
(11,'Consume',NULL,1,NULL,1,'Monthly cleaning','2026-07-10'),
(15,'Consume',NULL,1,NULL,5,'Kitchen use','2026-07-10'),
(1,'Move',1,3,NULL,3,'Moved for event','2026-07-10');

INSERT INTO asset_issuance (material_id, staff_id, issued_quantity, issue_date, return_date, status) VALUES
(4,1,1,'2026-02-10',NULL,'Issued'),
(2,2,1,'2026-01-15','2026-03-01','Returned'),
(3,3,2,'2026-02-15',NULL,'Issued'),
(13,2,2,'2026-07-10',NULL,'Issued'),
(7,3,1,'2026-07-10',NULL,'Issued');

COMMIT;

-- VIEWS

CREATE VIEW current_stock AS
SELECT 
    m.material_id, m.item_name, c.category_name,
    COALESCE(sc.subcategory_name, '-') AS subcategory,
    m.unit_price, m.minimum_quantity AS threshold,
    SUM(CASE 
        WHEN ml.action_type IN ('Add','Return') THEN ml.quantity
        WHEN ml.action_type IN ('Remove','Consume','Issue') THEN -ml.quantity
        ELSE 0 
    END) AS available_stock,
    SUM(CASE 
        WHEN ml.action_type IN ('Add','Return') THEN ml.quantity
        WHEN ml.action_type IN ('Remove','Consume','Issue') THEN -ml.quantity
        ELSE 0 
    END) * m.unit_price AS stock_value
FROM material m
JOIN category c ON m.category_id = c.category_id
LEFT JOIN subcategory sc ON m.subcategory_id = sc.subcategory_id
LEFT JOIN material_log ml ON m.material_id = ml.material_id
GROUP BY m.material_id, m.item_name, c.category_name,
         sc.subcategory_name, m.unit_price, m.minimum_quantity;

CREATE VIEW category_wise_summary AS
SELECT 
    c.category_name,
    COUNT(DISTINCT m.material_id) AS total_materials,
    COUNT(DISTINCT CASE WHEN m.material_id IN 
        (SELECT DISTINCT material_id FROM material_log) 
        THEN m.material_id END) AS active_materials,
    COUNT(DISTINCT CASE WHEN m.material_id NOT IN 
        (SELECT DISTINCT material_id FROM material_log) 
        THEN m.material_id END) AS inactive_materials,
    COALESCE(SUM(CASE 
        WHEN ml.action_type IN ('Add','Return') THEN ml.quantity
        WHEN ml.action_type IN ('Remove','Consume','Issue') THEN -ml.quantity
        ELSE 0 END),0) AS total_stock
FROM category c
LEFT JOIN material m ON c.category_id = m.category_id
LEFT JOIN material_log ml ON m.material_id = ml.material_id
GROUP BY c.category_name;

CREATE VIEW threshold_alert AS
SELECT 
    m.item_name, c.category_name,
    m.minimum_quantity AS threshold,
    SUM(CASE 
        WHEN ml.action_type IN ('Add','Return') THEN ml.quantity
        WHEN ml.action_type IN ('Remove','Consume','Issue') THEN -ml.quantity
        ELSE 0 
    END) AS current_stock,
    'REORDER REQUIRED' AS alert_status
FROM material m
JOIN category c ON m.category_id = c.category_id
LEFT JOIN material_log ml ON m.material_id = ml.material_id
WHERE c.category_name IN ('Stationery','Janitorial','Kitchen & Grocery')
GROUP BY m.material_id, m.item_name, c.category_name, m.minimum_quantity
HAVING current_stock <= m.minimum_quantity;

CREATE VIEW location_stock AS
SELECT 
    lo.location_name,
    COALESCE(sl.sublocation_name, '-') AS sublocation,
    m.item_name, c.category_name,
    SUM(CASE 
        WHEN ml.action_type = 'Add' AND ml.location_id = lo.location_id THEN ml.quantity
        WHEN ml.action_type IN ('Remove','Consume','Issue') AND ml.location_id = lo.location_id THEN -ml.quantity
        WHEN ml.action_type = 'Move' AND ml.location_id = lo.location_id THEN ml.quantity
        WHEN ml.action_type = 'Move' AND ml.source_location_id = lo.location_id THEN -ml.quantity
        ELSE 0 
    END) AS quantity_at_location
FROM material_log ml
JOIN material m ON ml.material_id = m.material_id
JOIN category c ON m.category_id = c.category_id
JOIN location lo ON ml.location_id = lo.location_id OR ml.source_location_id = lo.location_id
LEFT JOIN sublocation sl ON ml.sublocation_id = sl.sublocation_id
GROUP BY lo.location_name, sl.sublocation_name, m.item_name, c.category_name
HAVING quantity_at_location > 0;

CREATE VIEW unassigned_materials AS
SELECT 
    m.material_id, m.item_name, c.category_name,
    COALESCE(sc.subcategory_name, '-') AS subcategory,
    m.date_added,
    DATEDIFF(CURRENT_DATE, m.date_added) AS days_unassigned
FROM material m
JOIN category c ON m.category_id = c.category_id
LEFT JOIN subcategory sc ON m.subcategory_id = sc.subcategory_id
WHERE m.material_id NOT IN (SELECT DISTINCT material_id FROM material_log);

CREATE VIEW staff_asset_dashboard AS
SELECT 
    s.staff_name, s.department, s.designation,
    m.item_name, c.category_name,
    a.issued_quantity, a.issue_date, a.return_date, a.status
FROM asset_issuance a
JOIN staff s ON a.staff_id = s.staff_id
JOIN material m ON a.material_id = m.material_id
JOIN category c ON m.category_id = c.category_id;

CREATE VIEW purchase_history AS
SELECT 
    p.invoice_number, p.purchase_date, v.vendor_name,
    m.item_name, c.category_name,
    m.unit_price, p.total_amount,
    s.staff_name AS received_by
FROM purchase p
JOIN vendor v ON p.vendor_id = v.vendor_id
JOIN material m ON m.purchase_id = p.purchase_id
JOIN category c ON m.category_id = c.category_id
JOIN staff s ON p.received_by = s.staff_id;

CREATE VIEW weekly_comparison AS
SELECT 
    m.item_name, c.category_name,
    SUM(CASE 
        WHEN ml.log_date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
        AND ml.action_type IN ('Add','Return') THEN ml.quantity
        WHEN ml.log_date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
        AND ml.action_type IN ('Remove','Consume','Issue') THEN -ml.quantity
        ELSE 0 
    END) AS this_week,
    SUM(CASE 
        WHEN ml.log_date >= DATE_SUB(CURRENT_DATE, INTERVAL 14 DAY)
        AND ml.log_date < DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
        AND ml.action_type IN ('Add','Return') THEN ml.quantity
        WHEN ml.log_date >= DATE_SUB(CURRENT_DATE, INTERVAL 14 DAY)
        AND ml.log_date < DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
        AND ml.action_type IN ('Remove','Consume','Issue') THEN -ml.quantity
        ELSE 0 
    END) AS last_week
FROM material_log ml
JOIN material m ON ml.material_id = m.material_id
JOIN category c ON m.category_id = c.category_id
GROUP BY m.item_name, c.category_name;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
