# Trigger tính tổng tiền hóa đơn

## Mục đích

Mỗi hóa đơn tự chọn tối đa một chương trình hợp lệ có số tiền giảm lớn nhất; nếu bằng nhau thì chọn mã nhỏ nhất.

```text
Tổng trước giảm = tổng GiaVe + tổng (SoLuong × DonGia)
TienGiam        = ROUND(Tổng trước giảm × TyLeGiam / 100)
TongTien        = Tổng trước giảm − TienGiam
```

**TinhLaiTongTien(MaHoaDon)**
- Tính tổng tiền vé từ bảng VE.

- Tính tổng tiền sản phẩm từ bảng BAO_GOM.

- Kiểm tra các khuyến mãi hợp lệ: Thứ Hai, HSSV, Thẻ/Ví.

- Dùng `ORDER BY` tiền giảm giảm dần, mã khuyến mãi tăng dần và `LIMIT 1` để chương trình giảm nhiều nhất

- Cập nhật MaKhuyenMai, TienGiam và TongTien trong bảng HOA_DON.

- Hóa đơn rỗng được đặt `MaKhuyenMai = NULL`, `TienGiam = 0`, `TongTien = 0`.

# Dữ liệu minh họa chi tiết

Các bảng dưới đây được đối chiếu với `insert_data.sql`, `test_trigger.sql` và `trigger_tong_tien.sql` hiện tại.

### 1. Insert_Data

#### Bảng giá vé

Đơn vị trong bảng giá: **nghìn đồng**; trong SQL lưu đầy đủ số đồng, ví dụ 65 tương ứng `65000`.

| Định dạng | Thường | VIP | Đôi |
|---|---:|---:|---:|
| 2D | 65 | 85 | 70 |
| 3D | 80 | 100 | 85 |
| IMAX | 150 | 170 | 155 |

VIP = Thường + 20
Đôi = Thường + 5

#### Bảng giá combo và sản phẩm

Đơn vị: **nghìn đồng**. SP001, SP002 là combo; SP003, SP004, SP005 là sản phẩm lẻ.

| Mã sản phẩm | Tên sản phẩm | Giá |
|---|---|---:|
| SP001 | Combo 1 nước và 1 bắp | 78 |
| SP002 | Combo 2 nước và 1 bắp | 98 |
| SP003 | Bắp rang bơ lớn | 58 |
| SP004 | Sting | 25 |
| SP005 | Pepsi lớn | 38 |

#### Khuyến mãi

| Mã KM | Tên KM | Loại | Điều kiện hoặc nội dung |
|---|---|---|---|
| KM001 | Thứ Hai vui vẻ | Giảm giá | Giảm 10% tổng hóa đơn có vé thuộc suất chiếu thứ Hai |
| KM002 | Sinh nhật thành viên | Tặng quà | Thành viên có sinh nhật trong tháng được quà tặng |
| KM003 | Ưu đãi thanh toán thẻ hoặc ví | Giảm giá | Giảm 5% tổng hóa đơn khi thanh toán bằng thẻ ngân hàng hoặc ví điện tử; không bắt buộc có combo |
| KM004 | Ưu đãi HSSV | Giảm giá | Giảm 15% tổng hóa đơn nếu khách đứng tên đã được xác minh HSSV |
| KM005 | Khách hàng mới | Tặng quà | Hóa đơn đầu tiên được kèm quà tặng |

- `DieuKien` của KM001, KM003, KM004 lần lượt là `Thứ Hai`, `Thẻ/Ví`, `HSSV`.
- Các chương trình giảm giá phải còn hiệu lực vào **ngày thanh toán**. Điều kiện thứ Hai xét **ngày chiếu**, không xét ngày mua.
- Mỗi hóa đơn chỉ chọn một chương trình cho tiền giảm lớn nhất; bằng tiền thì chọn mã nhỏ nhất. Không cộng dồn.
- KH003 có `LaHSSV = 1`; các khách mẫu còn lại có `LaHSSV = 0`.
- KM002 và KM005 có `TyLeGiam = NULL`, không tham gia công thức giảm tiền. `SO_HUU` chỉ lưu hai mã tặng quà này.
- SC001 đến SC005 chiếu thứ Ba 01/12/2026; SC006 và SC007 chiếu thứ Hai 07/12/2026.

#### Hóa đơn mẫu

Đơn vị từ phần này trở đi: **đồng**; dấu chấm phân cách hàng nghìn.

| Hóa đơn | Vé và sản phẩm trước giảm | Mã KM | Tiền giảm | TongTien |
|---|---|---|---:|---:|
| HD001 | VE001: 65.000; không có sản phẩm | NULL | 0 | 65.000 |
| HD002 | 1 SP001: 78.000; không có vé | KM003 | 3.900 | 74.100 |
| HD003 | VE002: 100.000 + 1 SP002: 98.000 = 198.000 | KM004 | 29.700 | 168.300 |
| HD004 | VE003: 65.000 + VE004: 85.000 = 150.000 | KM003 | 7.500 | 142.500 |
| HD005 | VE005: 70.000 + 2 SP003: 116.000 + SP004: 25.000 + SP005: 38.000 = 249.000 | KM003 | 12.450 | 236.550 |
| HD006 | VE006: 65.000; không có sản phẩm | KM001 | 6.500 | 58.500 |
| HD007 | VE007: 150.000; không có sản phẩm | KM004 | 22.500 | 127.500 |

Giải thích lựa chọn:

