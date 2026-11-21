CREATE DATABASE myCinemaDB;

USE myCinemaDB;

-- 1. Bảng RAP_PHIM
CREATE TABLE RAP_PHIM(
	MaRap VARCHAR(10) PRIMARY KEY,
    TenRap VARCHAR(100) NOT NULL,
    DiaChi VARCHAR(255) NOT NULL,
    Hotline VARCHAR(15) NOT NULL,
		CONSTRAINT cnm_hotline
        CHECK (Hotline REGEXP '^[0-9]{8,11}$'),
    MaQuanLy VARCHAR(10)
);

-- 2. Bảng PHIM
CREATE TABLE PHIM(
	MaPhim VARCHAR(10) PRIMARY KEY,
    TuaDe VARCHAR(255) NOT NULL,
    ThoiLuong INT NOT NULL,
		CONSTRAINT cnm_thoiluong
		CHECK (ThoiLuong > 0),
    MoTa TEXT,
    GioiHanDoTuoi VARCHAR(10),
		CONSTRAINT cnm_dotuoi
		CHECK (GioiHanDoTuoi IN ('P', 'K', 'T13', 'T16', 'T18')),
    NgayKhoiChieu DATE,
    MaQuanLy VARCHAR(10)
);


-- 3. Bang THE_LOAI
CREATE TABLE THE_LOAI(
	MaTheLoai VARCHAR(10) PRIMARY KEY,
    TenTheLoai VARCHAR(100) NOT NULL UNIQUE
);

-- 4. Bang SAN_PHAM
CREATE TABLE SAN_PHAM(
	MaSanPham VARCHAR(10) PRIMARY KEY,
    TenSanPham VARCHAR(100) NOT NULL,
    GiaBan INT NOT NULL,
		CONSTRAINT cnm_giaban
		CHECK (GiaBan > 0),
    SoLuongTon INT NOT NULL DEFAULT 0,
		CONSTRAINT cnm_soluongton
		CHECK (SoLuongTon >= 0)
);

-- 5. Bang KHUYEN_MAI
CREATE TABLE KHUYEN_MAI(
	MaKhuyenMai VARCHAR(10) PRIMARY KEY,
    TenChuongTrinh VARCHAR(100) NOT NULL,
    NgayBatDau DATE,
    NgayKetThuc DATE,
    LoaiKhuyenMai VARCHAR(50), 
    DieuKien TEXT,
    CONSTRAINT cnm_ngay
		CHECK(NgayKetThuc >= NgayBatDau)
);

-- 6. Bang KHACH_HANG
CREATE TABLE KHACH_HANG(
	MaKhachHang VARCHAR(10) PRIMARY KEY,
    Ten VARCHAR(100) NOT NULL,
    GioiTinh VARCHAR(10),
		CONSTRAINT cnm_gioitinhkhach
        CHECK (GioiTinh IN ('Nam', 'Nữ', 'Khác')),
    NgaySinh DATE,
    SoDienThoai VARCHAR(10) UNIQUE,
		CONSTRAINT cnm_sdt
        CHECK(SoDienThoai REGEXP '^0[0-9]{9}$'),
    Email VARCHAR(100) UNIQUE,
		CONSTRAINT cnm_email
        CHECK (Email LIKE '_%@gmail.com')
);

-- 7. Bang CA_LAM_VIEC
CREATE TABLE CA_LAM_VIEC(
	MaCa VARCHAR(10) PRIMARY KEY,
    TenCa VARCHAR(100) NOT NULL,
    GioBatDau TIME NOT NULL,
    GioKetThuc TIME NOT NULL,
    CONSTRAINT cnm_giolamviec
    CHECK (GioKetThuc <> GioBatDau)
);

-- 8. Bang TAI_KHOAN
CREATE TABLE TAI_KHOAN(
	MaTaiKhoan VARCHAR(10) PRIMARY KEY,
    TenDangNhap VARCHAR(50) NOT NULL UNIQUE,
    MatKhau VARCHAR(255) NOT NULL,
    TrangThai VARCHAR(20) DEFAULT 'Hoạt động',
		CONSTRAINT cnm_trangthai
		CHECK (TrangThai IN ('Hoạt động', 'Bị Khóa'))
);

-- 9. Bang PHONG_CHIEU
CREATE TABLE PHONG_CHIEU(
	MaRap VARCHAR(10) NOT NULL,
    MaPhong VARCHAR(10) NOT NULL,
    SoGhe INT NOT NULL,
		CONSTRAINT cnm_soghe
        CHECK (SoGhe > 0),
    PRIMARY KEY (MaRap, MaPhong),
    FOREIGN KEY (MaRap) REFERENCES RAP_PHIM (MaRap)
        ON UPDATE CASCADE
);

