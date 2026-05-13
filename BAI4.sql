USE SESSION10;

-- ====================================================
-- 1. KHỞI TẠO BẢNG VÀ CHÈN DỮ LIỆU
-- ====================================================
CREATE TABLE Pharmacy_Inventory (
    Inventory_ID INT AUTO_INCREMENT,
    Drug_name VARCHAR(255) NOT NULL,
    Batch_Number VARCHAR(50),
    Expiry_Date DATE NOT NULL,
    Quantity INT NOT NULL,
    CONSTRAINT PK_Inventory_ID PRIMARY KEY(Inventory_ID),
    CONSTRAINT CK_Quantity CHECK(Quantity >= 0)
);

INSERT INTO Pharmacy_Inventory (Drug_name, Batch_Number, Expiry_Date, Quantity) VALUES 
('Paracetamol 500mg', 'P101', '2026-12-31', 1000),
('Paracetamol 250mg', 'P102', '2026-10-15', 500),
('Panadol Extra', 'P103', '2025-08-20', 2000),
('Amoxicillin Khang Sinh', 'A200', '2024-12-01', 300);

-- ====================================================
-- 2. CHỨNG MINH HIỆU QUẢ CỦA COMPOSITE INDEX 
-- ====================================================

-- Test 1: Khi đánh 2 Index đơn độc lập
CREATE INDEX idx_Drug_Name ON Pharmacy_Inventory(Drug_name);
CREATE INDEX idx_Expiry_Date ON Pharmacy_Inventory(Expiry_Date);

EXPLAIN ANALYZE SELECT * FROM Pharmacy_Inventory WHERE Drug_name = 'Panadol Extra' AND Expiry_Date = '2025-08-20';

/* PHÂN TÍCH TEST 1:
Kết quả EXPLAIN trả về có bước: -> Filter: (Expiry_Date = DATE'2025-08-20')
Điều này chứng tỏ máy tính tra mục lục Tên thuốc (Index lookup), nhưng sau đó phải chạy thêm một thao tác lọc thủ công (Filter) để đối chiếu ngày tháng, rất tốn tài nguyên nếu bảng có hàng triệu dòng.
*/

-- Dọn dẹp Index đơn để chuẩn bị test Index gộp
DROP INDEX idx_Drug_Name ON Pharmacy_Inventory;
DROP INDEX idx_Expiry_Date ON Pharmacy_Inventory;

-- Test 2: Khi đánh 1 Composite Index (Chỉ mục kết hợp)
CREATE INDEX idx_Drug_Name_Expiry_Date ON Pharmacy_Inventory(Drug_name, Expiry_Date);

EXPLAIN ANALYZE SELECT * FROM Pharmacy_Inventory WHERE Drug_name = 'Panadol Extra' AND Expiry_Date = '2025-08-20';

/* PHÂN TÍCH TEST 2:
Kết quả EXPLAIN chỉ có duy nhất: -> Index lookup on Pharmacy_Inventory using idx_Drug_Name_Expiry_Date
Bước 'Filter' thủ công ĐÃ HOÀN TOÀN BIẾN MẤT. Hệ thống chỉ cần tra 1 cuốn mục lục (B-Tree) là lấy ra ngay dòng kết quả chính xác. Chứng tỏ Composite Index tối ưu hơn hẳn trong việc tìm kiếm đa điều kiện (AND).
*/

-- ====================================================
-- 3. PHÂN TÍCH VÀ XỬ LÝ LỖI KHI DÙNG LIKE '%keyword%'
-- ====================================================

/*
A. GIẢI THÍCH HIỆN TƯỢNG INDEX BỊ VÔ HIỆU HÓA:
- Cơ chế của B-Tree Index là sắp xếp dữ liệu từ trái sang phải.
- Nếu tìm kiếm LIKE 'Para%', máy biết chữ cái bắt đầu là 'P' nên dùng Index tìm rất nhanh (Prefix matching).
- Nếu tìm kiếm LIKE '%mol%', máy không biết chữ cái bắt đầu của thuốc là gì, dẫn đến lạc lối. Nó buộc phải bỏ Index và quét toàn bộ bảng (Full Table Scan). Lúc này Index trở nên vô dụng.

B. ĐỀ XUẤT GIẢI PHÁP TỐI ƯU:
- Giải pháp 1 (Tối ưu cấu trúc LIKE): Chặn người dùng đặt dấu % ở đầu chuỗi. Bắt buộc tìm kiếm theo tiền tố (VD: Chỉ cho phép truy vấn LIKE 'Từ_khóa%').
- Giải pháp 2 (Nâng cấp toàn diện): Thay vì dùng Index thông thường, ta chuyển cột Drug_name sang dùng FULLTEXT INDEX. Lúc này có thể dùng cú pháp MATCH(Drug_name) AGAINST('mol') để tìm kiếm ở bất kỳ vị trí nào mà tốc độ vẫn cực kỳ nhanh.
*/