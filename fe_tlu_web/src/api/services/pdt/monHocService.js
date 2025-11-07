import { apiClient } from "../../apiClient";

export const monHocService = {
    async getAll() {
        return await apiClient.get("/pdt/mon-hoc");
    },
    async create(data) {
        return await apiClient.post("/pdt/mon-hoc", data);
    },
    async update(id, data) {
        return await apiClient.put(`/pdt/mon-hoc/${id}`, data);
    },
    async delete(id) {
        return await apiClient.delete(`/pdt/mon-hoc/${id}`);
    },
};
