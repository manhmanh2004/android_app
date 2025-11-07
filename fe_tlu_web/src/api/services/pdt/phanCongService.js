// src/api/services/pdt/phanCongService.js
import { apiClient } from "../../apiClient";

export const phanCongService = {
    // Phân công / đổi giảng viên
    assign(payload) {
        // payload = { MaLHP, MaGV }
        return apiClient.post("/pdt/phan-cong", payload);
    },

    // Hủy phân công (nếu BE có hỗ trợ)
    unassign(MaLHP, MaGV) {
        return apiClient.delete(`/pdt/phan-cong`, { params: { MaLHP, MaGV } });
    },
};
