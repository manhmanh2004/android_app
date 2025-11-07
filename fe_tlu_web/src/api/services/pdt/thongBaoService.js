import { apiClient } from "../../apiClient";

export const thongBaoService = {
    async getAll() {
        return await apiClient.get("/pdt/thong-bao/da-gui");
    },

    async create(data) {
        return await apiClient.post("/pdt/thong-bao", data);
    },

    async update(id, data) {
        return await apiClient.put(`/pdt/thong-bao/${id}`, data);
    },

    async delete(id) {
        return await apiClient.delete(`/pdt/thong-bao/${id}`);
    },
    async getById(id) {
        return await apiClient.get(`/pdt/thong-bao/${id}`);
    },
};
