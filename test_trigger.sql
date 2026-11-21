USE myCinemaDB;

SELECT COUNT(*) AS SoTrigger
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE()
  AND TRIGGER_NAME IN ('THEM_VE', 'SUA_VE', 'XOA_VE',
                       'THEM_SANPHAM', 'SUA_SANPHAM', 'XOA_SANPHAM');

SELECT COUNT(*) AS SoProcedure
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = DATABASE()
  AND ROUTINE_TYPE = 'PROCEDURE'
  AND ROUTINE_NAME = 'TinhLaiTongTien';

START TRANSACTION;

INSERT INTO HOA_DON
    (MaHoaDon, TongTien, ThoiGian, PhuongThucThanhToan,
     MaNhanVien, MaKhachHang, MaKhuyenMai)
VALUES ('HD900', 0, '2026-11-28 09:30:00', 'Tiền mặt', 'NV006', 'KH001', NULL);

-- VE: them, sua gia, chuyen sang hoa don khac, xoa.
INSERT INTO VE
    (MaVe, GiaVe, HinhThucMua, MaSuatChieu, MaRap, MaPhong, MaGhe, MaHoaDon)
VALUES ('VE900', 120000, 'Trực tiếp', 'SC001', 'R01', 'P01', 'A02', 'HD900');
SELECT 'VE INSERT: HD900=120000' AS Buoc, MaHoaDon, TongTien FROM HOA_DON WHERE MaHoaDon IN ('HD900');

UPDATE VE SET GiaVe = 130000 WHERE MaVe = 'VE900';
SELECT 'VE UPDATE GiaVe: HD900=130000' AS Buoc, MaHoaDon, TongTien FROM HOA_DON WHERE MaHoaDon IN ('HD900');

UPDATE VE SET MaHoaDon = 'HD001' WHERE MaVe = 'VE900';
SELECT 'VE UPDATE MaHoaDon: HD900=0, HD001=220000' AS Buoc, MaHoaDon, TongTien
FROM HOA_DON WHERE MaHoaDon IN ('HD900', 'HD001') ORDER BY MaHoaDon;

DELETE FROM VE WHERE MaVe = 'VE900';
SELECT 'VE DELETE: HD001=90000' AS Buoc, MaHoaDon, TongTien FROM HOA_DON WHERE MaHoaDon = 'HD001';

-- BAO_GOM: them, sua so luong/don gia, chuyen hoa don, xoa.
INSERT INTO BAO_GOM (MaHoaDon, MaSanPham, SoLuong, DonGia)
VALUES ('HD900', 'SP005', 1, 38000);
SELECT 'BAO_GOM INSERT: HD900=38000' AS Buoc, MaHoaDon, TongTien FROM HOA_DON WHERE MaHoaDon = 'HD900';

UPDATE BAO_GOM SET SoLuong = 2, DonGia = 40000
WHERE MaHoaDon = 'HD900' AND MaSanPham = 'SP005';
SELECT 'BAO_GOM UPDATE: HD900=80000' AS Buoc, MaHoaDon, TongTien FROM HOA_DON WHERE MaHoaDon = 'HD900';

UPDATE BAO_GOM SET MaHoaDon = 'HD001'
WHERE MaHoaDon = 'HD900' AND MaSanPham = 'SP005';
SELECT 'BAO_GOM MOVE: HD900=0, HD001=170000' AS Buoc, MaHoaDon, TongTien
FROM HOA_DON WHERE MaHoaDon IN ('HD900', 'HD001') ORDER BY MaHoaDon;

DELETE FROM BAO_GOM WHERE MaHoaDon = 'HD001' AND MaSanPham = 'SP005';
SELECT 'BAO_GOM DELETE: HD001=90000' AS Buoc, MaHoaDon, TongTien FROM HOA_DON WHERE MaHoaDon = 'HD001';

ROLLBACK;

-- Phai bang 0: khong con hoa don thu va tong cua 5 hoa don mau khong doi.
SELECT COUNT(*) AS SoHD900ConLai FROM HOA_DON WHERE MaHoaDon = 'HD900';
SELECT MaHoaDon, TongTien FROM HOA_DON ORDER BY MaHoaDon;

-- Phai tra ve 0 dong: tong luu trong hoa don khop chi tiet.
SELECT hd.MaHoaDon, hd.TongTien,
       COALESCE(v.TongVe, 0) + COALESCE(bg.TongSanPham, 0) AS TongTinhLai
FROM HOA_DON AS hd
LEFT JOIN (SELECT MaHoaDon, SUM(GiaVe) AS TongVe FROM VE GROUP BY MaHoaDon) AS v
    ON v.MaHoaDon = hd.MaHoaDon
LEFT JOIN (SELECT MaHoaDon, SUM(SoLuong * DonGia) AS TongSanPham
           FROM BAO_GOM GROUP BY MaHoaDon) AS bg
    ON bg.MaHoaDon = hd.MaHoaDon
WHERE hd.TongTien <> COALESCE(v.TongVe, 0) + COALESCE(bg.TongSanPham, 0);
