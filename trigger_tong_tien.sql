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
    DECLARE vTongVeThuHai DECIMAL(18, 0) DEFAULT 0;
    DECLARE vTongCombo DECIMAL(18, 0) DEFAULT 0;
    DECLARE vNgayThanhToan DATE;
    DECLARE vPhuongThucThanhToan VARCHAR(50);
    DECLARE vLaHSSV BOOLEAN;
    DECLARE vGiamThuHai DECIMAL(18, 0) DEFAULT 0;
    DECLARE vGiamCombo DECIMAL(18, 0) DEFAULT 0;
    DECLARE vGiamHSSV DECIMAL(18, 0) DEFAULT 0;
    DECLARE vTienGiam DECIMAL(18, 0) DEFAULT 0;
    DECLARE vMaKhuyenMai VARCHAR(10) DEFAULT NULL;

    -- 2. Dùng ngày thanh toán của hóa đơn.
    IF NOT EXISTS (SELECT 1 FROM HOA_DON WHERE MaHoaDon = p_MaHoaDon) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không tìm thấy hóa đơn cần tính tiền.';
    END IF;

    SELECT DATE(hd.ThoiGian), hd.PhuongThucThanhToan, kh.LaHSSV
    INTO vNgayThanhToan, vPhuongThucThanhToan, vLaHSSV
    FROM HOA_DON AS hd
    JOIN KHACH_HANG AS kh ON kh.MaKhachHang = hd.MaKhachHang
    WHERE hd.MaHoaDon = p_MaHoaDon;

    -- 3. Tính tiền vé gốc và riêng tiền vé có NGÀY CHIẾU vào thứ Hai.
    -- DAYOFWEEK: Chủ nhật = 1, thứ Hai = 2, ..., thứ Bảy = 7.
    SELECT COALESCE(SUM(v.GiaVe), 0),
           COALESCE(SUM(CASE WHEN DAYOFWEEK(sc.NgayChieu) = 2
                             THEN v.GiaVe ELSE 0 END), 0)
    INTO vTongVe, vTongVeThuHai
    FROM VE AS v
    JOIN SUAT_CHIEU AS sc
      ON sc.MaSuatChieu = v.MaSuatChieu
     AND sc.MaRap = v.MaRap
     AND sc.MaPhong = v.MaPhong
    WHERE v.MaHoaDon = p_MaHoaDon;

    -- 4. Tính tiền sản phẩm 
    SELECT COALESCE(SUM(bg.SoLuong * bg.DonGia), 0),
           COALESCE(SUM(CASE WHEN bg.MaSanPham IN ('SP001', 'SP002')
                             THEN bg.SoLuong * bg.DonGia ELSE 0 END), 0)
    INTO vTongSanPham, vTongCombo
    FROM BAO_GOM AS bg
    WHERE bg.MaHoaDon = p_MaHoaDon;

    -- 5. Tính tiền giảm của 3 Khuyến mãi
    SELECT
        COALESCE(MAX(CASE
            WHEN km.MaKhuyenMai = 'KM001' AND km.PhamViApDung = 'VE'
            THEN ROUND(vTongVeThuHai * km.TyLeGiam / 100, 0)
            ELSE 0 END), 0),
        COALESCE(MAX(CASE
            WHEN km.MaKhuyenMai = 'KM003' AND km.PhamViApDung = 'COMBO'
             AND vPhuongThucThanhToan IN ('Thẻ ngân hàng', 'Ví điện tử')
            THEN ROUND(vTongCombo * km.TyLeGiam / 100, 0)
            ELSE 0 END), 0),
        COALESCE(MAX(CASE
            WHEN km.MaKhuyenMai = 'KM004' AND km.PhamViApDung = 'VE'
             AND vLaHSSV = TRUE
            THEN ROUND(vTongVe * km.TyLeGiam / 100, 0)
            ELSE 0 END), 0)
    INTO vGiamThuHai, vGiamCombo, vGiamHSSV
    FROM KHUYEN_MAI AS km
    WHERE vNgayThanhToan BETWEEN km.NgayBatDau AND km.NgayKetThuc
      AND km.TyLeGiam BETWEEN 0 AND 100;

    -- 6. Chỉ chọn MỘT chương trình giảm nhiều tiền nhất.
    -- Nếu bằng nhau: KM001 trước KM003 trước KM004.
    IF vGiamThuHai > vTienGiam THEN
        SET vTienGiam = vGiamThuHai;
        SET vMaKhuyenMai = 'KM001';
    END IF;

    IF vGiamCombo > vTienGiam THEN
        SET vTienGiam = vGiamCombo;
        SET vMaKhuyenMai = 'KM003';
    END IF;

    IF vGiamHSSV > vTienGiam THEN
        SET vTienGiam = vGiamHSSV;
        SET vMaKhuyenMai = 'KM004';
    END IF;

    -- 7. Không sửa GIÁ BÁN; lưu mã, tiền giảm và số tiền thực trả trên HOA_DON.
    -- Hóa đơn rỗng hoặc không được giảm: MaKhuyenMai = NULL, TienGiam = 0.
    UPDATE HOA_DON
    SET MaKhuyenMai = vMaKhuyenMai,
        TienGiam = vTienGiam,
        TongTien = vTongVe + vTongSanPham - vTienGiam
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