-- 10. Bang GHE
CREATE TABLE GHE(
	MaRap VARCHAR(10),
    MaPhong VARCHAR(10),
    MaGhe VARCHAR(10),
    LoaiGhe VARCHAR(20) NOT NULL,
		CONSTRAINT cnm_loaighe
        CHECK (LoaiGhe IN ('Thường', 'Đôi', 'VIP')),
    PRIMARY KEY (MaRap, MaPhong, MaGhe),
    FOREIGN KEY (MaRap, MaPhong) REFERENCES PHONG_CHIEU(MaRap, MaPhong)
        ON UPDATE CASCADE
);

-- 11. BANG GHE_THUONG
CREATE TABLE GHE_THUONG (
    MaRap VARCHAR(10),
    MaPhong VARCHAR(10),
    MaGhe VARCHAR(10),
    PRIMARY KEY (MaRap, MaPhong, MaGhe),
    FOREIGN KEY (MaRap, MaPhong, MaGhe)
        REFERENCES GHE(MaRap, MaPhong, MaGhe)
        ON UPDATE CASCADE
);

-- 12. BANG GHE_DOI
CREATE TABLE GHE_DOI (
    MaRap VARCHAR(10),
    MaPhong VARCHAR(10),
    MaGhe VARCHAR(10),
    TayVin VARCHAR(50) NOT NULL,
    PRIMARY KEY (MaRap, MaPhong, MaGhe),
    FOREIGN KEY (MaRap, MaPhong, MaGhe)
        REFERENCES GHE(MaRap, MaPhong, MaGhe)
        ON UPDATE CASCADE
);

-- 13. BANG GHE_VIP
CREATE TABLE GHE_VIP (
    MaRap VARCHAR(10),
    MaPhong VARCHAR(10),
    MaGhe VARCHAR(10),
    NgaLung VARCHAR(50) NOT NULL,
    PRIMARY KEY (MaRap, MaPhong, MaGhe),
    FOREIGN KEY (MaRap, MaPhong, MaGhe)
        REFERENCES GHE(MaRap, MaPhong, MaGhe)
        ON UPDATE CASCADE
);

-- 14. BANG THUOC_THE_LOAI
CREATE TABLE THUOC_THE_LOAI (
    MaPhim VARCHAR(10),
    MaTheLoai VARCHAR(10),
    PRIMARY KEY (MaPhim, MaTheLoai),
    FOREIGN KEY (MaPhim)
        REFERENCES PHIM(MaPhim),
    FOREIGN KEY (MaTheLoai)
        REFERENCES THE_LOAI(MaTheLoai)
);

-- 15. BANG DAO_DIEN
CREATE TABLE DAO_DIEN (
    MaPhim VARCHAR(10),
    DaoDien VARCHAR(100),
    PRIMARY KEY (MaPhim, DaoDien),
    FOREIGN KEY (MaPhim)
        REFERENCES PHIM(MaPhim)
        ON UPDATE CASCADE
);

-- 16. BANG DIEN_VIEN
CREATE TABLE DIEN_VIEN (
    MaPhim VARCHAR(10),
    DienVien VARCHAR(100),
    PRIMARY KEY (MaPhim, DienVien),
    FOREIGN KEY (MaPhim)
        REFERENCES PHIM(MaPhim)
        ON UPDATE CASCADE
);

-- 17. BANG SUAT_CHIEU
CREATE TABLE SUAT_CHIEU (
    MaSuatChieu VARCHAR(10) PRIMARY KEY,
    NgayChieu DATE NOT NULL,
    GioBatDau TIME NOT NULL,
    GioKetThuc TIME NOT NULL,
    DinhDang VARCHAR(20) NOT NULL,
		CONSTRAINT cnm_dinhdang
        CHECK (DinhDang IN ('2D', '3D', 'IMAX')),
    HinhThucNgonNgu VARCHAR(50) NOT NULL
		CHECK (HinhThucNgonNgu IN ('Lồng tiếng', 'Phụ đề')),
    MaPhim VARCHAR(10) NOT NULL,
    MaRap VARCHAR(10) NOT NULL,
    MaPhong VARCHAR(10) NOT NULL,
    MaQuanLy VARCHAR(10),
    
    UNIQUE (MaSuatChieu, MaRap, MaPhong),

    FOREIGN KEY (MaPhim)
        REFERENCES PHIM(MaPhim)
        ON UPDATE CASCADE,

    FOREIGN KEY (MaRap, MaPhong)
        REFERENCES PHONG_CHIEU(MaRap, MaPhong)
        ON UPDATE CASCADE,
	
    CONSTRAINT cnm_giochieu
    CHECK (GioKetThuc <> GioBatDau)
);

