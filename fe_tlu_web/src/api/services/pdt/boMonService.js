import { apiClient } from "../../apiClient";

export const boMonService = {
    getAll: async () => {
        const res = await apiClient.get("/pdt/bomon");
        return res.data;
    },

    create: async (data) => {
        return await apiClient.post("/pdt/bomon", data);
    },

    update: async (id, data) => {
        return await apiClient.put(`/pdt/bomon/${id}`, data);
    },

    delete: async (id) => {
        return await apiClient.delete(`/pdt/bomon/${id}`);
    },
};
