import { apiClient } from "../../apiClient";

export const yeuCauService = {
    async getAll() {
        return await apiClient.get("/pdt/yeu-cau");
    },

    // ✅ Hàm update (duyệt / từ chối yêu cầu)
    async update(maYeuCau, data) {
        return await apiClient.put(`/pdt/yeu-cau/${maYeuCau}`, data);
    },
};
