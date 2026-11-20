USE myCinemaDB;

DROP PROCEDURE IF EXISTS sp_ThemSuatChieu;
DROP PROCEDURE IF EXISTS sp_SuaSuatChieu;
DROP PROCEDURE IF EXISTS sp_XoaSuatChieu;
DROP PROCEDURE IF EXISTS sp_KiemTraSuatChieu;

DELIMITER $$

-- Called within the transaction opened by the add or update procedure.
CREATE PROCEDURE sp_KiemTraSuatChieu(
    IN p_MaSuatChieu TEXT, IN p_NgayChieu DATE,
    IN p_GioBatDau TIME, IN p_GioKetThuc TIME,
    IN p_DinhDang TEXT, IN p_HinhThucNgonNgu TEXT,
    IN p_MaPhim TEXT, IN p_MaRap TEXT, IN p_MaPhong TEXT,
    IN p_MaQuanLy TEXT, IN p_Sua BOOLEAN
)
BEGIN
    DECLARE v_Phong VARCHAR(10);
    DECLARE v_BatDau DATETIME;
    DECLARE v_KetThuc DATETIME;

    IF p_MaSuatChieu IS NULL OR CHAR_LENGTH(TRIM(p_MaSuatChieu)) NOT BETWEEN 1 AND 10
       OR CHAR_LENGTH(p_MaSuatChieu) > 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã suất chiếu phải có từ 1 đến 10 ký tự.';
    END IF;
    IF NOT p_Sua AND EXISTS (SELECT 1 FROM SUAT_CHIEU WHERE MaSuatChieu = p_MaSuatChieu) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã suất chiếu đã tồn tại.';
    END IF;
    IF p_NgayChieu IS NULL OR YEAR(p_NgayChieu) < 1000
       OR MONTH(p_NgayChieu) = 0 OR DAY(p_NgayChieu) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày chiếu phải là ngày hợp lệ.';
    END IF;
    IF p_GioBatDau IS NULL OR p_GioKetThuc IS NULL
       OR p_GioBatDau NOT BETWEEN '00:00:00' AND '23:59:59'
       OR p_GioKetThuc NOT BETWEEN '00:00:00' AND '23:59:59'
       OR p_GioBatDau = p_GioKetThuc THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giờ bắt đầu và giờ kết thúc phải là hai giờ hợp lệ khác nhau.';
    END IF;
    IF p_DinhDang IS NULL OR p_DinhDang NOT IN ('2D', '3D') OR CHAR_LENGTH(p_DinhDang) > 20 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Định dạng chiếu phải là 2D hoặc 3D.';
    END IF;
    IF p_HinhThucNgonNgu IS NULL OR p_HinhThucNgonNgu NOT IN ('Lồng tiếng', 'Phụ đề')
       OR CHAR_LENGTH(p_HinhThucNgonNgu) > 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hình thức ngôn ngữ phải là Lồng tiếng hoặc Phụ đề.';
    END IF;
    IF p_MaPhim IS NULL OR CHAR_LENGTH(p_MaPhim) > 10
       OR NOT EXISTS (SELECT 1 FROM PHIM WHERE MaPhim = p_MaPhim) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã phim không hợp lệ hoặc phim không tồn tại.';
    END IF;
    IF p_MaRap IS NULL OR p_MaPhong IS NULL
       OR CHAR_LENGTH(p_MaRap) > 10 OR CHAR_LENGTH(p_MaPhong) > 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã rạp và mã phòng phải có tối đa 10 ký tự.';
    END IF;

    -- Serialize schedule changes for the same room.
    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Phong = NULL;
        SELECT MaPhong INTO v_Phong
        FROM PHONG_CHIEU
        WHERE MaRap = p_MaRap AND MaPhong = p_MaPhong
        FOR UPDATE;
    END;
    IF v_Phong IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng chiếu không tồn tại trong rạp đã chọn.';
    END IF;
    IF p_MaQuanLy IS NOT NULL AND (CHAR_LENGTH(p_MaQuanLy) > 10
       OR NOT EXISTS (SELECT 1 FROM QUAN_TRI_VIEN WHERE MaNhanVien = p_MaQuanLy)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã quản lý không hợp lệ hoặc quản trị viên không tồn tại.';
    END IF;

    -- An end time earlier than the start time belongs to the following day.
    SET v_BatDau = TIMESTAMP(p_NgayChieu, p_GioBatDau);
    SET v_KetThuc = TIMESTAMP(p_NgayChieu, p_GioKetThuc);
    IF p_GioKetThuc < p_GioBatDau THEN
        SET v_KetThuc = DATE_ADD(v_KetThuc, INTERVAL 1 DAY);
    END IF;

    IF EXISTS (
        SELECT 1
        FROM SUAT_CHIEU AS sc
        WHERE sc.MaRap = p_MaRap AND sc.MaPhong = p_MaPhong
          AND (NOT p_Sua OR sc.MaSuatChieu <> p_MaSuatChieu)
          AND TIMESTAMP(sc.NgayChieu, sc.GioBatDau) < DATE_ADD(v_KetThuc, INTERVAL 15 MINUTE)
          AND DATE_ADD(
              TIMESTAMP(sc.NgayChieu, sc.GioKetThuc),
              INTERVAL IF(sc.GioKetThuc < sc.GioBatDau, 1, 0) DAY
          ) > DATE_SUB(v_BatDau, INTERVAL 15 MINUTE)
        FOR UPDATE
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Các suất cùng phòng phải cách nhau ít nhất 15 phút.';
    END IF;
END$$

-- These three entry points manage their own transactions.
CREATE PROCEDURE sp_ThemSuatChieu(
    IN p_MaSuatChieu TEXT, IN p_NgayChieu DATE,
    IN p_GioBatDau TIME, IN p_GioKetThuc TIME,
    IN p_DinhDang TEXT, IN p_HinhThucNgonNgu TEXT,
    IN p_MaPhim TEXT, IN p_MaRap TEXT, IN p_MaPhong TEXT,
    IN p_MaQuanLy TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã suất chiếu đã tồn tại.';
    END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    CALL sp_KiemTraSuatChieu(p_MaSuatChieu, p_NgayChieu, p_GioBatDau, p_GioKetThuc,
        p_DinhDang, p_HinhThucNgonNgu, p_MaPhim, p_MaRap, p_MaPhong, p_MaQuanLy, FALSE);

    INSERT INTO SUAT_CHIEU (MaSuatChieu, NgayChieu, GioBatDau, GioKetThuc, DinhDang,
        HinhThucNgonNgu, MaPhim, MaRap, MaPhong, MaQuanLy)
    VALUES (p_MaSuatChieu, p_NgayChieu, p_GioBatDau, p_GioKetThuc, p_DinhDang,
        p_HinhThucNgonNgu, p_MaPhim, p_MaRap, p_MaPhong, p_MaQuanLy);
    COMMIT;
END$$

CREATE PROCEDURE sp_SuaSuatChieu(
    IN p_MaSuatChieu TEXT, IN p_NgayChieu DATE,
    IN p_GioBatDau TIME, IN p_GioKetThuc TIME,
    IN p_DinhDang TEXT, IN p_HinhThucNgonNgu TEXT,
    IN p_MaPhim TEXT, IN p_MaRap TEXT, IN p_MaPhong TEXT,
    IN p_MaQuanLy TEXT
)
BEGIN
    DECLARE v_MaSuatChieu VARCHAR(10);
    DECLARE v_ThayDoiThongTinVe BOOLEAN;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_MaSuatChieu = NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT MaSuatChieu,
           NOT (NgayChieu <=> p_NgayChieu AND GioBatDau <=> p_GioBatDau
                AND GioKetThuc <=> p_GioKetThuc AND MaPhim <=> p_MaPhim
                AND MaRap <=> p_MaRap AND MaPhong <=> p_MaPhong
                AND DinhDang <=> p_DinhDang AND HinhThucNgonNgu <=> p_HinhThucNgonNgu)
    INTO v_MaSuatChieu, v_ThayDoiThongTinVe
    FROM SUAT_CHIEU
    WHERE MaSuatChieu = p_MaSuatChieu
    FOR UPDATE;

    IF v_MaSuatChieu IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tìm thấy suất chiếu cần sửa.';
    END IF;

    CALL sp_KiemTraSuatChieu(p_MaSuatChieu, p_NgayChieu, p_GioBatDau, p_GioKetThuc,
        p_DinhDang, p_HinhThucNgonNgu, p_MaPhim, p_MaRap, p_MaPhong, p_MaQuanLy, TRUE);

    IF v_ThayDoiThongTinVe AND EXISTS (
        SELECT 1 FROM VE WHERE MaSuatChieu = p_MaSuatChieu FOR UPDATE
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suất đã có vé. Chỉ được cập nhật mã quản lý.';
    END IF;

    UPDATE SUAT_CHIEU
    SET NgayChieu = p_NgayChieu, GioBatDau = p_GioBatDau, GioKetThuc = p_GioKetThuc,
        DinhDang = p_DinhDang, HinhThucNgonNgu = p_HinhThucNgonNgu, MaPhim = p_MaPhim,
        MaRap = p_MaRap, MaPhong = p_MaPhong, MaQuanLy = p_MaQuanLy
    WHERE MaSuatChieu = p_MaSuatChieu;
    COMMIT;
END$$

CREATE PROCEDURE sp_XoaSuatChieu(IN p_MaSuatChieu TEXT)
BEGIN
    DECLARE EXIT HANDLER FOR 1451
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể xóa suất chiếu đã phát hành vé.';
    END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    DELETE FROM SUAT_CHIEU WHERE MaSuatChieu = p_MaSuatChieu;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tìm thấy suất chiếu cần xóa.';
    END IF;
    COMMIT;
END$$

DELIMITER ;
