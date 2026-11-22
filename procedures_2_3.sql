-- =====================================================================
-- CÂU 2.3 - THỦ TỤC TRUY VẤN HIỂN THỊ DỮ LIỆU  (Người làm: Trần Đại Trí)
-- CSDL: myCinemaDB (MySQL 8.0)
-- Chạy sau: myCinemaDB.sql -> insert_data.sql -> demo_data_2_3.sql
--
-- Thủ tục 1: sp_TimKiemSuatChieu      (>= 2 bảng, WHERE, ORDER BY)
--   Tra cứu suất chiếu cho khách / nhân viên quầy. Bảng chính: SUAT_CHIEU (bảng câu 2.1).
--   Gắn với ràng buộc ngữ nghĩa (RBNN) trong BTL1:
--     RBNN 2 : quá 15 phút sau giờ bắt đầu thì ngừng bán vé trực tuyến
--     RBNN 3 : khách phải đủ tuổi theo giới hạn độ tuổi của phim
--     RBNN 9 : mỗi ghế chỉ bán 1 vé / suất  -> số ghế trống = số ghế - số vé đã bán
--
-- Thủ tục 2: sp_ThongKeHieuQuaPhim     (aggregate, GROUP BY, HAVING, WHERE, ORDER BY, >= 2 bảng)
--   Báo cáo cho quản trị viên: hiệu quả từng phim (số suất, vé, doanh thu, tỷ lệ lấp đầy)
--   để quyết định tăng / giảm suất chiếu. Gom nhóm 2 cấp: theo suất chiếu, rồi theo phim.
-- =====================================================================
USE myCinemaDB;

DELIMITER //

