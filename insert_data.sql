SET NAMES utf8mb4;
USE myCinemaDB;

START TRANSACTION;

-- 1. RAP_PHIM
INSERT INTO RAP_PHIM (MaRap, TenRap, DiaChi, Hotline, MaQuanLy) VALUES
('R01', 'Beta Cinemas Ung Văn Khiêm', '26 Ung Văn Khiêm, Phường Thạnh Mỹ Tây, TPHCM', '0969874873', NULL),
('R02', 'Beta Cinemas Trần Quang Khải', '62 Trần Quang Khải, Phường Tân Định, TPHCM', '02873009079', NULL),
('R03', 'Beta Cinemas Nowzone', '235 Nguyễn Văn Cừ, Phường Cầu Ông Lãnh, TPHCM', '1900636807', NULL),
('R04', 'Beta Cinemas Quang Trung', '645 Quang Trung, Phường Thông Tây Hội, TPHCM', '0706075509', NULL),
('R05', 'Beta Cinemas Hồ Tràm', 'The Grand Hồ Tràm Strip, Xã Hồ Tràm, TPHCM', '02543788601', NULL);

-- 2. THE_LOAI
INSERT INTO THE_LOAI (MaTheLoai, TenTheLoai) VALUES
('TL01', 'Hành động'),
('TL02', 'Hài hước'),
('TL03', 'Tâm lý'),
('TL04', 'Kinh dị'),
('TL05', 'Tình cảm'),
('TL06', 'Hoạt hình');

-- 3. SAN_PHAM
INSERT INTO SAN_PHAM (MaSanPham, TenSanPham, GiaBan, SoLuongTon) VALUES
('SP001', 'Combo 1 nước và 1 bắp', 78000, 100),
('SP002', 'Combo 2 nước và 1 bắp', 98000, 120),
('SP003', 'Bắp rang bơ lớn', 58000, 80),
('SP004', 'Sting', 25000, 60),
('SP005', 'Pepsi lớn', 38000, 150);

-- 4. KHUYEN_MAI
INSERT INTO KHUYEN_MAI
    (MaKhuyenMai, TenChuongTrinh, NgayBatDau, NgayKetThuc, LoaiKhuyenMai, DieuKien)
VALUES
('KM001', 'Thứ Hai vui vẻ', '2026-01-01', '2026-12-31', 'Giảm giá vé', 'Áp dụng cho suất chiếu thứ Hai'),
('KM002', 'Sinh nhật thành viên', '2026-01-01', '2026-12-31', 'Quà tặng', 'Thành viên có sinh nhật trong tháng'),
('KM003', 'Combo cuối tuần', '2026-06-01', '2026-12-31', 'Giảm giá combo', 'Mua combo vào thứ Bảy hoặc Chủ Nhật'),
('KM004', 'Ưu đãi HSSV', '2026-08-01', '2027-05-31', 'Giảm giá vé', 'Xuất trình thẻ học sinh còn hiệu lực'),
('KM005', 'Khách hàng mới', '2026-01-01', '2026-12-31', 'Mã giảm giá', 'Áp dụng cho hóa đơn đầu tiên');

-- 5. KHACH_HANG
INSERT INTO KHACH_HANG
    (MaKhachHang, Ten, GioiTinh, NgaySinh, SoDienThoai, Email)
VALUES
('KH001', 'Nguyễn Minh Anh', 'Nữ', '2001-03-15', '0901000001', 'minhanh01@gmail.com'),
('KH002', 'Trần Quốc Bảo', 'Nam', '1998-07-22', '0901000002', 'quocbao02@gmail.com'),
('KH003', 'Lê Hoàng Gia Hân', 'Nữ', '2003-11-09', '0901000003', 'giahan03@gmail.com'),
('KH004', 'Phạm Đức Long', 'Nam', '1995-05-30', '0901000004', 'duclong04@gmail.com'),
('KH005', 'Võ Khánh Linh', 'Khác', '2000-12-12', '0901000005', 'khanhlinh05@gmail.com');

