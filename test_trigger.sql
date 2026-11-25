SET NAMES utf8mb4;
USE myCinemaDB;
START TRANSACTION;

INSERT INTO HOA_DON
    (MaHoaDon, ThoiGian, PhuongThucThanhToan, MaNhanVien, MaKhachHang)
VALUES
    ('HD900', '2026-12-05 11:00:00', 'Ví điện tử', NULL, 'KH003'),
    ('HD901', '2026-12-05 11:00:00', 'Ví điện tử', NULL, 'KH001'),
    ('HD902', '2026-11-28 09:15:00', 'Thẻ ngân hàng', NULL, 'KH002');

INSERT INTO VE
    (MaVe, GiaVe, HinhThucMua, ThoiGianDat, DinhDang, LoaiGhe,
     MaSuatChieu, MaRap, MaPhong, MaGhe, MaHoaDon)
VALUES
    ('VE900', 170000, 'Trực tuyến', '2026-12-05 11:00:00',
     'IMAX', 'VIP', 'SC007', 'R01', 'P01', 'A02', 'HD900'),
    ('VE901', 85000, 'Trực tuyến', '2026-12-05 11:00:00',
     '2D', 'VIP', 'SC006', 'R01', 'P01', 'A02', 'HD901'),
    ('VE902', 85000, 'Trực tuyến', '2026-11-28 09:15:00',
     '2D', 'VIP', 'SC001', 'R01', 'P01', 'A02', 'HD902');

INSERT INTO BAO_GOM (MaHoaDon, MaSanPham, SoLuong, DonGia)
VALUES
    ('HD900', 'SP001', 1, 78000),
    ('HD901', 'SP005', 1, 38000),
    ('HD902', 'SP003', 1, 58000);

SELECT MaHoaDon, MaKhuyenMai,
       TongTien + TienGiam AS TongTruocGiam, TienGiam, TongTien
FROM HOA_DON
WHERE MaHoaDon IN ('HD900', 'HD901', 'HD902')
ORDER BY MaHoaDon;

ROLLBACK;
