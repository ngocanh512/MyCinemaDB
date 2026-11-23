USE myCinemaDB;
-- Test INSERT những CASE hợp lệ
INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
-- CASE 1: Thêm sau SC001, cách hơn 15 phút.
-- SC001 kết thúc 11:00, SC006 bắt đầu 14:00 (cách 3 tiếng).
('SC006', '2026-12-01', '14:00:00', '16:00:00', '2D', 'Phụ đề', 'PH001', 'R01', 'P01', 'NV001'),

-- CASE 2: Thêm trước SC001, cách đúng 15 phút.
-- SC007 kết thúc 08:45, SC001 bắt đầu 09:00.
('SC007', '2026-12-01', '07:00:00', '08:45:00', '2D', 'Phụ đề', 'PH002', 'R01', 'P01', 'NV001'),

-- CASE 3: Thêm vào giữa hai suất đã tồn tại SC001 và SC006.
-- SC001 kết thúc 11:00, SC008 chiếu 11:15-13:45, SC006 bắt đầu 14:00.
-- Khoảng cách ở cả hai phía đều đúng 15 phút.
('SC008', '2026-12-01', '11:15:00', '13:45:00', '2D', 'Phụ đề', 'PH003', 'R01', 'P01', 'NV001'),

-- CASE 4: Thêm vào phòng khác R02-P02.
-- SC002 kết thúc 13:15, SC009 bắt đầu 13:30, cách đúng 15 phút.
('SC009', '2026-12-01', '13:30:00', '15:00:00', '2D', 'Phụ đề', 'PH003', 'R02', 'P02', 'NV002'), 

-- CASE 5: Thêm vào cùng phòng R01-P01 nhưng ở ngày khác.
-- SC010 thuộc ngày 03/12/2026, không xung đột với lịch ngày 01/12/2026.
('SC010', '2026-12-03', '09:00:00', '11:00:00', '2D', 'Phụ đề', 'PH004', 'R01', 'P01', 'NV001'),

-- CASE 6: Thêm suất chiếu qua đêm, cách suất chiếu ngày hôm trước đúng 15 phút.
-- SC011 kết thúc 23:00 ngày 06/12.
-- SC012 bắt đầu 23:15 ngày 06/12 và kết thúc 01:00 ngày 07/12.
('SC011', '2026-12-06', '21:00:00', '23:00:00', '2D', 'Phụ đề', 'PH003', 'R01', 'P01', 'NV001'),
('SC012', '2026-12-06', '23:15:00', '01:00:00', '2D', 'Phụ đề', 'PH004', 'R01', 'P01', 'NV001');

-- Test INSERT những CASE không hợp lệ
-- CASE 1: Thêm suất chiếu sau SC006 nhưng chỉ cách 10 phút.
INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC013', '2026-12-01', '16:10:00', '18:00:00',
 '2D', 'Phụ đề', 'PH001', 'R01', 'P01', 'NV001');

-- CASE 2: Thêm suất chiếu trước SC007 nhưng chỉ cách 10 phút.
INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC014', '2026-12-01', '05:00:00', '06:50:00',
 '2D', 'Phụ đề', 'PH002', 'R01', 'P01', 'NV001');

-- CASE 3: Thêm suất chiếu giữa SC007 và SC001,
INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC015', '2026-12-01', '08:50:00', '09:30:00',
 '2D', 'Phụ đề', 'PH003', 'R01', 'P01', 'NV001');

-- CASE 4: Thêm suất chiếu sau SC012 qua đêm nhưng chỉ cách 5 phút.
INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC016', '2026-12-07', '01:05:00', '03:00:00',
 '2D', 'Phụ đề', 'PH004', 'R01', 'P01', 'NV001');

-- CASE 5: Thêm suất chiếu sau SC005 nhưng chỉ cách 10 phút.
INSERT INTO SUAT_CHIEU
    (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
     HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
('SC017', '2026-12-01', '22:20:00', '00:20:00',
 '2D', 'Phụ đề', 'PH005', 'R05', 'P05', 'NV005');

-- Test UPDATE những CASE hợp lệ
-- CASE 1: Thay đổi giờ chiếu của SC001.
UPDATE SUAT_CHIEU
SET GioBatDau = '09:15:00',
    GioKetThuc = '11:15:00'
WHERE MaSuatChieu = 'SC001';

-- CASE 2: Chuyển SC002 sang phòng R01-P01.
UPDATE SUAT_CHIEU
SET MaRap = 'R01',
    MaPhong = 'P01'
WHERE MaSuatChieu = 'SC002';

-- CASE 3: Thay đổi ngày chiếu của SC004.
UPDATE SUAT_CHIEU
SET NgayChieu = '2026-12-02'
WHERE MaSuatChieu = 'SC004';

-- CASE 4: Chuyển SC005 sang phòng R03-P03.
UPDATE SUAT_CHIEU
SET MaRap = 'R03',
    MaPhong = 'P03'
WHERE MaSuatChieu = 'SC005';

-- Test UPDATE những CASE không hợp lệ
-- CASE 1: Cập nhật giờ kết thúc SC001,
UPDATE SUAT_CHIEU
SET GioKetThuc = '11:20:00'
WHERE MaSuatChieu = 'SC001';

-- CASE 2: Cập nhật giờ bắt đầu SC002,
UPDATE SUAT_CHIEU
SET GioBatDau = '11:20:00'
WHERE MaSuatChieu = 'SC002';

-- CASE 3: Chuyển SC004 sang phòng R01-P01,
UPDATE SUAT_CHIEU
SET NgayChieu = '2026-12-01',
    GioBatDau = '12:00:00',
    GioKetThuc = '13:00:00',
    MaRap = 'R01',
    MaPhong = 'P01'
WHERE MaSuatChieu = 'SC004';

-- CASE 4: Cập nhật giờ chiếu SC005,
UPDATE SUAT_CHIEU
SET GioBatDau = '15:40:00',
    GioKetThuc = '17:30:00'
WHERE MaSuatChieu = 'SC005';