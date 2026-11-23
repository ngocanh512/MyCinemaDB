DROP TRIGGER IF EXISTS BI_SUAT_CHIEU_CACH_NHAU_15P;
DELIMITER $$
CREATE TRIGGER BI_SUAT_CHIEU_CACH_NHAU_15P
BEFORE INSERT ON SUAT_CHIEU
FOR EACH ROW
BEGIN
    DECLARE v_BatDau DATETIME;
    DECLARE v_KetThuc DATETIME;
    
    SET v_BatDau = TIMESTAMP(NEW.NgayChieu, NEW.GioBatDau);
    
    SET v_KetThuc = DATE_ADD(
        TIMESTAMP(NEW.NgayChieu, NEW.GioKetThuc),
        INTERVAL IF(NEW.GioKetThuc < NEW.GioBatDau, 1, 0) DAY
    );
    
    IF EXISTS (
        SELECT 1
        FROM SUAT_CHIEU AS SC
        WHERE SC.MaRap = NEW.MaRap
          AND SC.MaPhong = NEW.MaPhong

          AND SC.NgayChieu BETWEEN
              DATE_SUB(NEW.NgayChieu, INTERVAL 1 DAY)
              AND DATE_ADD(NEW.NgayChieu, INTERVAL 1 DAY)

          AND TIMESTAMP(SC.NgayChieu, SC.GioBatDau)
              < DATE_ADD(v_KetThuc, INTERVAL 15 MINUTE)

          AND DATE_ADD(
              TIMESTAMP(SC.NgayChieu, SC.GioKetThuc),
              INTERVAL IF(SC.GioKetThuc < SC.GioBatDau, 1, 0) DAY
          ) > DATE_SUB(v_BatDau, INTERVAL 15 MINUTE)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Các suất cùng phòng phải cách nhau ít nhất 15 phút.';
    END IF;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS BU_SUAT_CHIEU_CACH_NHAU_15P;
DELIMITER $$
CREATE TRIGGER BU_SUAT_CHIEU_CACH_NHAU_15P
BEFORE UPDATE ON SUAT_CHIEU
FOR EACH ROW
BEGIN
    DECLARE v_BatDau DATETIME;
    DECLARE v_KetThuc DATETIME;

    SET v_BatDau = TIMESTAMP(NEW.NgayChieu, NEW.GioBatDau);

    SET v_KetThuc = DATE_ADD(
        TIMESTAMP(NEW.NgayChieu, NEW.GioKetThuc),
        INTERVAL IF(NEW.GioKetThuc < NEW.GioBatDau, 1, 0) DAY
    );

    IF EXISTS (
        SELECT 1
        FROM SUAT_CHIEU AS SC
        WHERE SC.MaRap = NEW.MaRap
          AND SC.MaPhong = NEW.MaPhong

          AND SC.MaSuatChieu <> OLD.MaSuatChieu

          AND SC.NgayChieu BETWEEN
              DATE_SUB(NEW.NgayChieu, INTERVAL 1 DAY)
              AND DATE_ADD(NEW.NgayChieu, INTERVAL 1 DAY)

          AND TIMESTAMP(SC.NgayChieu, SC.GioBatDau)
              < DATE_ADD(v_KetThuc, INTERVAL 15 MINUTE)

          AND DATE_ADD(
              TIMESTAMP(SC.NgayChieu, SC.GioKetThuc),
              INTERVAL IF(SC.GioKetThuc < SC.GioBatDau, 1, 0) DAY
          ) > DATE_SUB(v_BatDau, INTERVAL 15 MINUTE)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Các suất cùng phòng phải cách nhau ít nhất 15 phút.';
    END IF;
END$$
DELIMITER ;