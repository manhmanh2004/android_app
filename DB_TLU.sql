CREATE DATABASE DB_TLU;
GO
USE DB_TLU;
GO
drop database DB_TLU
-- ========== DANH MỤC CƠ BẢN ==========
CREATE TABLE Khoa (
    MaKhoa INT IDENTITY(1,1) PRIMARY KEY,
    TenKhoa NVARCHAR(200) NOT NULL,
    MoTa NVARCHAR(500)
);

CREATE TABLE BoMon (
    MaBoMon INT IDENTITY(1,1) PRIMARY KEY,
    TenBoMon NVARCHAR(200) NOT NULL,
    MaKhoa INT NOT NULL,
    FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);

CREATE TABLE Nganh (
    MaNganh INT IDENTITY(1,1) PRIMARY KEY,
    TenNganh NVARCHAR(200) NOT NULL,
    MaKhoa INT NOT NULL,
    FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);

CREATE TABLE HocKy (
    MaHK INT IDENTITY(1,1) PRIMARY KEY,
    TenHK NVARCHAR(100) NOT NULL,
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    CHECK (NgayKetThuc >= NgayBatDau)
);

CREATE TABLE MonHoc (
    MaMonHoc INT IDENTITY(1,1) PRIMARY KEY,
    TenMonHoc NVARCHAR(200) NOT NULL,
    SoTinChi INT NOT NULL CHECK (SoTinChi > 0),
    SoTiet INT NOT NULL CHECK (SoTiet > 0),
    MaNganh INT NOT NULL,
    FOREIGN KEY (MaNganh) REFERENCES Nganh(MaNganh)
);

CREATE TABLE PhongHoc (
    MaPhong INT IDENTITY(1,1) PRIMARY KEY,
    TenPhong NVARCHAR(100) NOT NULL,
    SucChua INT NOT NULL CHECK (SucChua > 0),
    LoaiPhong VARCHAR(10) NOT NULL CHECK (LoaiPhong IN ('LT','TH'))
);

-- ========== NGƯỜI DÙNG & PHÂN QUYỀN ==========
CREATE TABLE VaiTro (
    MaVaiTro INT IDENTITY(1,1) PRIMARY KEY,
    TenVaiTro NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE NguoiDung (
    MaND INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap NVARCHAR(100) NOT NULL UNIQUE,
    MatKhau NVARCHAR(255),
    HoTen NVARCHAR(200) NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    TrangThai BIT NOT NULL DEFAULT(1)
);

CREATE TABLE NguoiDung_VaiTro (
    MaND INT NOT NULL,
    MaVaiTro INT NOT NULL,
    PRIMARY KEY (MaND, MaVaiTro),
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND),
    FOREIGN KEY (MaVaiTro) REFERENCES VaiTro(MaVaiTro)
);

CREATE TABLE GiangVien (
    MaGV INT IDENTITY(1,1) PRIMARY KEY,
    MaND INT NOT NULL UNIQUE,
    MaBoMon INT NOT NULL,
    TrinhDo NVARCHAR(100),
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND),
    FOREIGN KEY (MaBoMon) REFERENCES BoMon(MaBoMon)
);

CREATE TABLE SinhVien (
    MaSV INT IDENTITY(1,1) PRIMARY KEY,
    MaND INT NOT NULL UNIQUE,
    MaLopHanhChinh NVARCHAR(50),
    NamNhapHoc INT,
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND)
);

-- ========== QUẢN LÝ GIẢNG DẠY ==========
CREATE TABLE LopHocPhan (
    MaLHP INT IDENTITY(1,1) PRIMARY KEY,
    TenLHP NVARCHAR(200) NOT NULL,
    MaMonHoc INT NOT NULL,
    MaHK INT NOT NULL,
    MaPhongMacDinh INT NULL,
    SiSoToiDa INT NOT NULL CHECK (SiSoToiDa > 0),
    TrangThai VARCHAR(20) NOT NULL DEFAULT('DangDay') CHECK (TrangThai IN ('DangDay','HoanThanh','Huy')),
    FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(MaMonHoc),
    FOREIGN KEY (MaHK) REFERENCES HocKy(MaHK),
    FOREIGN KEY (MaPhongMacDinh) REFERENCES PhongHoc(MaPhong)
);

CREATE TABLE PhanCong (
    MaPhanCong INT IDENTITY(1,1) PRIMARY KEY,
    MaLHP INT NOT NULL,
    MaGV INT NOT NULL,
    NgayPhanCong DATE NOT NULL DEFAULT(GETDATE()),
    UNIQUE (MaLHP, MaGV),
    FOREIGN KEY (MaLHP) REFERENCES LopHocPhan(MaLHP),
    FOREIGN KEY (MaGV) REFERENCES GiangVien(MaGV)
);

