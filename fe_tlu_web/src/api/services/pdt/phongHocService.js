import { apiClient } from "../../apiClient";

export const phongHocService = {
    async getAll() {
        return await apiClient.get("/pdt/phong-hoc");
    },
    async create(data) {
        return await apiClient.post("/pdt/phong-hoc", data);
    },
    async update(id, data) {
        return await apiClient.put(`/pdt/phong-hoc/${id}`, data);
    },
    async delete(id) {
        return await apiClient.delete(`/pdt/phong-hoc/${id}`);
    },
};