-- 6. CA_LAM_VIEC
INSERT INTO CA_LAM_VIEC (MaCa, TenCa, GioBatDau, GioKetThuc) VALUES
('CA01', 'Ca sáng', '08:00:00', '12:00:00'),
('CA02', 'Ca trưa', '12:00:00', '16:00:00'),
('CA03', 'Ca chiều', '16:00:00', '20:00:00'),
('CA04', 'Ca tối', '20:00:00', '23:59:00'),
('CA05', 'Full-time', '09:00:00', '17:00:00');

-- 7. TAI_KHOAN
-- TK001-TK010 cho nhan vien; TK011-TK015 cho khach hang.
INSERT INTO TAI_KHOAN (MaTaiKhoan, TenDangNhap, MatKhau, TrangThai) VALUES
('TK001', 'quanly_rap01', 'Demo@2026_R01', 'Hoạt động'),
('TK002', 'quanly_rap02', 'Demo@2026_R02', 'Hoạt động'),
('TK003', 'quanly_rap03', 'Demo@2026_R03', 'Hoạt động'),
('TK004', 'quanly_rap04', 'Demo@2026_R04', 'Hoạt động'),
('TK005', 'quanly_rap05', 'Demo@2026_R05', 'Hoạt động'),
('TK006', 'vanhanh_rap01', 'Demo@2026_V01', 'Hoạt động'),
('TK007', 'vanhanh_rap02', 'Demo@2026_V02', 'Hoạt động'),
('TK008', 'vanhanh_rap03', 'Demo@2026_V03', 'Hoạt động'),
('TK009', 'vanhanh_rap04', 'Demo@2026_V04', 'Hoạt động'),
('TK010', 'vanhanh_rap05', 'Demo@2026_V05', 'Hoạt động'),
('TK011', 'khachhang_001', 'Khach@2026_01', 'Hoạt động'),
('TK012', 'khachhang_002', 'Khach@2026_02', 'Hoạt động'),
('TK013', 'khachhang_003', 'Khach@2026_03', 'Hoạt động'),
('TK014', 'khachhang_004', 'Khach@2026_04', 'Hoạt động'),
('TK015', 'khachhang_005', 'Khach@2026_05', 'Hoạt động');

-- 8. PHONG_CHIEU
INSERT INTO PHONG_CHIEU (MaRap, MaPhong, SoGhe) VALUES
('R01', 'P01', 3),
('R02', 'P02', 3),
('R03', 'P03', 3),
('R04', 'P04', 3),
('R05', 'P05', 3);

-- 9. GHE
INSERT INTO GHE (MaRap, MaPhong, MaGhe, LoaiGhe) VALUES
('R01', 'P01', 'A01', 'Thường'),
('R01', 'P01', 'A02', 'VIP'),
('R01', 'P01', 'A03', 'Đôi'),
('R02', 'P02', 'B01', 'Thường'),
('R02', 'P02', 'B02', 'VIP'),
('R02', 'P02', 'B03', 'Đôi'),
('R03', 'P03', 'C01', 'Thường'),
('R03', 'P03', 'C02', 'VIP'),
('R03', 'P03', 'C03', 'Đôi'),
('R04', 'P04', 'D01', 'Thường'),
('R04', 'P04', 'D02', 'VIP'),
('R04', 'P04', 'D03', 'Đôi'),
('R05', 'P05', 'E01', 'Thường'),
('R05', 'P05', 'E02', 'VIP'),
('R05', 'P05', 'E03', 'Đôi');

-- 10. GHE_THUONG
INSERT INTO GHE_THUONG (MaRap, MaPhong, MaGhe) VALUES
('R01', 'P01', 'A01'),
('R02', 'P02', 'B01'),
('R03', 'P03', 'C01'),
('R04', 'P04', 'D01'),
('R05', 'P05', 'E01');

