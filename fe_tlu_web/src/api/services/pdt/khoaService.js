import { apiClient } from "../../apiClient";

export const khoaService = {
    async getAll() {
        return await apiClient.get("/pdt/khoa");
    },
    async create(data) {
        return await apiClient.post("/pdt/khoa", data);
    },
    async update(id, data) {
        return await apiClient.put(`/pdt/khoa/${id}`, data);
    },
    async delete(id) {
        return await apiClient.delete(`/pdt/khoa/${id}`);
    },
};
