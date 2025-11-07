import { apiClient } from "../../apiClient";

export const lichTrinhService = {
    // 🧮 Gọi API sinh lịch tự động
    async sinhLichTuDong(data) {
        // data gồm: MaLHP, SoBuoi, NgayBatDau, CaHoc, MaPhong (nếu có)
        return await apiClient.post("/pdt/sinh-lich-tu-dong", data);
    },

    // 📅 Lấy danh sách lịch theo mã lớp học phần
    async getByLopHocPhan(maLHP) {
        return await apiClient.get(`/pdt/lich-theo-lhp/${maLHP}`);
    },

    // ❌ (Tùy chọn) Xóa lịch của lớp học phần — nếu muốn sinh lại
    async xoaLichTheoLop(maLHP) {
        return await apiClient.delete(`/pdt/xoa-lich-theo-lhp/${maLHP}`);
    },
};
