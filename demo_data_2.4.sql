-- =====================================================================
-- 02_demo_data.sql
-- Du lieu bo sung phuc vu demo 2 ham: fn_TyLeSuDungPhong, fn_TimDayGheTrong
-- Chay SAU file du lieu goc (27 bang) va TRUOC khi chay file test.
-- Chi them du lieu vao cac bang ma 2 ham can: PHONG_CHIEU, GHE, SUAT_CHIEU, VE
-- (VE.MaHoaDon la NOT NULL nen dung lai hoa don HD001 co san)
-- =====================================================================
SET NAMES utf8mb4;
USE myCinemaDB;

START TRANSACTION;

-- A. Phong R01-P06 (13 ghe)
--    Hang A: A01-A05 | Hang B: B01, B02, B04, B05 (B03 la loi di) | Hang C: C01-C04
INSERT INTO PHONG_CHIEU (MaRap, MaPhong, SoGhe) VALUES ('R01', 'P06', 13);

INSERT INTO GHE (MaRap, MaPhong, MaGhe, LoaiGhe) VALUES
('R01','P06','A01','Thường'),('R01','P06','A02','Thường'),('R01','P06','A03','Thường'),
('R01','P06','A04','Thường'),('R01','P06','A05','Thường'),
('R01','P06','B01','Thường'),('R01','P06','B02','Thường'),
('R01','P06','B04','Thường'),('R01','P06','B05','Thường'),
('R01','P06','C01','Thường'),('R01','P06','C02','Thường'),
('R01','P06','C03','Thường'),('R01','P06','C04','Thường');

-- B. Suat chieu bo sung
INSERT INTO SUAT_CHIEU
 (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang, HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
VALUES
-- Ham 1, R01-P01: 6 suat, nghi 30 phut
('SC006','2026-12-02','08:00:00','10:00:00','2D','Phụ đề','PH001','R01','P01','NV001'),
('SC007','2026-12-02','10:30:00','12:30:00','2D','Lồng tiếng','PH002','R01','P01','NV001'),
('SC008','2026-12-02','13:00:00','15:00:00','3D','Lồng tiếng','PH003','R01','P01','NV001'),
('SC009','2026-12-02','15:30:00','17:30:00','2D','Phụ đề','PH004','R01','P01','NV001'),
('SC010','2026-12-02','18:00:00','20:00:00','2D','Phụ đề','PH005','R01','P01','NV001'),
('SC011','2026-12-02','20:30:00','22:30:00','2D','Phụ đề','PH001','R01','P01','NV001'),
-- Ham 1, R02-P02: nghi 10 phut (duoi muc toi thieu 15 phut)
('SC012','2026-12-02','09:00:00','11:00:00','2D','Lồng tiếng','PH002','R02','P02','NV002'),
('SC013','2026-12-02','11:10:00','13:10:00','2D','Phụ đề','PH003','R02','P02','NV002'),
('SC014','2026-12-02','13:20:00','15:20:00','2D','Phụ đề','PH004','R02','P02','NV002'),
-- Ham 1, R03-P03: hai suat chong lan 30 phut
('SC015','2026-12-02','10:00:00','12:00:00','2D','Phụ đề','PH005','R03','P03','NV003'),
('SC016','2026-12-02','11:30:00','13:30:00','2D','Lồng tiếng','PH001','R03','P03','NV003'),
-- Ham 1, R04-P04: suat ket thuc luc 01:00 sang hom sau
('SC017','2026-12-02','19:00:00','21:00:00','2D','Phụ đề','PH002','R04','P04','NV004'),
('SC018','2026-12-02','22:00:00','01:00:00','2D','Phụ đề','PH003','R04','P04','NV004'),
-- Ham 1, R05-P05: suat bat dau 07:00, truoc gio mo cua 08:00
('SC019','2026-12-02','07:00:00','09:00:00','2D','Phụ đề','PH004','R05','P05','NV005'),
-- Ham 2, R01-P06: 1 suat da qua + 2 suat tuong lai (nam 2030 de demo khong het han)
('SC020','2026-01-15','10:00:00','12:00:00','2D','Phụ đề','PH003','R01','P06','NV001'),
('SC021','2030-01-15','19:00:00','21:00:00','2D','Phụ đề','PH001','R01','P06','NV001'),
('SC022','2030-01-16','10:00:00','12:00:00','2D','Lồng tiếng','PH002','R01','P06','NV001');

-- C. Ve: suat SC021 da ban ghe A01 va A04 (dung lai hoa don HD001)
INSERT INTO VE
 (MaVe, GiaVe, HinhThucMua, MaSuatChieu, MaRap, MaPhong, MaGhe, MaHoaDon)
VALUES
('VE006', 90000, 'Trực tuyến', 'SC021', 'R01', 'P06', 'A01', 'HD001'),
('VE007', 90000, 'Trực tuyến', 'SC021', 'R01', 'P06', 'A04', 'HD001');

COMMIT;