-- 11. GHE_DOI
INSERT INTO GHE_DOI (MaRap, MaPhong, MaGhe, TayVin) VALUES
('R01', 'P01', 'A03', 'Tay vịn có thể nâng'),
('R02', 'P02', 'B03', 'Tay vịn có thể nâng'),
('R03', 'P03', 'C03', 'Tay vịn có thể nâng'),
('R04', 'P04', 'D03', 'Tay vịn có thể nâng'),
('R05', 'P05', 'E03', 'Tay vịn có thể nâng');

-- 12. GHE_VIP
INSERT INTO GHE_VIP (MaRap, MaPhong, MaGhe, NgaLung) VALUES
('R01', 'P01', 'A02', 'Ngả lưng 120 độ'),
('R02', 'P02', 'B02', 'Ngả lưng 120 độ'),
('R03', 'P03', 'C02', 'Ngả lưng 120 độ'),
('R04', 'P04', 'D02', 'Ngả lưng 120 độ'),
('R05', 'P05', 'E02', 'Ngả lưng 120 độ');

-- 13. NHAN_VIEN
-- NV001-NV005 la quan tri; NV006-NV010 la nhan vien van hanh.
INSERT INTO NHAN_VIEN
    (MaNhanVien, Ho, Ten, GioiTinh, NgaySinh, SoDienThoai, CCCD, MucLuong, MaTaiKhoan, MaRap)
VALUES
('NV001', 'Nguyễn Văn', 'An', 'Nam', '1988-01-10', '0912000001', '079088000001', 22000000, 'TK001', 'R01'),
('NV002', 'Trần Thị', 'Bích', 'Nữ', '1990-02-20', '0912000002', '079090000002', 21000000, 'TK002', 'R02'),
('NV003', 'Lê Minh', 'Cường', 'Nam', '1987-03-12', '0912000003', '079087000003', 23000000, 'TK003', 'R03'),
('NV004', 'Phạm Ngọc', 'Dung', 'Nữ', '1992-04-08', '0912000004', '079092000004', 20500000, 'TK004', 'R04'),
('NV005', 'Võ Thanh', 'Em', 'Khác', '1991-05-18', '0912000005', '079091000005', 21500000, 'TK005', 'R05'),
('NV006', 'Đặng Quốc', 'Phong', 'Nam', '1999-06-21', '0912000006', '079099000006', 9500000, 'TK006', 'R01'),
('NV007', 'Bùi Thu', 'Giang', 'Nữ', '2000-07-14', '0912000007', '079200000007', 9200000, 'TK007', 'R02'),
('NV008', 'Đỗ Anh', 'Huy', 'Nam', '1998-08-25', '0912000008', '079098000008', 9800000, 'TK008', 'R03'),
('NV009', 'Hồ Mỹ', 'Lan', 'Nữ', '2001-09-16', '0912000009', '079201000009', 9000000, 'TK009', 'R04'),
('NV010', 'Cao Nhật', 'Minh', 'Nam', '1997-10-05', '0912000010', '079097000010', 10000000, 'TK010', 'R05');

-- 14. QUAN_TRI_VIEN
-- NV001 la quan tri cap cao; cac quan ly rap con lai do NV001 quan tri.
INSERT INTO QUAN_TRI_VIEN (MaNhanVien, CapQuyen, MaQuanTri) VALUES
('NV001', 'Quản trị hệ thống', NULL),
('NV002', 'Quản lý rạp', 'NV001'),
('NV003', 'Quản lý rạp', 'NV001'),
('NV004', 'Quản lý rạp', 'NV001'),
('NV005', 'Quản lý rạp', 'NV001');

-- 15. NHAN_VIEN_VAN_HANH
INSERT INTO NHAN_VIEN_VAN_HANH (MaNhanVien, ViTriQuay) VALUES
('NV006', 'Quầy vé 1'),
('NV007', 'Quầy vé 2'),
('NV008', 'Quầy bắp nước 1'),
('NV009', 'Cửa soát vé 1'),
('NV010', 'Phòng điều khiển 1');

