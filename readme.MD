sử dụng 2 mục index riêng
bắt buộc
 -- '-> Filter: (pharmacy_inventory.Expiry_Date = DATE\'2025-08-20\')  (cost=0.275 rows=0.25) (actual time=0.0503..0.0523 rows=1 loops=1)\n    -> Index lookup on Pharmacy_Inventory using idx_Drug_Name (Drug_name=\'Panadol Extra\')  (cost=0.275 rows=1) (actual time=0.0481..0.05 rows=1 loops=1)\n'

Chúng ta sẽ thấy chữ filter, có nghĩa là nó sẽ phải lọc ra trước rồi mới tìm kiếm -> Nó tra cuốn 1 để lấy ra một rổ thuốc Panadol. Sau đó, nó phải cặm cụi lật đít từng hộp thuốc trong rổ đó lên để kiểm tra "bằng tay" xem hộp nào có hạn sử dụng đúng yêu cầu.


còn sử dụng composite index cho tên thuốc và hạn sử dụng

-- -> Index lookup on Pharmacy_Inventory using idx_Drug_Name_Expiry_Date (Drug_name='Panadol Extra', Expiry_Date=DATE'2025-08-20')  (cost=0.35 rows=1) (actual time=0.0572..0.059 rows=1 loops=1)


nó chỉ có index nghĩa là nó k cần phải lọc ra điều kiện nữa, sẽ tối ưu hơn, với lại thằng composite sẽ hoạt động như thế này, nó sẽ dựa vào mục lục lướt đến chỗ nào có chữ panadol, xong sau đó nó liếc qua kiếm ngày là 2025-08-20 và sau đó nó sẽ nhảy thẳng đến chỗ của thằng đó và lấy nó ra

Về mặt thời gian đo được (0.050ms vs 0.057ms): Lúc test với bảng dữ liệu siêu nhỏ (vài dòng), thời gian chạy của Composite Index đôi khi có vẻ nhỉnh hơn vài mili-giây so với Index đơn. Lý do là vì "cây" Composite to hơn nên tốn một chút chi phí khởi tạo (cost) vào RAM. Nhưng đây chỉ là "ảo giác vật lý" của dữ liệu nhỏ.

Chốt hạ: Bằng chứng từ EXPLAIN cho thấy Composite Index đã triệt tiêu hoàn toàn bước lọc phụ (Filter). Nếu áp dụng trên Big Data (hàng triệu dòng), Composite Index chắc chắn là người chiến thắng tuyệt đối khi truy vấn bằng mệnh đề AND.


Giải thích hiện tượng Index bị "vô hiệu hóa" khi sử dụng LIKE '%keyword%'.

Trường hợp index mạnh nhất khi sử dụng like là 'chu%', tại vì máy tính biết nó bắt đầu bằng chữ gì nên có thể dựa vào đó mà đến khu vực có những thằng bắt đầu bằng chu để kiếm luôn

%keyword% Vì có dấu % ở đầu, máy tính "bó tay" không biết chữ cái bắt đầu của tên thuốc là gì (có thể là A, có thể là B...). Không biết điểm xuất phát, nó đành vứt cuốn mục lục đi và chạy xuống kho lật từng hộp thuốc lên để xem có chữ "mol" hay không
