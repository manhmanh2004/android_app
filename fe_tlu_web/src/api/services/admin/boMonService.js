import { apiClient } from "../../apiClient";

export const boMonService = {
    async getAll() {
        return await apiClient.get("/admin/bo-mon");
    },
};
