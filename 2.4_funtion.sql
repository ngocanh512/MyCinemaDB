
USE myCinemaDB;

DELIMITER $$

-- =====================================================================
-- Hàm tỷ lệ sử dụng phòng
-- fn_TyLeSuDungPhong(p_MaRap, p_MaPhong, p_Ngay)
--
-- Trả về % thời gian phòng được dùng trong giờ hoạt động của ngày p_Ngay.

DROP FUNCTION IF EXISTS fn_TyLeSuDungPhong$$

CREATE FUNCTION fn_TyLeSuDungPhong(
    p_MaRap   VARCHAR(10),
    p_MaPhong VARCHAR(10),
    p_Ngay    DATE
)
RETURNS DECIMAL(7,2)
READS SQL DATA
BEGIN

    -- 1. Khai báo thời gian hoạt động
    DECLARE v_gioMo INT DEFAULT 480;       -- 08:00
    DECLARE v_gioDong INT DEFAULT 1440;    -- 24:00
    DECLARE v_nghiToiThieu INT DEFAULT 15;

    -- 2. Biến con trỏ
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_bd INT;
    DECLARE v_kt INT;

    -- 3. Biến tính toán
    DECLARE v_soPhong INT DEFAULT 0;
    DECLARE v_tongPhut INT DEFAULT 0;
    DECLARE v_daTinhDen INT DEFAULT 480;

    DECLARE v_cuoiMax INT DEFAULT 0;
    DECLARE v_coSuatTruoc INT DEFAULT 0;

    DECLARE v_s INT;
    DECLARE v_e INT;
    DECLARE v_nghi INT;

    DECLARE v_soNghiNgan INT DEFAULT 0;
    DECLARE v_ghiChu VARCHAR(1000) DEFAULT NULL;

    DECLARE v_phutLo INT DEFAULT 0;
    DECLARE v_gioKetThucCuoi INT DEFAULT 1440;

    -- 4. Con trỏ duyệt suất chiếu trong ngày
    DECLARE cur_suat CURSOR FOR
        SELECT
            TIME_TO_SEC(GioBatDau) DIV 60,
            (TIME_TO_SEC(GioKetThuc) DIV 60)
            + CASE
                WHEN GioKetThuc < GioBatDau THEN 1440
                ELSE 0
              END
        FROM SUAT_CHIEU
        WHERE MaRap = p_MaRap
          AND MaPhong = p_MaPhong
          AND NgayChieu = p_Ngay
        ORDER BY GioBatDau ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    -- =========================================
    -- BƯỚC 1: KIỂM TRA THAM SỐ
    -- =========================================

    IF p_MaRap IS NULL OR TRIM(p_MaRap) = ''
       OR p_MaPhong IS NULL OR TRIM(p_MaPhong) = '' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mã rạp và mã phòng không được để trống';

    END IF;

    IF p_Ngay IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngày không được để NULL';

    END IF;

    SELECT COUNT(*)
    INTO v_soPhong
    FROM PHONG_CHIEU
    WHERE MaRap = p_MaRap
      AND MaPhong = p_MaPhong;

    IF v_soPhong = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phòng chiếu không tồn tại';

    END IF;

    -- =========================================
    -- BƯỚC 2: DUYỆT CÁC SUẤT CHIẾU
    -- =========================================

    OPEN cur_suat;

    lap_suat: LOOP

        FETCH cur_suat INTO v_bd, v_kt;

        IF v_done = 1 THEN
            LEAVE lap_suat;
        END IF;

        -- Nếu suất chiếu lố qua ngày hôm sau
        IF v_kt > 1440 THEN

            SET v_phutLo = v_kt - 1440;

        END IF;

        -- Kiểm tra khoảng nghỉ giữa hai suất
        IF v_coSuatTruoc = 1 THEN

            SET v_nghi = v_bd - v_cuoiMax;

            IF v_nghi < v_nghiToiThieu THEN

                SET v_soNghiNgan = v_soNghiNgan + 1;

                SET v_ghiChu = CONCAT_WS('; ',v_ghiChu,CONCAT('Khoảng nghỉ ',v_nghi,' phút'));

            END IF;

        END IF;

        -- Xác định đoạn thời gian cần tính
        SET v_s = GREATEST(v_bd, v_daTinhDen);

        -- Không giới hạn tại 24:00 vì cần tính cả phần lố
        SET v_e = v_kt;

        -- Cộng tổng số phút chiếu, tránh cộng trùng
        IF v_e > v_s THEN

            SET v_tongPhut = v_tongPhut + (v_e - v_s);

            SET v_daTinhDen = v_e;

        END IF;

        -- Cập nhật giờ kết thúc muộn nhất
        IF v_coSuatTruoc = 0 OR v_kt > v_cuoiMax THEN

            SET v_cuoiMax = v_kt;

        END IF;

        SET v_coSuatTruoc = 1;

    END LOOP lap_suat;

    CLOSE cur_suat;

    -- =========================================
    -- BƯỚC 3: XÁC ĐỊNH GIỜ KẾT THÚC
    -- =========================================

    IF v_cuoiMax > 1440 THEN

        SET v_gioKetThucCuoi = v_cuoiMax;

    ELSE

        SET v_gioKetThucCuoi = 1440;

    END IF;

    -- =========================================
    -- BƯỚC 4: GHI NHẬN THÔNG TIN PHỤ
    -- =========================================

    SET @tong_phut_chieu = v_tongPhut;

    SET @phut_lo_qua_ngay_sau = v_phutLo;

    SET @gio_ket_thuc_tinh = v_gioKetThucCuoi;

    SET @so_khoang_nghi_ngan = v_soNghiNgan;

    SET @chi_tiet_khoang_nghi =
        COALESCE(v_ghiChu, 'Không có');

    -- =========================================
    -- BƯỚC 5: TÍNH TỶ LỆ SỬ DỤNG PHÒNG
    -- =========================================

    RETURN ROUND(
        v_tongPhut * 100 / (v_gioKetThucCuoi - v_gioMo),
        2
    );

