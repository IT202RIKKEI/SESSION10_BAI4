
USE SESSION10;

CREATE TABLE Pharmacy_Inventory (
	Inventory_ID INT AUTO_INCREMENT,
    Drug_name VARCHAR(255) NOT NULL,
    Batch_Number VARCHAR(50),
    Expiry_Date DATE NOT NULL,

    Quantity INT NOT NULL,
    CONSTRAINT PK_Inventory_ID PRIMARY KEY(Inventory_ID),
    CONSTRAINT CK_Quantity CHECK(Quantity >= 0)
);

-- chèn dữ liệu
INSERT INTO Pharmacy_Inventory (Drug_name, Batch_Number, Expiry_Date, Quantity) VALUES 
('Paracetamol 500mg', 'P101', '2026-12-31', 1000),
('Paracetamol 250mg', 'P102', '2026-10-15', 500),
('Panadol Extra', 'P103', '2025-08-20', 2000),
('Amoxicillin Khang Sinh', 'A200', '2024-12-01', 300);

-- INDEX CHO CẢ 2 CỘT RIÊNG BIỆT
CREATE INDEX idx_Drug_Name ON Pharmacy_Inventory(Drug_name);
CREATE INDEX idx_Expiry_Date ON Pharmacy_Inventory(Expiry_Date);

-- XÓA 
DROP INDEX idx_Expiry_Date  ON Pharmacy_Inventory;

EXPLAIN ANALYZE
SELECT * FROM Pharmacy_Inventory WHERE Drug_name = 'Panadol Extra' AND Expiry_Date = '2025-08-20';


-- cái này 2 cái riêng biệt
 -- '-> Filter: (pharmacy_inventory.Expiry_Date = DATE\'2025-08-20\')  (cost=0.275 rows=0.25) (actual time=0.0503..0.0523 rows=1 loops=1)\n    -> Index lookup on Pharmacy_Inventory using idx_Drug_Name (Drug_name=\'Panadol Extra\')  (cost=0.275 rows=1) (actual time=0.0481..0.05 rows=1 loops=1)\n'

-- INDEX COMPOSITE KẾT HỢP CẢ 2 LẠI
CREATE INDEX  idx_Drug_Name_Expiry_Date ON Pharmacy_Inventory(Drug_name, Expiry_Date);

-- -> Index lookup on Pharmacy_Inventory using idx_Drug_Name_Expiry_Date (Drug_name='Panadol Extra', Expiry_Date=DATE'2025-08-20')  (cost=0.35 rows=1) (actual time=0.0572..0.059 rows=1 loops=1)
 