-- Gan quan ly sau khi QUAN_TRI_VIEN da ton tai.
UPDATE RAP_PHIM SET MaQuanLy = 'NV001' WHERE MaRap = 'R01';
UPDATE RAP_PHIM SET MaQuanLy = 'NV002' WHERE MaRap = 'R02';
UPDATE RAP_PHIM SET MaQuanLy = 'NV003' WHERE MaRap = 'R03';
UPDATE RAP_PHIM SET MaQuanLy = 'NV004' WHERE MaRap = 'R04';
UPDATE RAP_PHIM SET MaQuanLy = 'NV005' WHERE MaRap = 'R05';

-- 16. PHIM
INSERT INTO PHIM
    (MaPhim, TuaDe, ThoiLuong, MoTa, GioiHanDoTuoi, NgayKhoiChieu, MaQuanLy)
VALUES
('PH001', 'Chị chị em em 3', 120, 'Một cuộc tình tay năm bùng nổ, cuốn tất cả vào một cuộc chiến không ai toàn thắng.', 'T18', '2026-11-20', 'NV001'),
('PH002', 'Bò sữa bay', 105, 'Một trang trại đang nghiên cứu công thức sữa “bí mật” có khả năng chữa lành và trẻ hóa.', 'T13', '2026-11-22', 'NV002'),
('PH003', 'Trại buôn người', 95, 'Vì cứu em gái, Ny cùng bạn thân bị bắt làm nô dịch trong sào huyệt lừa đảo.', 'T18', '2026-11-25', 'NV003'),
('PH004', 'Shaun The Sheep:"Quái Lạ" Ghé Nhà', 110, 'Cả đàn cừu lên đường tìm kiếm Ông chủ và đối mặt với một chuyến phiêu lưu.', 'P', '2026-11-27', 'NV004'),
('PH005', 'Khi Thần Chết Đổ Chuông', 115, 'Linh hồn không đầu gieo rắc nỗi kinh hoàng tại vùng đất Belitung.', 'T18', '2026-11-29', 'NV005');

-- 17. THUOC_THE_LOAI
INSERT INTO THUOC_THE_LOAI (MaPhim, MaTheLoai) VALUES
('PH001', 'TL03'),
('PH001', 'TL05'),
('PH002', 'TL02'),
('PH002', 'TL05'),
('PH003', 'TL01'),
('PH003', 'TL03'),
('PH004', 'TL06'),
('PH005', 'TL04');

-- 18. DAO_DIEN
INSERT INTO DAO_DIEN (MaPhim, DaoDien) VALUES
('PH001', 'Nguyễn Hải Nam'),
('PH002', 'Trần Thu Hà'),
('PH003', 'Lê Hoàng Sơn'),
('PH004', 'Steve Cox'),
('PH005', 'Jay Sukmo');

-- 19. DIEN_VIEN
INSERT INTO DIEN_VIEN (MaPhim, DienVien) VALUES
('PH001', 'Steven Nguyễn'),
('PH001', 'Quốc Anh'),
('PH002', 'Nguyễn Hùng'),
('PH003', 'Steven Nguyễn'),
('PH005', 'Givina');

-- 20. SUAT_CHIEU
INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC001', '2026-12-01', '09:00:00', '11:00:00', '2D', 'Phụ đề', 'PH001', 'R01', 'P01', 'NV001'),
('SC002', '2026-12-01', '11:30:00', '13:15:00', '2D', 'Lồng tiếng', 'PH002', 'R02', 'P02', 'NV002'),
('SC003', '2026-12-01', '14:00:00', '15:35:00', '3D', 'Lồng tiếng', 'PH003', 'R03', 'P03', 'NV003'),
('SC004', '2026-12-01', '18:00:00', '19:50:00', '2D', 'Phụ đề', 'PH004', 'R04', 'P04', 'NV004'),
('SC005', '2026-12-01', '20:15:00', '22:10:00', '2D', 'Phụ đề', 'PH005', 'R05', 'P05', 'NV005');

-- 21. THE_THANH_VIEN
INSERT INTO THE_THANH_VIEN
    (SoThe, HangThe, NgayKichHoat, DiemKhaDung, DiemTichLuy, MaKhachHang)