END$$



-- =====================================================================
-- Hàm tìm dãy ghế trống (giữ nguyên)
-- =====================================================================

DROP FUNCTION IF EXISTS fn_TimDayGheTrong$$

CREATE FUNCTION fn_TimDayGheTrong(
    p_MaSuatChieu VARCHAR(10),
    p_SoGhe       INT
)
RETURNS VARCHAR(10)
READS SQL DATA
BEGIN
    -- Biến phục vụ con trỏ
    DECLARE v_done   INT DEFAULT 0;
    DECLARE v_maGhe  VARCHAR(10);
    DECLARE v_hang   VARCHAR(10);
    DECLARE v_so     INT;
    DECLARE v_daBan  INT;

    -- Biến tính toán
    DECLARE v_soSuat     INT DEFAULT 0;
    DECLARE v_batDau     DATETIME;
    DECLARE v_hangTruoc  VARCHAR(10) DEFAULT NULL;
    DECLARE v_soTruoc    INT DEFAULT NULL;
    DECLARE v_dem        INT DEFAULT 0;        -- số ghế trống liền nhau đang đếm
    DECLARE v_gheDauDay  VARCHAR(10) DEFAULT NULL;
    DECLARE v_ketQua     VARCHAR(10) DEFAULT NULL;

    -- Con trỏ duyệt ghế của phòng theo hàng và số ghế,
    -- đối chiếu (LEFT JOIN) với vé đã bán của suất chiếu
    DECLARE cur_ghe CURSOR FOR
        SELECT g.MaGhe,
               LEFT(g.MaGhe, 1)                          AS Hang,
               CAST(SUBSTRING(g.MaGhe, 2) AS UNSIGNED)   AS So,
               (v.MaVe IS NOT NULL)                      AS DaBan
        FROM SUAT_CHIEU sc
        JOIN GHE g
          ON g.MaRap = sc.MaRap AND g.MaPhong = sc.MaPhong
        LEFT JOIN VE v
          ON v.MaSuatChieu = sc.MaSuatChieu
         AND v.MaRap = g.MaRap
         AND v.MaPhong = g.MaPhong
         AND v.MaGhe = g.MaGhe
        WHERE sc.MaSuatChieu = p_MaSuatChieu
        ORDER BY Hang, So;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- ---------- 1. KIỂM TRA THAM SỐ ĐẦU VÀO ----------
    IF p_MaSuatChieu IS NULL OR TRIM(p_MaSuatChieu) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mã suất chiếu không được để trống';
    END IF;

    IF p_SoGhe IS NULL OR p_SoGhe < 1 OR p_SoGhe > 10 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Số ghế phải nằm trong khoảng từ 1 đến 10';
    END IF;

    SELECT COUNT(*) INTO v_soSuat
    FROM SUAT_CHIEU
    WHERE MaSuatChieu = p_MaSuatChieu;

    IF v_soSuat = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Suất chiếu không tồn tại';
    END IF;

    SELECT TIMESTAMP(NgayChieu, GioBatDau) INTO v_batDau
    FROM SUAT_CHIEU
    WHERE MaSuatChieu = p_MaSuatChieu;

    IF v_batDau <= NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Suất chiếu đã bắt đầu hoặc đã chiếu xong';
    END IF;

    -- ---------- 2. DUYỆT CON TRỎ (LOOP) ----------
    OPEN cur_ghe;

    lap_ghe: LOOP
        FETCH cur_ghe INTO v_maGhe, v_hang, v_so, v_daBan;

        IF v_done = 1 THEN
            LEAVE lap_ghe;
        END IF;

        IF v_daBan = 1 THEN
            -- Ghế đã có vé: đứt dãy
            SET v_dem = 0;
            SET v_gheDauDay = NULL;
        ELSE
            IF v_hangTruoc IS NULL OR v_hang <> v_hangTruoc THEN
                -- Đổi sang hàng mới: đếm lại từ đầu
                SET v_dem = 1;
                SET v_gheDauDay = v_maGhe;
            ELSEIF v_dem > 0 AND v_so = v_soTruoc + 1 THEN
                -- Ghế trống liền kề ghế trước: kéo dài dãy
                SET v_dem = v_dem + 1;
            ELSE
                -- Ghế trước đã bán hoặc số ghế bị nhảy cóc: bắt đầu dãy mới
                SET v_dem = 1;
                SET v_gheDauDay = v_maGhe;
            END IF;
        END IF;

        SET v_hangTruoc = v_hang;
        SET v_soTruoc   = v_so;

        -- Đủ số ghế yêu cầu thì dừng
        IF v_dem >= p_SoGhe THEN
            SET v_ketQua = v_gheDauDay;
            LEAVE lap_ghe;
        END IF;
    END LOOP lap_ghe;

    CLOSE cur_ghe;

    RETURN v_ketQua;
