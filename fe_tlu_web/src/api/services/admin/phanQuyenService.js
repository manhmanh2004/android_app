import { apiClient } from "../apiClient";

export const phanQuyenService = {
    getUsers: () => apiClient.get("/admin/phan-quyen/users"),
    getRoles: () => apiClient.get("/admin/phan-quyen/roles"),
    addRole: (userId, roleId) =>
        apiClient.post(`/admin/phan-quyen/${userId}/add/${roleId}`),
    removeRole: (userId, roleId) =>
        apiClient.delete(`/admin/phan-quyen/${userId}/remove/${roleId}`),
};
