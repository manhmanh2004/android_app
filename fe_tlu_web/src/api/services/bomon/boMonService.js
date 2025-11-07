import { apiClient } from "../../apiClient";

export const boMonService = {
    // 🔹 Danh sách giảng viên thuộc bộ môn
    async getGiangVien(maBoMon) {
        const params = maBoMon ? { maBoMon } : {}; // ✅ tránh null
        return await apiClient.get(`/bo-mon/giang-vien`, { params });
    },

    // 🔹 Tiến trình giảng dạy của 1 giảng viên
    async getTienTrinh(maGV, filters = {}) {
        return await apiClient.get(`/bo-mon/giang-vien/${maGV}/tien-trinh`, {
            params: filters,
        });
    },

    // 🔹 Báo cáo tổng hợp bộ môn
    async getBaoCao(maBoMon, filters = {}) {
        const params = maBoMon ? { maBoMon, ...filters } : { ...filters }; // ✅ tránh lỗi object undefined
        return await apiClient.get(`/bo-mon/bao-cao`, { params });
    },

    // 🔹 Lịch dạy của 1 lớp học phần
    async getLichDay(maLHP) {
        return await apiClient.get(`/bo-mon/lich-day/${maLHP}`);
    },
};
