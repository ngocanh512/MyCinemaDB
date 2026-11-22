-- =====================================================================
-- DỮ LIỆU BỔ SUNG ĐỂ MINH HỌA CÂU 2.3 (chạy sau insert_data.sql)
-- Thêm 5 suất chiếu (02-03/12/2026), 5 hóa đơn, 11 vé, 2 dòng combo
-- để mỗi phim có nhiều suất / nhiều vé -> GROUP BY, HAVING cho kết quả rõ ràng.
-- Giá vé theo mức đang dùng trong insert_data.sql:
--   2D: Thường 90.000 | VIP 120.000 | Đôi 150.000
--   3D: Thường 100.000 | VIP 120.000 | Đôi 160.000
-- Lịch phòng không trùng giờ (cách nhau >= 15 phút, RB ngữ nghĩa số 1).
-- =====================================================================
SET NAMES utf8mb4;
USE myCinemaDB;

START TRANSACTION;

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC006', '2026-12-02', '09:00:00', '11:00:00', '2D', 'Phụ đề',     'PH001', 'R01', 'P01', 'NV001'),
('SC007', '2026-12-02', '19:00:00', '20:45:00', '3D', 'Lồng tiếng', 'PH002', 'R02', 'P02', 'NV002'),
('SC008', '2026-12-02', '20:00:00', '21:35:00', '2D', 'Phụ đề',     'PH003', 'R03', 'P03', 'NV003'),
('SC009', '2026-12-03', '18:00:00', '20:00:00', '2D', 'Phụ đề',     'PH001', 'R02', 'P02', 'NV002'),
('SC010', '2026-12-03', '09:00:00', '10:50:00', '2D', 'Lồng tiếng', 'PH004', 'R01', 'P01', 'NV001');

-- TongTien = tổng giá vé + tổng (SoLuong x DonGia) sản phẩm
INSERT INTO HOA_DON
    (MaHoaDon, TongTien, ThoiGian, PhuongThucThanhToan,
     MaNhanVien, MaKhachHang, MaKhuyenMai)
VALUES
('HD006', 288000, '2026-12-01 20:00:00', 'Ví điện tử',    NULL,    'KH001', NULL), -- 90k + 120k + 78k
('HD007', 380000, '2026-12-02 18:30:00', 'Tiền mặt',      'NV007', 'KH002', NULL), -- 100k + 120k + 160k
('HD008', 316000, '2026-12-02 19:40:00', 'Thẻ ngân hàng', 'NV008', 'KH004', NULL), -- 90k + 150k + 2 x 38k
('HD009', 210000, '2026-12-03 17:30:00', 'Ví điện tử',    NULL,    'KH005', NULL), -- 90k + 120k
('HD010', 240000, '2026-12-03 08:40:00', 'Tiền mặt',      'NV006', 'KH003', NULL); -- 90k + 150k

INSERT INTO VE
    (MaVe, GiaVe, HinhThucMua, MaSuatChieu, MaRap, MaPhong, MaGhe, MaHoaDon)
VALUES
('VE006',  90000, 'Trực tuyến', 'SC006', 'R01', 'P01', 'A01', 'HD006'),
('VE007', 120000, 'Trực tuyến', 'SC006', 'R01', 'P01', 'A02', 'HD006'),
('VE008', 100000, 'Trực tiếp',  'SC007', 'R02', 'P02', 'B01', 'HD007'),
('VE009', 120000, 'Trực tiếp',  'SC007', 'R02', 'P02', 'B02', 'HD007'),
('VE010', 160000, 'Trực tiếp',  'SC007', 'R02', 'P02', 'B03', 'HD007'),
('VE011',  90000, 'Trực tiếp',  'SC008', 'R03', 'P03', 'C01', 'HD008'),
('VE012', 150000, 'Trực tiếp',  'SC008', 'R03', 'P03', 'C03', 'HD008'),
('VE013',  90000, 'Trực tuyến', 'SC009', 'R02', 'P02', 'B01', 'HD009'),
('VE014', 120000, 'Trực tuyến', 'SC009', 'R02', 'P02', 'B02', 'HD009'),
('VE015',  90000, 'Trực tiếp',  'SC010', 'R01', 'P01', 'A01', 'HD010'),
('VE016', 150000, 'Trực tiếp',  'SC010', 'R01', 'P01', 'A03', 'HD010');

INSERT INTO BAO_GOM (MaHoaDon, MaSanPham, SoLuong, DonGia) VALUES
('HD006', 'SP001', 1, 78000),
('HD008', 'SP005', 2, 38000);

COMMIT;