| Hóa đơn | Các phương án hợp lệ | Vì sao chọn mã trong bảng trên? |
|---|---|---|
| HD001 | Không có: tiền mặt, không HSSV, vé thứ Ba | Tiền giảm bằng 0 |
| HD002 | Thẻ/ví: 78.000 × 5% = 3.900 | Chỉ có KM003 hợp lệ |
| HD003 | Thẻ/ví: 9.900; HSSV: 29.700 | Chọn HSSV vì giảm nhiều hơn |
| HD004 | Thẻ/ví: 150.000 × 5% = 7.500 | Chỉ có KM003 hợp lệ |
| HD005 | Thẻ/ví: 249.000 × 5% = 12.450 | Chỉ có KM003 hợp lệ |
| HD006 | Thứ Hai: 6.500; thẻ/ví: 3.250 | Chọn thứ Hai |
| HD007 | Thứ Hai: 15.000; thẻ/ví: 7.500; HSSV: 22.500 | Chọn HSSV |

HD003, HD005, HD006, HD007 có vé online nên `MaNhanVien = NULL`. 

### 2. test_trigger.sql

#### Hóa đơn chuẩn bị

| Hóa đơn | Khách hàng | HSSV | Thanh toán | MaNhanVien | Tổng ban đầu |
|---|---|---|---|---|---:|
| HD900 | KH003 | Có | Ví điện tử | NULL | 0 |
| HD901 | KH001 | Không | Ví điện tử | NULL | 0 |
| HD902 | KH002 | Không | Thẻ ngân hàng | NULL | 0 |

Các câu INSERT hóa đơn không cung cấp `TongTien`, `TienGiam`, `MaKhuyenMai`; giá trị ban đầu lần lượt là 0, 0 và NULL.

#### Vé và sản phẩm được thêm

| Hóa đơn | Vé | Suất/ngày chiếu | Ghế | Giá vé | Sản phẩm | Giá sản phẩm |
|---|---|---|---|---:|---|---:|
| HD900 | VE900 | SC007, thứ Hai 07/12/2026 | R01/P01/A02, IMAX VIP | 170.000 | 1 SP001 | 78.000 |
| HD901 | VE901 | SC006, thứ Hai 07/12/2026 | R01/P01/A02, 2D VIP | 85.000 | 1 SP005 | 38.000 |
| HD902 | VE902 | SC001, thứ Ba 01/12/2026 | R01/P01/A02, 2D VIP | 85.000 | 1 SP003 | 58.000 |

Ba vé dùng cùng mã ghế nhưng **khác suất chiếu**, nên không bán trùng ghế trong cùng suất.

#### Bước trong test, trigger chạy và kết quả

| Bước trong test | Trigger chạy | Kết quả sau thao tác |
|---|---|---|
| 1. INSERT ba hóa đơn | Không kích hoạt sáu trigger tính tiền vì chúng gắn với VE/BAO_GOM | HD900, HD901, HD902 đều có tổng 0, tiền giảm 0, mã NULL |
| 2. INSERT ba vé trong một câu lệnh | THEM_VE chạy cho từng vé; nếu đã tạo trigger nghiệp vụ thì BI_VE_CUNG_SUAT_CHIEU kiểm tra trước khi thêm | HD900: 170.000 − 25.500 = 144.500 (KM004); HD901: 85.000 − 8.500 = 76.500 (KM001); HD902: 85.000 − 4.250 = 80.750 (KM003) |
| 3. INSERT ba dòng BAO_GOM trong một câu lệnh | THEM_SANPHAM chạy cho từng dòng | HD900: 248.000 − 37.200 = 210.800; HD901: 123.000 − 12.300 = 110.700; HD902: 143.000 − 7.150 = 135.850 |
| 4. SELECT kết quả | Không có trigger chạy | Hiển thị một bảng gồm ba hóa đơn như bên dưới |
| 5. ROLLBACK | Hoàn tác giao dịch; không kích hoạt các trigger DELETE | Bỏ toàn bộ dữ liệu demo; các hóa đơn HD001–HD007 giữ nguyên. Result Grid đã hiện vẫn có thể dùng để chụp báo cáo |

#### Bảng kết quả cuối demo

| MaHoaDon | MaKhuyenMai | TongTruocGiam | TienGiam | TongTien |
|---|---|---:|---:|---:|
| HD900 | KM004 | 248.000 | 37.200 | 210.800 |
| HD901 | KM001 | 123.000 | 12.300 | 110.700 |
| HD902 | KM003 | 143.000 | 7.150 | 135.850 |

Với HD900, ba mức giảm là 24.800 (10%), 12.400 (5%) và 37.200 (15%); chọn KM004. Với HD901, chọn 12.300 thay vì 6.150. HD902 chỉ đủ điều kiện thẻ/ví.

Không có lệnh CALL trong demo. INSERT chi tiết tự kích hoạt trigger, trigger gọi `TinhLaiTongTien`, và procedure cập nhật HOA_DON. SELECT chỉ đọc kết quả.


### 3. Sáu trigger 

| Thao tác | Trigger | Hóa đơn được tính lại |
|---|---|---|
| Thêm vé | THEM_VE | NEW.MaHoaDon |
| Sửa vé | SUA_VE | OLD.MaHoaDon; thêm NEW.MaHoaDon nếu chuyển hóa đơn |
| Xóa vé | XOA_VE | OLD.MaHoaDon |
| Thêm sản phẩm | THEM_SANPHAM | NEW.MaHoaDon |
| Sửa số lượng, đơn giá hoặc hóa đơn của sản phẩm | SUA_SANPHAM | OLD.MaHoaDon; thêm NEW.MaHoaDon nếu chuyển hóa đơn |
| Xóa sản phẩm | XOA_SANPHAM | OLD.MaHoaDon |
