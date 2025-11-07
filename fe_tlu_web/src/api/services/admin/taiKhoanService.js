import { apiClient } from "../../apiClient";

export const taiKhoanService = {
    // 📋 Danh sách tài khoản (đã include vai trò)
    async getAll() {
        return await apiClient.get("/admin/tai-khoan");
    },

    // 🧩 Thêm mới người dùng
    async create(data) {
        return await apiClient.post("/admin/nguoi-dung", data);
    },

    // ✏️ Cập nhật thông tin người dùng
    async update(id, data) {
        return await apiClient.put(`/admin/nguoi-dung/${id}`, data);
    },

    // 🗑️ Xóa người dùng
    async delete(id) {
        return await apiClient.delete(`/admin/nguoi-dung/${id}`);
    },

    // 📜 Danh sách vai trò
    async getRoles() {
        return await apiClient.get("/admin/vai-tro");
    },

    // 🧱 Danh sách bộ môn (nếu cần chọn khi tạo giảng viên)
    async getBoMons() {
        return await apiClient.get("/admin/bo-mon");
    },
};
