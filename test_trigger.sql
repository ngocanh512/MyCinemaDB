SET NAMES utf8mb4;
USE myCinemaDB;

START TRANSACTION;

INSERT INTO HOA_DON
    (MaHoaDon, ThoiGian, PhuongThucThanhToan, MaNhanVien, MaKhachHang)
VALUES
    ('HD900', '2026-12-05 11:00:00', 'Ví điện tử', 'NV006', 'KH003'),
    ('HD901', '2026-12-05 11:00:00', 'Tiền mặt', 'NV006', 'KH001');

-- 1. THÊM VÉ: 
INSERT INTO VE
    (MaVe, GiaVe, HinhThucMua, ThoiGianDat, DinhDang, LoaiGhe,
     MaSuatChieu, MaRap, MaPhong, MaGhe, MaHoaDon)
VALUES
    ('VE900', 180000, 'Trực tuyến', '2026-12-05 11:00:00',
     'IMAX', 'VIP', 'SC007', 'R01', 'P01', 'A02', 'HD900');
SELECT '1. Thêm VE' AS Buoc, MaHoaDon, MaKhuyenMai, TienGiam, TongTien
FROM HOA_DON WHERE MaHoaDon = 'HD900';

-- 2. THÊM COMBO: 
INSERT INTO BAO_GOM (MaHoaDon, MaSanPham, SoLuong, DonGia)
VALUES ('HD900', 'SP001', 1, 78000);
SELECT '2. Thêm combo' AS Buoc, MaHoaDon, MaKhuyenMai, TienGiam, TongTien
FROM HOA_DON WHERE MaHoaDon = 'HD900';

-- 3. SỬA COMBO: 
UPDATE BAO_GOM SET SoLuong = 10
WHERE MaHoaDon = 'HD900' AND MaSanPham = 'SP001';
SELECT '3. Sửa combo' AS Buoc, MaHoaDon, MaKhuyenMai, TienGiam, TongTien
FROM HOA_DON WHERE MaHoaDon = 'HD900';

-- 4. SỬA VÉ: 
UPDATE VE SET MaHoaDon = 'HD901' WHERE MaVe = 'VE900';
SELECT '4. Sửa VE: chuyển hóa đơn' AS Buoc,
       MaHoaDon, MaKhuyenMai, TienGiam, TongTien
FROM HOA_DON WHERE MaHoaDon IN ('HD900', 'HD901') ORDER BY MaHoaDon;

-- 5. XÓA VÉ:
DELETE FROM VE WHERE MaVe = 'VE900';
SELECT '5. Xóa VE' AS Buoc, MaHoaDon, MaKhuyenMai, TienGiam, TongTien
FROM HOA_DON WHERE MaHoaDon = 'HD901';

-- 6. XÓA COMBO:
DELETE FROM BAO_GOM WHERE MaHoaDon = 'HD900' AND MaSanPham = 'SP001';
SELECT '6. Xóa combo' AS Buoc, MaHoaDon, MaKhuyenMai, TienGiam, TongTien
FROM HOA_DON WHERE MaHoaDon = 'HD900';

ROLLBACK;