-- ---------------------------------------------------------------------
-- THỦ TỤC 1: Tìm kiếm suất chiếu
-- Tham số NULL / chuỗi rỗng = không lọc theo tham số đó
-- (tương ứng textbox, combobox, date picker, checkbox trên giao diện).
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_TimKiemSuatChieu //
CREATE PROCEDURE sp_TimKiemSuatChieu(
    IN p_TuKhoaPhim  VARCHAR(255),  -- một phần tựa phim (không phân biệt hoa/thường, dấu)
    IN p_MaRap       VARCHAR(10),   -- VD 'R01'
    IN p_MaTheLoai   VARCHAR(10),   -- VD 'TL04' (Kinh dị)
    IN p_TuNgay      DATE,          -- ngày chiếu từ
    IN p_DenNgay     DATE,          -- ngày chiếu đến
    IN p_DinhDang    VARCHAR(20),   -- '2D' | '3D' | 'IMAX'
    IN p_TuoiKhach   INT,           -- tuổi khách: chỉ hiện phim được phép xem (RBNN 3)
    IN p_ChiConGhe   BOOLEAN        -- 1 = chỉ hiện suất còn ghế trống
)
BEGIN
    DECLARE v_msg VARCHAR(255);

    -- 1) Chuẩn hóa tham số
    SET p_TuKhoaPhim = NULLIF(TRIM(p_TuKhoaPhim), '');
    SET p_MaRap      = NULLIF(TRIM(p_MaRap), '');
    SET p_MaTheLoai  = NULLIF(TRIM(p_MaTheLoai), '');
    SET p_DinhDang   = NULLIF(TRIM(p_DinhDang), '');
    SET p_ChiConGhe  = IFNULL(p_ChiConGhe, FALSE);

    -- 2) Kiểm tra tham số đầu vào
    IF p_TuNgay IS NOT NULL AND p_DenNgay IS NOT NULL AND p_TuNgay > p_DenNgay THEN
        SET v_msg = CONCAT('Lỗi: Từ ngày (', p_TuNgay,
                           ') không được sau Đến ngày (', p_DenNgay, ').');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF p_MaRap IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM RAP_PHIM WHERE MaRap = p_MaRap) THEN
        SET v_msg = CONCAT('Lỗi: Mã rạp "', p_MaRap, '" không tồn tại.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF p_MaTheLoai IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM THE_LOAI WHERE MaTheLoai = p_MaTheLoai) THEN
        SET v_msg = CONCAT('Lỗi: Mã thể loại "', p_MaTheLoai, '" không tồn tại.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF p_DinhDang IS NOT NULL AND p_DinhDang NOT IN ('2D', '3D', 'IMAX') THEN
        SET v_msg = CONCAT('Lỗi: Định dạng "', p_DinhDang,
                           '" không hợp lệ (chỉ nhận 2D, 3D hoặc IMAX).');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF p_TuoiKhach IS NOT NULL AND (p_TuoiKhach < 0 OR p_TuoiKhach > 120) THEN
        SET v_msg = CONCAT('Lỗi: Tuổi khách hàng ', p_TuoiKhach,
                           ' không hợp lệ (phải từ 0 đến 120).');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    -- 3) Truy vấn
    SELECT  sc.MaSuatChieu,
            p.TuaDe,
            -- danh sách thể loại của phim, VD "Hành động, Tâm lý"
            (SELECT GROUP_CONCAT(tl.TenTheLoai ORDER BY tl.TenTheLoai SEPARATOR ', ')
             FROM THUOC_THE_LOAI ttl
             JOIN THE_LOAI tl ON tl.MaTheLoai = ttl.MaTheLoai
             WHERE ttl.MaPhim = p.MaPhim)                         AS TheLoai,
            p.GioiHanDoTuoi,
            r.TenRap,
            sc.MaPhong,
            sc.NgayChieu,
            sc.GioBatDau,
            sc.GioKetThuc,
            sc.DinhDang,
            sc.HinhThucNgonNgu,
            pc.SoGhe - IFNULL(dv.SoVeDaBan, 0)                    AS SoGheTrong,
            -- trạng thái bán vé theo RBNN 2 và RBNN 9
            CASE
                -- suất qua đêm (giờ kết thúc < giờ bắt đầu) kết thúc vào ngày hôm sau
                WHEN TIMESTAMP(sc.NgayChieu, sc.GioKetThuc)
                     + INTERVAL IF(sc.GioKetThuc < sc.GioBatDau, 1, 0) DAY < NOW()
                    THEN 'Đã chiếu'
                WHEN pc.SoGhe - IFNULL(dv.SoVeDaBan, 0) = 0
                    THEN 'Hết vé'
                WHEN NOW() > TIMESTAMP(sc.NgayChieu, sc.GioBatDau) + INTERVAL 15 MINUTE
                    THEN 'Ngừng bán trực tuyến'
                ELSE 'Còn vé'
            END                                                   AS TrangThai
    FROM SUAT_CHIEU sc
    JOIN PHIM        p  ON p.MaPhim = sc.MaPhim
    JOIN RAP_PHIM    r  ON r.MaRap  = sc.MaRap
    JOIN PHONG_CHIEU pc ON pc.MaRap = sc.MaRap AND pc.MaPhong = sc.MaPhong
    -- số vé đã bán của từng suất
    LEFT JOIN (SELECT MaSuatChieu, COUNT(*) AS SoVeDaBan
               FROM VE
               GROUP BY MaSuatChieu) dv ON dv.MaSuatChieu = sc.MaSuatChieu
    WHERE (p_TuKhoaPhim IS NULL OR p.TuaDe LIKE CONCAT('%', p_TuKhoaPhim, '%'))
      AND (p_MaRap      IS NULL OR sc.MaRap     = p_MaRap)
      AND (p_TuNgay     IS NULL OR sc.NgayChieu >= p_TuNgay)
      AND (p_DenNgay    IS NULL OR sc.NgayChieu <= p_DenNgay)
      AND (p_DinhDang   IS NULL OR sc.DinhDang  = p_DinhDang)
      -- lọc thể loại bằng EXISTS để phim nhiều thể loại không bị lặp dòng
      AND (p_MaTheLoai  IS NULL OR EXISTS (SELECT 1 FROM THUOC_THE_LOAI ttl
                                           WHERE ttl.MaPhim = p.MaPhim
                                             AND ttl.MaTheLoai = p_MaTheLoai))
      -- RBNN 3: đổi nhãn độ tuổi ra tuổi tối thiểu (P, K: mọi lứa tuổi)
      AND (p_TuoiKhach  IS NULL OR p_TuoiKhach >= CASE p.GioiHanDoTuoi
                                                      WHEN 'T13' THEN 13
                                                      WHEN 'T16' THEN 16
                                                      WHEN 'T18' THEN 18
                                                      ELSE 0
                                                  END)
      AND (p_ChiConGhe = FALSE OR pc.SoGhe - IFNULL(dv.SoVeDaBan, 0) > 0)
    ORDER BY sc.NgayChieu, sc.GioBatDau, r.TenRap;
END //


-- ---------------------------------------------------------------------
-- THỦ TỤC 2: Thống kê hiệu quả phim
-- Gom nhóm 2 cấp:
--   Cấp 1 (bảng tạm t): mỗi SUẤT CHIẾU -> số ghế phòng, số vé bán, doanh thu suất đó.
--          Dùng LEFT JOIN VE để suất không bán được vé nào vẫn được đếm (doanh thu 0).
--   Cấp 2: gom các suất theo PHIM -> tổng suất, tổng vé, tổng ghế, tỷ lệ lấp đầy, doanh thu.
-- Lý do phải gom 2 cấp: nếu JOIN thẳng PHONG_CHIEU với VE rồi SUM(SoGhe) thì số ghế
-- bị cộng lặp theo số vé -> tỷ lệ lấp đầy sai.
-- HAVING: chỉ giữ phim đạt doanh thu tối thiểu VÀ tỷ lệ lấp đầy tối thiểu.
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_ThongKeDoanhThuPhim //   -- tên cũ, xóa đi
DROP PROCEDURE IF EXISTS sp_ThongKeHieuQuaPhim //
CREATE PROCEDURE sp_ThongKeHieuQuaPhim(
    IN p_TuNgay             DATE,          -- bắt buộc
    IN p_DenNgay            DATE,          -- bắt buộc
    IN p_MaRap              VARCHAR(10),   -- NULL / '' = toàn hệ thống
    IN p_DoanhThuToiThieu   INT,           -- HAVING; NULL = 0
    IN p_TyLeLapDayToiThieu DECIMAL(5,2)   -- HAVING, đơn vị %; NULL = 0
)
BEGIN
    DECLARE v_msg VARCHAR(255);

    -- 1) Chuẩn hóa tham số
    SET p_MaRap              = NULLIF(TRIM(p_MaRap), '');
    SET p_DoanhThuToiThieu   = IFNULL(p_DoanhThuToiThieu, 0);
    SET p_TyLeLapDayToiThieu = IFNULL(p_TyLeLapDayToiThieu, 0);

    -- 2) Kiểm tra tham số đầu vào
    IF p_TuNgay IS NULL OR p_DenNgay IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Phải nhập đủ Từ ngày và Đến ngày để thống kê.';
    END IF;

    IF p_TuNgay > p_DenNgay THEN
        SET v_msg = CONCAT('Lỗi: Từ ngày (', p_TuNgay,
                           ') không được sau Đến ngày (', p_DenNgay, ').');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF p_MaRap IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM RAP_PHIM WHERE MaRap = p_MaRap) THEN
        SET v_msg = CONCAT('Lỗi: Mã rạp "', p_MaRap, '" không tồn tại.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF p_DoanhThuToiThieu < 0 THEN
        SET v_msg = CONCAT('Lỗi: Doanh thu tối thiểu không được âm (đang nhập ',
                           p_DoanhThuToiThieu, ').');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF p_TyLeLapDayToiThieu < 0 OR p_TyLeLapDayToiThieu > 100 THEN
        SET v_msg = CONCAT('Lỗi: Tỷ lệ lấp đầy tối thiểu phải từ 0 đến 100% (đang nhập ',
                           p_TyLeLapDayToiThieu, ').');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    -- 3) Truy vấn
    SELECT  p.MaPhim,
            p.TuaDe,
            COUNT(t.MaSuatChieu)                              AS SoSuatChieu,
            SUM(t.SoVe)                                       AS SoVeBan,
            SUM(t.SoGhe)                                      AS TongSoGhe,
            ROUND(SUM(t.SoVe) * 100 / SUM(t.SoGhe), 2)        AS TyLeLapDay,
            SUM(t.SoVeTrucTuyen)                              AS SoVeTrucTuyen,
            SUM(t.DoanhThu)                                   AS DoanhThuVe,
            ROUND(SUM(t.DoanhThu) / COUNT(t.MaSuatChieu))     AS DoanhThuTBMoiSuat,
            CASE
                WHEN SUM(t.SoVe) * 100 / SUM(t.SoGhe) >= 70 THEN 'Nên tăng suất chiếu'
                WHEN SUM(t.SoVe) * 100 / SUM(t.SoGhe) >= 40 THEN 'Giữ nguyên'
                ELSE 'Cân nhắc giảm suất chiếu'
            END                                               AS DeXuat
    FROM PHIM p
    JOIN (
        -- Cấp 1: thống kê theo từng suất chiếu
        SELECT  sc.MaSuatChieu,
                sc.MaPhim,
                pc.SoGhe,
                COUNT(v.MaVe)                         AS SoVe,
                SUM(CASE WHEN v.HinhThucMua = 'Trực tuyến'
                         THEN 1 ELSE 0 END)           AS SoVeTrucTuyen,
                IFNULL(SUM(v.GiaVe), 0)               AS DoanhThu
        FROM SUAT_CHIEU sc
        JOIN PHONG_CHIEU pc ON pc.MaRap = sc.MaRap AND pc.MaPhong = sc.MaPhong
        LEFT JOIN VE v      ON v.MaSuatChieu = sc.MaSuatChieu
        WHERE sc.NgayChieu BETWEEN p_TuNgay AND p_DenNgay
          AND (p_MaRap IS NULL OR sc.MaRap = p_MaRap)
        GROUP BY sc.MaSuatChieu, sc.MaPhim, pc.SoGhe
    ) t ON t.MaPhim = p.MaPhim
    -- Cấp 2: gom theo phim
    GROUP BY p.MaPhim, p.TuaDe
    HAVING DoanhThuVe >= p_DoanhThuToiThieu
       AND TyLeLapDay >= p_TyLeLapDayToiThieu
    ORDER BY DoanhThuVe DESC, TyLeLapDay DESC;