END$$

DELIMITER ;


-- =====================================================================
-- HAM 1: fn_TyLeSuDungPhong  (ket qua la ty le % su dung phong)
-- =====================================================================
SELECT MaRap, MaPhong, Ngay, TyLe AS TyLeSuDung_Phantram
FROM (
    SELECT 1 AS STT, 'R01' AS MaRap, 'P01' AS MaPhong, CAST('2026-12-01' AS DATE) AS Ngay,
           fn_TyLeSuDungPhong('R01','P01','2026-12-01') AS TyLe
    UNION ALL SELECT 2,  'R02','P02', '2026-12-01', fn_TyLeSuDungPhong('R02','P02','2026-12-01')
    UNION ALL SELECT 3,  'R03','P03', '2026-12-01', fn_TyLeSuDungPhong('R03','P03','2026-12-01')
    UNION ALL SELECT 4,  'R04','P04', '2026-12-01', fn_TyLeSuDungPhong('R04','P04','2026-12-01')
    UNION ALL SELECT 5,  'R05','P05', '2026-12-01', fn_TyLeSuDungPhong('R05','P05','2026-12-01')
    UNION ALL SELECT 6,  'R01','P01', '2026-12-02', fn_TyLeSuDungPhong('R01','P01','2026-12-02')
    UNION ALL SELECT 7,  'R02','P02', '2026-12-02', fn_TyLeSuDungPhong('R02','P02','2026-12-02')
    UNION ALL SELECT 8,  'R03','P03', '2026-12-02', fn_TyLeSuDungPhong('R03','P03','2026-12-02')
    UNION ALL SELECT 9,  'R04','P04', '2026-12-02', fn_TyLeSuDungPhong('R04','P04','2026-12-02')
    UNION ALL SELECT 10, 'R05','P05', '2026-12-02', fn_TyLeSuDungPhong('R05','P05','2026-12-02')
    UNION ALL SELECT 11, 'R05','P05', '2026-12-03', fn_TyLeSuDungPhong('R05','P05','2026-12-03')
) t
ORDER BY STT;

-- =====================================================================
-- HAM 2: fn_TimDayGheTrong  (ket qua la ma ghe dau day, NULL neu khong co)
-- =====================================================================

-- 2.1 Suat nam 2030 (luon chay duoc)
SELECT sc.MaRap, sc.MaPhong, sc.NgayChieu AS Ngay, sc.MaSuatChieu, c.SoGhe AS SoGheCanTim,
       fn_TimDayGheTrong(c.MaSuatChieu, c.SoGhe) AS GheDauDay
FROM (
    SELECT 1 AS STT, 'SC021' AS MaSuatChieu, 1 AS SoGhe
    UNION ALL SELECT 2,  'SC021', 2
    UNION ALL SELECT 3,  'SC021', 3
    UNION ALL SELECT 4,  'SC021', 4
    UNION ALL SELECT 5,  'SC021', 5
    UNION ALL SELECT 6,  'SC022', 5
    UNION ALL SELECT 7,  'SC022', 6
) c
JOIN SUAT_CHIEU sc ON sc.MaSuatChieu = c.MaSuatChieu
ORDER BY c.STT;

-- 2.2 Suat du lieu goc ngay 01/12/2026 (chi chay duoc TRUOC ngay 01/12/2026,
--     sau ngay do ham bao loi suat da chieu -> bo qua phan nay)
SELECT sc.MaRap, sc.MaPhong, sc.NgayChieu AS Ngay, sc.MaSuatChieu, c.SoGhe AS SoGheCanTim,
       fn_TimDayGheTrong(c.MaSuatChieu, c.SoGhe) AS GheDauDay
FROM (
    SELECT 1 AS STT, 'SC001' AS MaSuatChieu, 1 AS SoGhe
    UNION ALL SELECT 2, 'SC001', 2
    UNION ALL SELECT 3, 'SC001', 3
    UNION ALL SELECT 4, 'SC002', 3
    UNION ALL SELECT 5, 'SC004', 1
    UNION ALL SELECT 6, 'SC004', 2
) c
JOIN SUAT_CHIEU sc ON sc.MaSuatChieu = c.MaSuatChieu
ORDER BY c.STT;

COMMIT;