-- 18. BANG NHAN_VIEN
CREATE TABLE NHAN_VIEN (
    MaNhanVien VARCHAR(10) PRIMARY KEY,
    Ho VARCHAR(50) NOT NULL,
    Ten VARCHAR(50) NOT NULL,
    GioiTinh VARCHAR(10),
		CONSTRAINT cnm_gioitinh_nhanvien
        CHECK (GioiTinh IN ('Nam', 'Nữ', 'Khác')),
    NgaySinh DATE,
    SoDienThoai VARCHAR(10) NOT NULL UNIQUE,
		CONSTRAINT cnm_sdt_nhanvien
        CHECK(SoDienThoai REGEXP '^0[0-9]{9}$'),
    CCCD VARCHAR(12) NOT NULL UNIQUE,
		CONSTRAINT cnm_cccd
        CHECK (CCCD REGEXP '^[0-9]{12}$'),
    MucLuong INT NOT NULL DEFAULT 0,
		CONSTRAINT cnm_luong
        CHECK (MucLuong >= 0),
    MaTaiKhoan VARCHAR(10) NOT NULL UNIQUE,
    MaRap VARCHAR(10) NOT NULL,

    FOREIGN KEY (MaTaiKhoan)
        REFERENCES TAI_KHOAN(MaTaiKhoan),

    FOREIGN KEY (MaRap)
        REFERENCES RAP_PHIM(MaRap)
);

-- 19. BANG QUAN_TRI_VIEN
CREATE TABLE QUAN_TRI_VIEN (
    MaNhanVien VARCHAR(10) PRIMARY KEY,
    CapQuyen VARCHAR(50) NOT NULL,
    MaQuanTri VARCHAR(10),

    FOREIGN KEY (MaNhanVien)
        REFERENCES NHAN_VIEN(MaNhanVien),

    FOREIGN KEY (MaQuanTri)
        REFERENCES QUAN_TRI_VIEN(MaNhanVien)
);

-- 20. BANG NHAN_VIEN_VAN_HANH
CREATE TABLE NHAN_VIEN_VAN_HANH (
    MaNhanVien VARCHAR(10) PRIMARY KEY,
    ViTriQuay VARCHAR(50) NOT NULL,

    FOREIGN KEY (MaNhanVien)
        REFERENCES NHAN_VIEN(MaNhanVien)
);

-- 21. BANG THE_THANH_VIEN
CREATE TABLE THE_THANH_VIEN (
    SoThe VARCHAR(10) PRIMARY KEY,
    HangThe VARCHAR(50) NOT NULL,
		CONSTRAINT cnm_hangthe
		CHECK (HangThe IN ('STANDARD', 'VIP')),
    NgayKichHoat DATE NOT NULL,
    DiemKhaDung INT NOT NULL DEFAULT 0,
		CONSTRAINT cnm_diemkhadung
        CHECK (DiemKhaDung >= 0),
    DiemTichLuy INT NOT NULL DEFAULT 0,
		CONSTRAINT cnm_diemtichluy
        CHECK (DiemTichLuy >= 0),
    MaKhachHang VARCHAR(10) NOT NULL UNIQUE,

    FOREIGN KEY (MaKhachHang)
        REFERENCES KHACH_HANG(MaKhachHang)
);

-- 22. BANG KHACH_HANG_TAI_KHOAN
CREATE TABLE KHACH_HANG_TAI_KHOAN (
    MaKhachHang VARCHAR(10) PRIMARY KEY,
    MaTaiKhoan VARCHAR(10) NOT NULL UNIQUE,

    FOREIGN KEY (MaKhachHang)
        REFERENCES KHACH_HANG(MaKhachHang),

    FOREIGN KEY (MaTaiKhoan)
        REFERENCES TAI_KHOAN(MaTaiKhoan)
);

