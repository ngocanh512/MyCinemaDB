USE myCinemaDB;

START TRANSACTION;

-- =====================================================
-- I. TEST BEFORE INSERT
-- =====================================================

SAVEPOINT sp_insert;

-- 1. CÁC TRƯỜNG HỢP INSERT HỢP LỆ

-- CASE 1: Thêm sau SC001, cách hơn 15 phút.
-- SC001 kết thúc 11:00, SC2201 bắt đầu 14:00.
-- Mong đợi: INSERT thành công.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2201', '2026-12-01', '14:00:00', '16:00:00',
 '2D', 'Phụ đề', 'PH001', 'R01', 'P01', 'NV001');


-- CASE 2: Thêm trước SC001, cách đúng 15 phút.
-- SC2202 kết thúc 08:45, SC001 bắt đầu 09:00.
-- Mong đợi: INSERT thành công.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2202', '2026-12-01', '07:00:00', '08:45:00',
 '2D', 'Phụ đề', 'PH002', 'R01', 'P01', 'NV001');


-- CASE 3: Thêm vào giữa SC001 và SC2201.
-- SC001 kết thúc 11:00; SC2203 chiếu 11:15-13:45;
-- SC2201 bắt đầu 14:00.
-- Mong đợi: INSERT thành công.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2203', '2026-12-01', '11:15:00', '13:45:00',
 '2D', 'Phụ đề', 'PH003', 'R01', 'P01', 'NV001');
 

-- CASE 4: Thêm vào phòng khác R02-P02.
-- SC002 kết thúc 13:15, SC2204 bắt đầu 13:30.
-- Mong đợi: INSERT thành công.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2204', '2026-12-01', '13:30:00', '15:00:00',
 '2D', 'Phụ đề', 'PH003', 'R02', 'P02', 'NV002');


-- CASE 5: Thêm vào cùng phòng R01-P01 nhưng ở ngày khác.
-- SC2205 thuộc ngày 03/12/2026.
-- Mong đợi: INSERT thành công.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2205', '2026-12-03', '09:00:00', '11:00:00',
 '2D', 'Phụ đề', 'PH004', 'R01', 'P01', 'NV001');


-- CASE 6: Thêm hai suất chiếu liên tiếp qua đêm.
-- SC2206 kết thúc 23:00 ngày 06/12.
-- SC2207 bắt đầu 23:15 ngày 06/12.
-- Mong đợi: Cả hai INSERT thành công.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2206', '2026-12-06', '21:00:00', '23:00:00',
 '2D', 'Phụ đề', 'PH003', 'R01', 'P01', 'NV001');

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2207', '2026-12-06', '23:15:00', '01:00:00',
 '2D', 'Phụ đề', 'PH004', 'R01', 'P01', 'NV001');


-- 2. CÁC TRƯỜNG HỢP INSERT KHÔNG HỢP LỆ

-- CASE 1: Thêm sau SC2201 nhưng chỉ cách 10 phút.
-- Mong đợi: Bị trigger chặn.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2208', '2026-12-01', '16:10:00', '18:00:00',
 '2D', 'Phụ đề', 'PH001', 'R01', 'P01', 'NV001');


-- CASE 2: Thêm trước SC2202 nhưng chỉ cách 10 phút.
-- SC2209 kết thúc 06:50, SC2202 bắt đầu 07:00.
-- Mong đợi: Bị trigger chặn.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2209', '2026-12-01', '05:00:00', '06:50:00',
 '2D', 'Phụ đề', 'PH002', 'R01', 'P01', 'NV001');


-- CASE 3: Thêm suất chiếu bị trùng thời gian với SC001.
-- SC2210 chiếu 08:50-09:30, trong khi SC001 bắt đầu 09:00.
-- Mong đợi: Bị trigger chặn.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2210', '2026-12-01', '08:50:00', '09:30:00',
 '2D', 'Phụ đề', 'PH003', 'R01', 'P01', 'NV001');


-- CASE 4: Thêm sau SC2207 qua đêm nhưng chỉ cách 5 phút.
-- SC2207 kết thúc 01:00 ngày 07/12.
-- SC2211 bắt đầu 01:05 ngày 07/12.
-- Mong đợi: Bị trigger chặn.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2211', '2026-12-07', '01:05:00', '03:00:00',
 '2D', 'Phụ đề', 'PH004', 'R01', 'P01', 'NV001');


