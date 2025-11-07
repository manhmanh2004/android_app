import { Routes, Route } from "react-router-dom";

// 🧩 Auth
import LoginPage from "../pages/auth/LoginPage";

// 🏫 PĐT
import PDTLayout from "../layouts/PDTLayout";
import KhoaPage from "../pages/pdt/KhoaPage";
import NganhPage from "../pages/pdt/NganhPage";
import MonHocPage from "../pages/pdt/MonHocPage";
import PhongHocPage from "../pages/pdt/PhongHocPage";
import HocKyPage from "../pages/pdt/HocKyPage";
import BoMonPage from "../pages/pdt/BoMonPage";
import LopHocPhanPage from "../pages/pdt/LopHocPhanPage";
import PhanCongPage from "../pages/pdt/PhanCongPage";
import SinhLichPage from "../pages/pdt/SinhLichPage";
import YeuCauPage from "../pages/pdt/YeuCauPage";
import ThongBaoPage from "../pages/pdt/ThongBaoPage";
import ThongKePage from "../pages/pdt/ThongKePage";

// ⚙️ Quản trị viên
import AdminLayout from "../layouts/AdminLayout";
import TaiKhoanPage from "../pages/admin/TaiKhoanPage";

// 🎓 Bộ Môn
import BoMonLayout from "../layouts/BoMonLayout";
import GiangVienBoMonPage from "../pages/bomon/GiangVienBoMonPage";
import TienTrinhGiangDayPage from "../pages/bomon/TienTrinhGiangDayPage";
import BaoCaoBoMonPage from "../pages/bomon/BaoCaoBoMonPage";
import LichDayBoMonPage from "../pages/bomon/LichDayBoMonPage";

export default function AppRouter() {
    return (
        <Routes>
            {/* ✅ Trang đăng nhập */}
            <Route path="/" element={<LoginPage />} />

            {/* 🏫 Layout Phòng Đào Tạo */}
            <Route path="/pdt" element={<PDTLayout />}>
                <Route path="khoa" element={<KhoaPage />} />
                <Route path="nganh" element={<NganhPage />} />
                <Route path="monhoc" element={<MonHocPage />} />
                <Route path="phonghoc" element={<PhongHocPage />} />
                <Route path="hocky" element={<HocKyPage />} />
                <Route path="bomon" element={<BoMonPage />} />
                <Route path="lop-hoc-phan" element={<LopHocPhanPage />} />
                <Route path="phancong" element={<PhanCongPage />} />
                <Route path="sinh-lich" element={<SinhLichPage />} />
                <Route path="yeucau" element={<YeuCauPage />} />
                <Route path="thongbao" element={<ThongBaoPage />} />
                <Route path="thongke" element={<ThongKePage />} />
            </Route>

            {/* ⚙️ Layout Quản trị viên */}
            <Route path="/admin" element={<AdminLayout />}>
                <Route path="tai-khoan" element={<TaiKhoanPage />} />
            </Route>

            {/* 🎓 Layout Bộ Môn */}
            <Route path="/bomon" element={<BoMonLayout />}>
                <Route path="giang-vien" element={<GiangVienBoMonPage />} />
                <Route path="tien-trinh" element={<TienTrinhGiangDayPage />} />
                <Route path="bao-cao" element={<BaoCaoBoMonPage />} />
                <Route path="lich-day" element={<LichDayBoMonPage />} />
            </Route>
        </Routes>
    );
}