END //

DELIMITER ;


-- =====================================================================
-- CÂU LỆNH MINH HỌA KHI BÁO CÁO
-- Thứ tự tham số thủ tục 1:
--   (từ khóa, mã rạp, mã thể loại, từ ngày, đến ngày, định dạng, tuổi khách, chỉ còn ghế)
-- =====================================================================

-- ---- Thủ tục 1 ----
-- (a) Không lọc: toàn bộ suất chiếu, kèm thể loại, ghế trống, trạng thái
CALL sp_TimKiemSuatChieu(NULL, NULL, NULL, NULL, NULL, NULL, NULL, FALSE);
-- (b) Tìm không dấu: 'bo sua' -> "Bò sữa bay"
CALL sp_TimKiemSuatChieu('bo sua', NULL, NULL, NULL, NULL, NULL, NULL, FALSE);
-- (c) Khách 15 tuổi: ẩn các phim T16, T18 (RBNN 3)
CALL sp_TimKiemSuatChieu(NULL, NULL, NULL, NULL, NULL, NULL, 15, FALSE);
-- (d) Phim Tâm lý (TL03) tại rạp R01..R03 bất kỳ, chỉ suất còn ghế
CALL sp_TimKiemSuatChieu(NULL, NULL, 'TL03', NULL, NULL, NULL, NULL, TRUE);
-- (e) Rạp R01, ngày 02/12 - 03/12, định dạng 2D
CALL sp_TimKiemSuatChieu('', 'R01', '', '2026-12-02', '2026-12-03', '2D', NULL, FALSE);
-- Các trường hợp lỗi (bỏ dấu -- để chạy):
-- CALL sp_TimKiemSuatChieu(NULL, NULL, NULL, '2026-12-05', '2026-12-01', NULL, NULL, FALSE); -- ngày ngược
-- CALL sp_TimKiemSuatChieu(NULL, 'R99', NULL, NULL, NULL, NULL, NULL, FALSE);               -- rạp không có
-- CALL sp_TimKiemSuatChieu(NULL, NULL, 'TL99', NULL, NULL, NULL, NULL, FALSE);              -- thể loại không có
-- CALL sp_TimKiemSuatChieu(NULL, NULL, NULL, NULL, NULL, '4DX', NULL, FALSE);               -- định dạng sai
-- CALL sp_TimKiemSuatChieu(NULL, NULL, NULL, NULL, NULL, NULL, -3, FALSE);                  -- tuổi sai