CREATE TABLE DangKyHocPhan (
    MaLHP INT NOT NULL,
    MaSV INT NOT NULL,
    NgayDangKy DATE NOT NULL DEFAULT(GETDATE()),
    PRIMARY KEY (MaLHP, MaSV),
    FOREIGN KEY (MaLHP) REFERENCES LopHocPhan(MaLHP),
    FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV)
);

CREATE TABLE LichTrinhChiTiet (
    MaBuoiHoc INT IDENTITY(1,1) PRIMARY KEY,
    MaLHP INT NOT NULL,
    NgayHoc DATE NOT NULL,
    CaHoc VARCHAR(20) NOT NULL,
    MaPhong INT NULL,
    TrangThaiBuoiHoc VARCHAR(20) NOT NULL DEFAULT('BinhThuong') CHECK (TrangThaiBuoiHoc IN ('BinhThuong','Nghi','DayBu')),
    ThoiGianMoDD DATETIME2(0),
    ThoiGianDongDD DATETIME2(0),
    NoiDungGiangDay NVARCHAR(MAX),
    UNIQUE (MaLHP, NgayHoc, CaHoc),
    FOREIGN KEY (MaLHP) REFERENCES LopHocPhan(MaLHP),
    FOREIGN KEY (MaPhong) REFERENCES PhongHoc(MaPhong)
);

CREATE TABLE DiemDanh (
    MaDiemDanh INT IDENTITY(1,1) PRIMARY KEY,
    MaBuoiHoc INT NOT NULL,
    MaSV INT NOT NULL,
    TrangThaiDD VARCHAR(20) NOT NULL CHECK (TrangThaiDD IN ('CoMat','Vang','Muon','CoPhep')),
    GhiChu NVARCHAR(500),
    ThoiGianDiemDanh DATETIME2(0) NOT NULL DEFAULT(SYSDATETIME()),
    UNIQUE (MaBuoiHoc, MaSV),
    FOREIGN KEY (MaBuoiHoc) REFERENCES LichTrinhChiTiet(MaBuoiHoc),
    FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV)
);

-- ========== YÊU CẦU NGHỈ / DẠY BÙ ==========
CREATE TABLE YeuCauThayDoiLich (
    MaYeuCau INT IDENTITY(1,1) PRIMARY KEY,
    MaGV INT NOT NULL,
    MaBuoiHocNguon INT NOT NULL,
    LoaiYeuCau VARCHAR(20) NOT NULL CHECK (LoaiYeuCau IN ('Nghi','DayBu')),
    NgayDeXuat DATE NOT NULL DEFAULT(GETDATE()),
    NgayDeNghiBu DATE,
    CaDeNghiBu VARCHAR(20),
    MaPhongDeNghi INT,
    LyDo NVARCHAR(1000),
    TrangThai VARCHAR(20) NOT NULL DEFAULT('ChoDuyet') CHECK (TrangThai IN ('ChoDuyet','Duyet','TuChoi')),
    FOREIGN KEY (MaGV) REFERENCES GiangVien(MaGV),
    FOREIGN KEY (MaBuoiHocNguon) REFERENCES LichTrinhChiTiet(MaBuoiHoc),
    FOREIGN KEY (MaPhongDeNghi) REFERENCES PhongHoc(MaPhong)
);

-- ========== THÔNG BÁO ==========
CREATE TABLE ThongBao (
    MaThongBao INT IDENTITY(1,1) PRIMARY KEY,
    TieuDe NVARCHAR(300) NOT NULL,
    NoiDung NVARCHAR(MAX) NOT NULL,
    NguoiGui INT NOT NULL,
    ThoiGianGui DATETIME2(0) NOT NULL DEFAULT(SYSDATETIME()),
    FOREIGN KEY (NguoiGui) REFERENCES NguoiDung(MaND)
);

CREATE TABLE ThongBao_NguoiNhan (
    MaThongBao INT NOT NULL,
    MaNguoiNhan INT NOT NULL,
    TrangThaiDoc BIT NOT NULL DEFAULT(0),
    PRIMARY KEY (MaThongBao, MaNguoiNhan),
    FOREIGN KEY (MaThongBao) REFERENCES ThongBao(MaThongBao),
    FOREIGN KEY (MaNguoiNhan) REFERENCES NguoiDung(MaND)
);