-- CASE 5: Thêm sau SC005 nhưng chỉ cách 10 phút.
-- SC005 kết thúc 22:10, SC2212 bắt đầu 22:20.
-- Mong đợi: Bị trigger chặn.

INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC2212', '2026-12-01', '22:20:00', '00:20:00',
 '2D', 'Phụ đề', 'PH005', 'R05', 'P05', 'NV005');


-- Hoàn tác toàn bộ dữ liệu INSERT kiểm thử.
-- Đưa dữ liệu về trạng thái ban đầu SC001-SC005.

ROLLBACK TO SAVEPOINT sp_insert;


-- =====================================================
-- II. TEST BEFORE UPDATE
-- =====================================================

SAVEPOINT sp_update;

-- 1. CÁC TRƯỜNG HỢP UPDATE HỢP LỆ

-- CASE 1: Thay đổi giờ chiếu của SC001.
-- SC001 chuyển thành 09:15-11:15.
-- Mong đợi: UPDATE thành công.

UPDATE SUAT_CHIEU
SET GioBatDau = '09:15:00',
    GioKetThuc = '11:15:00'
WHERE MaSuatChieu = 'SC001';


-- CASE 2: Chuyển SC002 sang phòng R01-P01.
-- SC001 kết thúc 11:15, SC002 bắt đầu 11:30.
-- Khoảng cách đúng 15 phút.
-- Mong đợi: UPDATE thành công.

UPDATE SUAT_CHIEU
SET MaRap = 'R01',
    MaPhong = 'P01'
WHERE MaSuatChieu = 'SC002';


-- CASE 3: Thay đổi ngày chiếu của SC004.
-- Chuyển SC004 sang ngày 02/12/2026.
-- Mong đợi: UPDATE thành công.

UPDATE SUAT_CHIEU
SET NgayChieu = '2026-12-02'
WHERE MaSuatChieu = 'SC004';


-- CASE 4: Đổi giờ SC005 trong cùng phòng R05-P05 thành 20:30-22:25.
-- Phòng R05-P05 ngày 01/12 không có suất nào khác.
-- Mong đợi: UPDATE thành công.

UPDATE SUAT_CHIEU
SET GioBatDau = '20:30:00',
    GioKetThuc = '22:25:00'
WHERE MaSuatChieu = 'SC005';


-- 2. CÁC TRƯỜNG HỢP UPDATE KHÔNG HỢP LỆ

-- CASE 1: Cập nhật giờ kết thúc SC001 thành 11:20.
-- SC002 bắt đầu 11:30, khoảng cách chỉ còn 10 phút.
-- Mong đợi: Bị trigger chặn.

UPDATE SUAT_CHIEU
SET GioKetThuc = '11:20:00'
WHERE MaSuatChieu = 'SC001';


-- CASE 2: Cập nhật giờ bắt đầu SC002 thành 11:20.
-- SC001 kết thúc 11:15, khoảng cách chỉ còn 5 phút.
-- Mong đợi: Bị trigger chặn.

UPDATE SUAT_CHIEU
SET GioBatDau = '11:20:00'
WHERE MaSuatChieu = 'SC002';


-- CASE 3: Chuyển SC004 sang phòng R01-P01 và thay đổi thời gian suất chiếu thành 12:00-13:00.
-- SC004 chiếu 12:00-13:00, bị trùng thời gian với SC002.
-- Mong đợi: Bị trigger chặn.

UPDATE SUAT_CHIEU
SET NgayChieu = '2026-12-01',
    GioBatDau = '12:00:00',
    GioKetThuc = '13:00:00',
    MaRap = 'R01',
    MaPhong = 'P01'
WHERE MaSuatChieu = 'SC004';


-- CASE 4: Chuyển SC002 (chưa có vé) sang phòng R03-P03, chiếu 15:40-17:25.
-- SC003 ở R03-P03 kết thúc 15:35, khoảng cách chỉ còn 5 phút.
-- Mong đợi: Bị trigger chặn.

UPDATE SUAT_CHIEU
SET MaRap = 'R03',
    MaPhong = 'P03',
    GioBatDau = '15:40:00',
    GioKetThuc = '17:25:00'
WHERE MaSuatChieu = 'SC002';


-- Hoàn tác toàn bộ dữ liệu UPDATE kiểm thử.
ROLLBACK TO SAVEPOINT sp_update;


-- =====================================================
-- III. KẾT THÚC KIỂM THỬ
-- =====================================================

-- Hoàn tác toàn bộ giao dịch, giữ nguyên dữ liệu gốc.
ROLLBACK;