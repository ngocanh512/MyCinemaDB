USE myCinemaDB;

DROP TRIGGER IF EXISTS BI_VE_CUNG_SUAT_CHIEU;
DROP TRIGGER IF EXISTS BU_VE_CUNG_SUAT_CHIEU;

DELIMITER $$

-- Trigger kiểm tra vé cùng suất chiếu trước khi thêm vé.
CREATE TRIGGER BI_VE_CUNG_SUAT_CHIEU
BEFORE INSERT ON VE
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM VE
        WHERE MaHoaDon = NEW.MaHoaDon
          AND MaSuatChieu <> NEW.MaSuatChieu
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Các vé trong cùng hóa đơn phải thuộc cùng một suất chiếu.';
    END IF;
END$$

-- Trigger kiểm tra vé cùng suất chiếu trước khi cập nhật vé.
CREATE TRIGGER BU_VE_CUNG_SUAT_CHIEU
BEFORE UPDATE ON VE
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM VE
        WHERE MaHoaDon = NEW.MaHoaDon
          AND MaSuatChieu <> NEW.MaSuatChieu
          AND MaVe <> OLD.MaVe
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Các vé trong cùng hóa đơn phải thuộc cùng một suất chiếu.';
    END IF;
END$$

DELIMITER ;
