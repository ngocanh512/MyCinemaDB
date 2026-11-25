SET NAMES utf8mb4;
USE myCinemaDB;

DROP TRIGGER IF EXISTS THEM_VE;
DROP TRIGGER IF EXISTS SUA_VE;
DROP TRIGGER IF EXISTS XOA_VE;
DROP TRIGGER IF EXISTS THEM_SANPHAM;
DROP TRIGGER IF EXISTS SUA_SANPHAM;
DROP TRIGGER IF EXISTS XOA_SANPHAM;
DROP PROCEDURE IF EXISTS TinhLaiTongTien;

DELIMITER $$


CREATE PROCEDURE TinhLaiTongTien(
    IN p_MaHoaDon VARCHAR(10)
)
BEGIN
    -- 1. Biến chỉ dùng trong lần tính hóa đơn này; không thêm cột vào VE/BAO_GOM.
    DECLARE vTongVe DECIMAL(18, 0) DEFAULT 0;
    DECLARE vTongSanPham DECIMAL(18, 0) DEFAULT 0;
    DECLARE vCoVeThuHai BOOLEAN DEFAULT FALSE;
    DECLARE vTongTruocGiam DECIMAL(18, 0) DEFAULT 0;
    DECLARE vNgayThanhToan DATE;
    DECLARE vPhuongThucThanhToan VARCHAR(50);
    DECLARE vLaHSSV BOOLEAN;
    DECLARE vTienGiam DECIMAL(18, 0) DEFAULT 0;
    DECLARE vMaKhuyenMai VARCHAR(10) DEFAULT NULL;
    -- Không tìm được chương trình hợp lệ: giữ trạng thái không giảm.
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET vMaKhuyenMai = NULL, vTienGiam = 0;

    -- 2. Xác định điều kiện HSSV
    IF NOT EXISTS (
        SELECT 1 
        FROM HOA_DON 
        WHERE MaHoaDon = p_MaHoaDon
        ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không tìm thấy hóa đơn cần tính tiền.';
    END IF;

    SELECT DATE(hd.ThoiGian), hd.PhuongThucThanhToan, kh.LaHSSV
    INTO vNgayThanhToan, vPhuongThucThanhToan, vLaHSSV
    FROM HOA_DON AS hd
    JOIN KHACH_HANG AS kh ON kh.MaKhachHang = hd.MaKhachHang
    WHERE hd.MaHoaDon = p_MaHoaDon;

    -- 3. Tính tổng tiền trước giảm
    SELECT COALESCE(SUM(v.GiaVe), 0),
           COALESCE(MAX(DAYOFWEEK(sc.NgayChieu) = 2), FALSE)
    INTO vTongVe, vCoVeThuHai
    FROM VE AS v
    JOIN SUAT_CHIEU AS sc
      ON sc.MaSuatChieu = v.MaSuatChieu
     AND sc.MaRap = v.MaRap AND sc.MaPhong = v.MaPhong
    WHERE v.MaHoaDon = p_MaHoaDon;

    SELECT COALESCE(SUM(bg.SoLuong * bg.DonGia), 0)
    INTO vTongSanPham
    FROM BAO_GOM AS bg
    WHERE bg.MaHoaDon = p_MaHoaDon;

    SET vTongTruocGiam = vTongVe + vTongSanPham;

    -- 4. Đặt lại kết quả; hóa đơn rỗng/không được giảm có mã NULL, tiền giảm 0.
    SET vMaKhuyenMai = NULL, vTienGiam = 0;

    IF vTongTruocGiam > 0 THEN
        -- Tính tiền giảm của khuyến mãi và chọn ra KM giảm nhiều tiền nhất
        SELECT km.MaKhuyenMai,
               ROUND(vTongTruocGiam * km.TyLeGiam / 100, 0)
        INTO vMaKhuyenMai, vTienGiam
        FROM KHUYEN_MAI AS km
        WHERE km.LoaiKhuyenMai = 'Giảm giá'   
          AND vNgayThanhToan BETWEEN km.NgayBatDau AND km.NgayKetThuc
          AND km.TyLeGiam > 0 AND km.TyLeGiam <= 100
          AND (
              (km.DieuKien = 'Thứ Hai' AND vCoVeThuHai = TRUE)
              OR (km.DieuKien = 'HSSV' AND vLaHSSV = TRUE)
              OR (km.DieuKien = 'Thẻ/Ví'
                  AND vPhuongThucThanhToan IN ('Thẻ ngân hàng', 'Ví điện tử'))
          )
          AND ROUND(vTongTruocGiam * km.TyLeGiam / 100, 0) > 0
        ORDER BY ROUND(vTongTruocGiam * km.TyLeGiam / 100, 0) DESC,
                 km.MaKhuyenMai ASC
        LIMIT 1;
    END IF;

    -- 5. Lưu tiền giảm và số tiền phải trả; không sửa giá bán.
    UPDATE HOA_DON
    SET MaKhuyenMai = vMaKhuyenMai,
        TienGiam = vTienGiam,
        TongTien = vTongTruocGiam - vTienGiam
    WHERE MaHoaDon = p_MaHoaDon;
END$$

-- Trigger THÊM VÉ
CREATE TRIGGER THEM_VE 
AFTER INSERT ON VE
FOR EACH ROW
BEGIN
    CALL TinhLaiTongTien(NEW.MaHoaDon);
END$$
-- Trigger SỬA VÉ
CREATE TRIGGER SUA_VE
AFTER UPDATE ON VE
FOR EACH ROW
BEGIN
    CALL TinhLaiTongTien(OLD.MaHoaDon);
    IF NOT (OLD.MaHoaDon <=> NEW.MaHoaDon) THEN
        CALL TinhLaiTongTien(NEW.MaHoaDon);
    END IF;
END$$
-- Trigger XÓA VÉ
CREATE TRIGGER XOA_VE 
AFTER DELETE ON VE
FOR EACH ROW
BEGIN
    CALL TinhLaiTongTien(OLD.MaHoaDon);
END$$

-- Trigger THÊM SẢN PHẨM
CREATE TRIGGER THEM_SANPHAM 
AFTER INSERT ON BAO_GOM
FOR EACH ROW
BEGIN
    CALL TinhLaiTongTien(NEW.MaHoaDon);
END$$
-- Trigger SỬA SẢN PHẨM
CREATE TRIGGER SUA_SANPHAM 
AFTER UPDATE ON BAO_GOM
FOR EACH ROW
BEGIN
    CALL TinhLaiTongTien(OLD.MaHoaDon);
    IF NOT (OLD.MaHoaDon <=> NEW.MaHoaDon) THEN
        CALL TinhLaiTongTien(NEW.MaHoaDon);
    END IF;
END$$
-- Trigger XÓA SẢN PHẨM
CREATE TRIGGER XOA_SANPHAM 
AFTER DELETE ON BAO_GOM
FOR EACH ROW
BEGIN
    CALL TinhLaiTongTien(OLD.MaHoaDon);
END$$

DELIMITER ;