-- ========== VIEW THỐNG KÊ ==========
CREATE VIEW vThongKeTienDoLHP AS
SELECT
    pc.MaGV,
    lhp.MaLHP,
    lhp.TenLHP,
    hk.TenHK,
    SUM(CASE WHEN l.TrangThaiBuoiHoc = 'BinhThuong' THEN 1 ELSE 0 END) AS SoBuoiDaDay,
    SUM(CASE WHEN l.TrangThaiBuoiHoc = 'Nghi' THEN 1 ELSE 0 END) AS SoBuoiNghi,
    SUM(CASE WHEN l.TrangThaiBuoiHoc = 'DayBu' THEN 1 ELSE 0 END) AS SoBuoiDayBu,
    COUNT(*) AS TongSoBuoi,
    CAST(100.0 * SUM(CASE WHEN l.TrangThaiBuoiHoc IN ('BinhThuong','DayBu') THEN 1 ELSE 0 END)
         / NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS TienDoPhanTram
FROM PhanCong pc
JOIN LopHocPhan lhp ON lhp.MaLHP = pc.MaLHP
JOIN HocKy hk ON hk.MaHK = lhp.MaHK
JOIN LichTrinhChiTiet l ON l.MaLHP = lhp.MaLHP
GROUP BY pc.MaGV, lhp.MaLHP, lhp.TenLHP, hk.TenHK;
GO

CREATE VIEW vThongKeChuyenCanSV AS
SELECT
    d.MaSV,
    lhp.MaLHP,
    mh.TenMonHoc,
    COUNT(*) AS TongBuoi,
    SUM(CASE WHEN d.TrangThaiDD IN ('CoMat','Muon','CoPhep') THEN 1 ELSE 0 END) AS SoBuoiCoMat,
    CAST(100.0 * SUM(CASE WHEN d.TrangThaiDD IN ('CoMat','Muon','CoPhep') THEN 1 ELSE 0 END)
         / NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS TiLeChuyenCan
FROM DiemDanh d
JOIN LichTrinhChiTiet l ON l.MaBuoiHoc = d.MaBuoiHoc
JOIN LopHocPhan lhp ON lhp.MaLHP = l.MaLHP
JOIN MonHoc mh ON mh.MaMonHoc = lhp.MaMonHoc
GROUP BY d.MaSV, lhp.MaLHP, mh.TenMonHoc;
GO





-----------------------------------------------------
CREATE OR REPLACE VIEW vThongKeChuyenCanSV AS
SELECT
    d.MaSV,
    lhp.MaLHP,
    mh.TenMonHoc,
    COUNT(*) AS TongBuoi,
    SUM(CASE WHEN d.TrangThaiDD IN ('CoMat','Muon','CoPhep') THEN 1 ELSE 0 END) AS SoBuoiCoMat,
    ROUND(
        100.0 *
        SUM(CASE WHEN d.TrangThaiDD IN ('CoMat','Muon','CoPhep') THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*),0),
        2
    ) AS TiLeChuyenCan
FROM DiemDanh d
JOIN LichTrinhChiTiet l ON l.MaBuoiHoc = d.MaBuoiHoc
JOIN LopHocPhan lhp ON lhp.MaLHP = l.MaLHP
JOIN MonHoc mh ON mh.MaMonHoc = lhp.MaMonHoc
GROUP BY d.MaSV, lhp.MaLHP, mh.TenMonHoc;
-----------------------------------------------------
CREATE OR REPLACE VIEW vThongKeTienDoLHP AS
SELECT
    pc.MaGV,
    lhp.MaLHP,
    lhp.TenLHP,
    hk.TenHK,
    SUM(CASE WHEN l.TrangThaiBuoiHoc = 'BinhThuong' THEN 1 ELSE 0 END) AS SoBuoiDaDay,
    SUM(CASE WHEN l.TrangThaiBuoiHoc = 'Nghi' THEN 1 ELSE 0 END) AS SoBuoiNghi,
    SUM(CASE WHEN l.TrangThaiBuoiHoc = 'DayBu' THEN 1 ELSE 0 END) AS SoBuoiDayBu,
    COUNT(*) AS TongSoBuoi,
    ROUND(
        100.0 *
        SUM(CASE WHEN l.TrangThaiBuoiHoc IN ('BinhThuong','DayBu') THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*),0),
        2
    ) AS TienDoPhanTram
FROM PhanCong pc
JOIN LopHocPhan lhp ON lhp.MaLHP = pc.MaLHP
JOIN HocKy hk ON hk.MaHK = lhp.MaHK
JOIN LichTrinhChiTiet l ON l.MaLHP = lhp.MaLHP
GROUP BY pc.MaGV, lhp.MaLHP, lhp.TenLHP, hk.TenHK;
