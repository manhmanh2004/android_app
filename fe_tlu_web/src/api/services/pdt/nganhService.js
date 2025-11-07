import { apiClient } from "../../apiClient";

export const nganhService = {
    async getAll() {
        return await apiClient.get("/pdt/nganh");
    },
    async create(data) {
        return await apiClient.post("/pdt/nganh", data);
    },
    async update(id, data) {
        return await apiClient.put(`/pdt/nganh/${id}`, data);
    },
    async delete(id) {
        return await apiClient.delete(`/pdt/nganh/${id}`);
    },
};