-- ---- Thủ tục 2 ----
-- (a) Toàn hệ thống tháng 12/2026, không đặt ngưỡng
CALL sp_ThongKeHieuQuaPhim('2026-12-01', '2026-12-31', NULL, 0, 0);
-- (b) Chỉ phim có doanh thu >= 400.000đ (HAVING lọc bớt)
CALL sp_ThongKeHieuQuaPhim('2026-12-01', '2026-12-31', NULL, 400000, 0);
-- (c) Chỉ phim lấp đầy >= 60% ghế
CALL sp_ThongKeHieuQuaPhim('2026-12-01', '2026-12-31', NULL, 0, 60);
-- (d) Riêng rạp R02
CALL sp_ThongKeHieuQuaPhim('2026-12-01', '2026-12-31', 'R02', 0, 0);
-- Các trường hợp lỗi:
-- CALL sp_ThongKeHieuQuaPhim(NULL, '2026-12-31', NULL, 0, 0);              -- thiếu ngày
-- CALL sp_ThongKeHieuQuaPhim('2026-12-01', '2026-12-31', NULL, -5, 0);     -- doanh thu âm
-- CALL sp_ThongKeHieuQuaPhim('2026-12-01', '2026-12-31', NULL, 0, 150);    -- tỷ lệ > 100
