-- =====================================================================
-- DỮ LIỆU BỔ SUNG ĐỂ MINH HỌA CÂU 2.3 (chạy sau insert_data.sql và
-- trigger_tong_tien.sql)
-- Thêm 7 suất chiếu (08-10/12/2026), 6 hóa đơn, 13 vé, 2 dòng sản phẩm.
-- Mã riêng của câu 2.3: SC23xx, HD23xx, VE23xx (không trùng dữ liệu gốc
-- và demo của câu khác). Các lệnh CALL ở cuối procedures_2_3.sql đều lọc
-- theo khoảng 08-10/12/2026 nên kết quả không phụ thuộc demo khác.
--
-- Giá vé lấy đúng theo BANG_GIA_VE (RB 13):
--   2D  : Thường 65.000 | VIP  85.000 | Đôi  70.000
--   3D  : Thường 80.000 | VIP 100.000 | Đôi  85.000
--   IMAX: Thường 150.000 | VIP 170.000 | Đôi 155.000
-- Các ràng buộc đã kiểm tra trên dữ liệu này:
--   RB 1  : suất cùng phòng cách nhau >= 15 phút
--   RB 2  : vé trực tuyến đặt trước giờ chiếu
--   RB 13 : DinhDang, LoaiGhe, GiaVe khớp suất chiếu, ghế, bảng giá
--   RB 14 : thanh toán trong 10 phút sau khi đặt vé
--   RB 18 : khung giờ suất >= thời lượng phim
--   RB 22, 25 : mỗi hóa đơn một suất chiếu, một hình thức mua
--   RB 23, 26 : hóa đơn trực tuyến không trả tiền mặt, không có nhân viên
--   RB 24 : đặt vé không sớm hơn 14 ngày trước ngày chiếu
-- TongTien, TienGiam, MaKhuyenMai do trigger tính (RB 27, 28):
--   HD2301 228.000 - 11.400 (KM003, ví)          = 216.600
--   HD2302 265.000 - 0      (tiền mặt, không HSSV) = 265.000
--   HD2303 296.000 - 14.800 (KM003, thẻ)          = 281.200
--   HD2304 150.000 - 7.500  (KM003, ví)           = 142.500
--   HD2305 150.000 - 22.500 (KM004, HSSV)         = 127.500
--   HD2306 170.000 - 8.500  (KM003, thẻ)          = 161.500
-- =====================================================================
SET NAMES utf8mb4;
USE myCinemaDB;

START TRANSACTION;

-- 08/12 thứ Ba, 09/12 thứ Tư, 10/12 thứ Năm (không có suất thứ Hai)
INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2301', '2026-12-08', '09:00:00', '11:00:00', '2D',   'Phụ đề',     'PH001', 'R01', 'P01', 'NV001'),
('SC2302', '2026-12-08', '19:00:00', '20:45:00', '3D',   'Lồng tiếng', 'PH002', 'R02', 'P02', 'NV002'),
('SC2303', '2026-12-08', '20:00:00', '21:35:00', '2D',   'Phụ đề',     'PH003', 'R03', 'P03', 'NV003'),
('SC2304', '2026-12-09', '18:00:00', '20:00:00', '2D',   'Phụ đề',     'PH001', 'R02', 'P02', 'NV002'),
('SC2305', '2026-12-09', '09:00:00', '10:50:00', '2D',   'Lồng tiếng', 'PH004', 'R01', 'P01', 'NV001'),
('SC2306', '2026-12-10', '20:00:00', '22:00:00', 'IMAX', 'Phụ đề',     'PH005', 'R05', 'P05', 'NV005'),
('SC2307', '2026-12-10', '14:00:00', '15:45:00', '2D',   'Lồng tiếng', 'PH002', 'R02', 'P02', 'NV002');

-- Hóa đơn tạo trước (VE tham chiếu HOA_DON); TongTien để trigger tính.
-- Mua tại quầy: có nhân viên của rạp đó. Mua trực tuyến: MaNhanVien NULL.
INSERT INTO HOA_DON
    (MaHoaDon, ThoiGian, PhuongThucThanhToan, MaNhanVien, MaKhachHang)