-- 23. Bảng HOA_DON
CREATE TABLE HOA_DON (
    MaHoaDon VARCHAR(10) PRIMARY KEY,
    TongTien INT NOT NULL DEFAULT 0,
		CONSTRAINT cnm_tongtien
        CHECK(TongTien >= 0),
    ThoiGian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ,
    PhuongThucThanhToan VARCHAR(50) NOT NULL,
		CONSTRAINT cnm_thanhtoan
        CHECK (PhuongThucThanhToan IN ('Tiền mặt', 'Thẻ ngân hàng', 'Ví điện tử')),
    MaNhanVien VARCHAR(10),
    MaKhachHang VARCHAR(10) NOT NULL,
    MaKhuyenMai VARCHAR(10),

    FOREIGN KEY (MaNhanVien)
        REFERENCES NHAN_VIEN_VAN_HANH(MaNhanVien),

    FOREIGN KEY (MaKhachHang)
        REFERENCES KHACH_HANG(MaKhachHang),

    FOREIGN KEY (MaKhuyenMai)
        REFERENCES KHUYEN_MAI(MaKhuyenMai)
);

-- 24. Bảng VE
CREATE TABLE VE (
    MaVe VARCHAR(10) PRIMARY KEY,
    GiaVe INT NOT NULL ,
		CONSTRAINT cnm_giave
        CHECK (GiaVe >= 0),
    HinhThucMua VARCHAR(30) NOT NULL,
		CONSTRAINT cnm_hinhthucmua
        CHECK (HinhThucMua IN ('Trực tuyến', 'Trực tiếp')),
    MaSuatChieu VARCHAR(10) NOT NULL,
    MaRap VARCHAR(10) NOT NULL,
    MaPhong VARCHAR(10) NOT NULL,
    MaGhe VARCHAR(10) NOT NULL,
    MaHoaDon VARCHAR(10) NOT NULL,
    
    UNIQUE (MaSuatChieu, MaRap, MaPhong, MaGhe),
        
	FOREIGN KEY (MaSuatChieu, MaRap, MaPhong)
		REFERENCES SUAT_CHIEU(MaSuatChieu, MaRap, MaPhong),

    FOREIGN KEY (MaRap, MaPhong, MaGhe)
        REFERENCES GHE(MaRap, MaPhong, MaGhe),

    FOREIGN KEY (MaHoaDon)
        REFERENCES HOA_DON(MaHoaDon)
);

-- 25. Bảng BAO_GOM
CREATE TABLE BAO_GOM (
    MaHoaDon VARCHAR(10) NOT NULL,
    MaSanPham VARCHAR(10) NOT NULL,
    SoLuong INT NOT NULL,
		CONSTRAINT cnm_soluongdon
        CHECK (SoLuong > 0),
    DonGia INT NOT NULL,
		CONSTRAINT cnm_dongia
        CHECK (DonGia >= 0),

    PRIMARY KEY (MaHoaDon, MaSanPham),

    FOREIGN KEY (MaHoaDon)
        REFERENCES HOA_DON(MaHoaDon),

    FOREIGN KEY (MaSanPham)
        REFERENCES SAN_PHAM(MaSanPham)
);

-- 26. Bảng SO_HUU
CREATE TABLE SO_HUU (
    MaKhachHang VARCHAR(10),
    MaKhuyenMai VARCHAR(10),

    PRIMARY KEY (MaKhachHang, MaKhuyenMai),

    FOREIGN KEY (MaKhachHang)
        REFERENCES KHACH_HANG(MaKhachHang),

    FOREIGN KEY (MaKhuyenMai)
        REFERENCES KHUYEN_MAI(MaKhuyenMai)
);

-- 27. Bảng TRUC
CREATE TABLE TRUC (
    MaCa VARCHAR(10),
    MaNhanVien VARCHAR(10),
    NgayLamViec DATE NOT NULL,

    PRIMARY KEY (MaCa, MaNhanVien, NgayLamViec),

    FOREIGN KEY (MaCa)
        REFERENCES CA_LAM_VIEC(MaCa),

    FOREIGN KEY (MaNhanVien)
        REFERENCES NHAN_VIEN_VAN_HANH(MaNhanVien)
);

ALTER TABLE RAP_PHIM
ADD CONSTRAINT FK_RAP_PHIM_QUAN_TRI_VIEN
FOREIGN KEY (MaQuanLy)
REFERENCES QUAN_TRI_VIEN(MaNhanVien);

ALTER TABLE PHIM
ADD CONSTRAINT FK_PHIM_QUAN_TRI_VIEN
FOREIGN KEY (MaQuanLy)
REFERENCES QUAN_TRI_VIEN(MaNhanVien);

ALTER TABLE SUAT_CHIEU
ADD CONSTRAINT FK_SUAT_CHIEU_QUAN_TRI_VIEN
FOREIGN KEY (MaQuanLy)
REFERENCES QUAN_TRI_VIEN(MaNhanVien);