VALUES
('TV001', 'STANDARD', '2026-01-10', 120, 380, 'KH001'),
('TV002', 'STANDARD', '2026-02-15', 560, 1440, 'KH002'),
('TV003', 'STANDARD', '2026-03-20', 80, 420, 'KH003'),
('TV004', 'VIP', '2026-04-25', 1200, 3800, 'KH004'),
('TV005', 'VIP', '2026-05-30', 640, 2360, 'KH005');

-- 22. KHACH_HANG_TAI_KHOAN
INSERT INTO KHACH_HANG_TAI_KHOAN (MaKhachHang, MaTaiKhoan) VALUES
('KH001', 'TK011'),
('KH002', 'TK012'),
('KH003', 'TK013'),
('KH004', 'TK014'),
('KH005', 'TK015');

-- 23. HOA_DON
-- TongTien du kien theo chi tiet VE + BAO_GOM, chua tru khuyen mai:
-- HD001 = 90.000 (chi ve)
-- HD002 = 78.000 (chi combo)
-- HD003 = 120.000 + 98.000 = 218.000 (ve + combo)
-- HD004 = 90.000 + 120.000 = 210.000 (nhieu ve)
-- HD005 = 150.000 + 2 × 58.000 + 25.000 + 38.000 = 329.000 (ve + nhieu combo)
INSERT INTO HOA_DON
    (MaHoaDon, TongTien, ThoiGian, PhuongThucThanhToan,
     MaNhanVien, MaKhachHang, MaKhuyenMai)
VALUES
('HD001', 90000, '2026-11-28 09:15:00', 'Tiền mặt', 'NV006', 'KH001', NULL),
('HD002', 78000, '2026-11-28 10:20:00', 'Thẻ ngân hàng', 'NV007', 'KH002', 'KM003'),
('HD003', 218000, '2026-11-28 14:05:00', 'Ví điện tử', 'NV008', 'KH003', 'KM005'),
('HD004', 210000, '2026-11-29 18:10:00', 'Thẻ ngân hàng', 'NV009', 'KH004', NULL),
('HD005', 329000, '2026-11-29 20:00:00', 'Ví điện tử', 'NV010', 'KH005', NULL);

-- 24. VE
INSERT INTO VE
    (MaVe, GiaVe, HinhThucMua, MaSuatChieu, MaRap, MaPhong, MaGhe, MaHoaDon)
VALUES
('VE001', 90000, 'Trực tiếp', 'SC001', 'R01', 'P01', 'A01', 'HD001'),
('VE002', 120000, 'Trực tuyến', 'SC003', 'R03', 'P03', 'C02', 'HD003'),
('VE003', 90000, 'Trực tiếp', 'SC004', 'R04', 'P04', 'D01', 'HD004'),
('VE004', 120000, 'Trực tiếp', 'SC004', 'R04', 'P04', 'D02', 'HD004'),
('VE005', 150000, 'Trực tuyến', 'SC005', 'R05', 'P05', 'E03', 'HD005');

-- 25. BAO_GOM
INSERT INTO BAO_GOM (MaHoaDon, MaSanPham, SoLuong, DonGia) VALUES
('HD002', 'SP001', 1, 78000),
('HD003', 'SP002', 1, 98000),
('HD005', 'SP003', 2, 58000),
('HD005', 'SP004', 1, 25000),
('HD005', 'SP005', 1, 38000);
-- 26. SO_HUU
INSERT INTO SO_HUU (MaKhachHang, MaKhuyenMai) VALUES
('KH001', 'KM001'),
('KH002', 'KM003'),
('KH003', 'KM005'),
('KH004', 'KM001'),
('KH005', 'KM002');

-- 27. TRUC
INSERT INTO TRUC (MaCa, MaNhanVien, NgayLamViec) VALUES
('CA01', 'NV006', '2026-11-28'), 
('CA01', 'NV007', '2026-11-28'),
('CA02', 'NV008', '2026-11-28'),
('CA03', 'NV009', '2026-11-29'),
('CA04', 'NV010', '2026-11-29'); 

COMMIT;