VALUES
('HD2301', '2026-12-07 20:05:00', 'Ví điện tử',    NULL,    'KH001'), -- trực tuyến
('HD2302', '2026-12-08 18:33:00', 'Tiền mặt',      'NV007', 'KH002'), -- tại quầy R02
('HD2303', '2026-12-08 19:44:00', 'Thẻ ngân hàng', 'NV008', 'KH004'), -- tại quầy R03
('HD2304', '2026-12-09 17:34:00', 'Ví điện tử',    NULL,    'KH005'), -- trực tuyến
('HD2305', '2026-12-09 08:43:00', 'Tiền mặt',      'NV006', 'KH003'), -- tại quầy R01, HSSV
('HD2306', '2026-12-10 19:05:00', 'Thẻ ngân hàng', NULL,    'KH002'); -- trực tuyến

INSERT INTO VE
    (MaVe, GiaVe, HinhThucMua, ThoiGianDat, DinhDang, LoaiGhe,
     MaSuatChieu, MaRap, MaPhong, MaGhe, MaHoaDon)
VALUES
-- HD2301: SC2301 (PH001, 2D), 2 vé trực tuyến + 1 combo
('VE2301',  65000, 'Trực tuyến', '2026-12-07 20:00:00', '2D',   'Thường', 'SC2301', 'R01', 'P01', 'A01', 'HD2301'),
('VE2302',  85000, 'Trực tuyến', '2026-12-07 20:00:00', '2D',   'VIP',    'SC2301', 'R01', 'P01', 'A02', 'HD2301'),
-- HD2302: SC2302 (PH002, 3D), mua hết 3 ghế -> suất "Hết vé"
('VE2303',  80000, 'Trực tiếp',  '2026-12-08 18:30:00', '3D',   'Thường', 'SC2302', 'R02', 'P02', 'B01', 'HD2302'),
('VE2304', 100000, 'Trực tiếp',  '2026-12-08 18:30:00', '3D',   'VIP',    'SC2302', 'R02', 'P02', 'B02', 'HD2302'),
('VE2305',  85000, 'Trực tiếp',  '2026-12-08 18:30:00', '3D',   'Đôi',    'SC2302', 'R02', 'P02', 'B03', 'HD2302'),
-- HD2303: SC2303 (PH003, 2D), mua hết 3 ghế + 2 nước -> suất "Hết vé"
('VE2306',  65000, 'Trực tiếp',  '2026-12-08 19:40:00', '2D',   'Thường', 'SC2303', 'R03', 'P03', 'C01', 'HD2303'),
('VE2307',  85000, 'Trực tiếp',  '2026-12-08 19:40:00', '2D',   'VIP',    'SC2303', 'R03', 'P03', 'C02', 'HD2303'),
('VE2308',  70000, 'Trực tiếp',  '2026-12-08 19:40:00', '2D',   'Đôi',    'SC2303', 'R03', 'P03', 'C03', 'HD2303'),
-- HD2304: SC2304 (PH001, 2D), 2 vé trực tuyến
('VE2309',  65000, 'Trực tuyến', '2026-12-09 17:30:00', '2D',   'Thường', 'SC2304', 'R02', 'P02', 'B01', 'HD2304'),
('VE2310',  85000, 'Trực tuyến', '2026-12-09 17:30:00', '2D',   'VIP',    'SC2304', 'R02', 'P02', 'B02', 'HD2304'),
-- HD2305: SC2305 (PH004, 2D), khách HSSV mua tại quầy
('VE2311',  65000, 'Trực tiếp',  '2026-12-09 08:40:00', '2D',   'Thường', 'SC2305', 'R01', 'P01', 'A01', 'HD2305'),
('VE2312',  85000, 'Trực tiếp',  '2026-12-09 08:40:00', '2D',   'VIP',    'SC2305', 'R01', 'P01', 'A02', 'HD2305'),
-- HD2306: SC2306 (PH005, IMAX), 1 vé VIP trực tuyến
('VE2313', 170000, 'Trực tuyến', '2026-12-10 19:00:00', 'IMAX', 'VIP',    'SC2306', 'R05', 'P05', 'E02', 'HD2306');
-- SC2307 (PH002, 10/12) chưa bán vé nào: còn đủ 3 ghế

INSERT INTO BAO_GOM (MaHoaDon, MaSanPham, SoLuong, DonGia) VALUES
('HD2301', 'SP001', 1, 78000),
('HD2303', 'SP005', 2, 38000);

COMMIT;
