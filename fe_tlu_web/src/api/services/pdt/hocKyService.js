import { apiClient } from "../../apiClient";

export const hocKyService = {
    async getAll() {
        return await apiClient.get("/pdt/hoc-ky");
    },
    async create(data) {
        return await apiClient.post("/pdt/hoc-ky", data);
    },
    async update(id, data) {
        return await apiClient.put(`/pdt/hoc-ky/${id}`, data);
    },
    async delete(id) {
        return await apiClient.delete(`/pdt/hoc-ky/${id}`);
    },
};
