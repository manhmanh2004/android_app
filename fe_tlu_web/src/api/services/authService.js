// src/api/services/pdt/authService.js
import { apiClient } from "../apiClient";

export const AuthService = {
    async login(username, password) {
        const res = await apiClient.post("/login", {
            TenDangNhap: username,
            MatKhau: password,
        });

        const data = res.data;

        // 🧹 Xóa token cũ (nếu có)
        localStorage.removeItem("token");
        localStorage.removeItem("roles");
        localStorage.removeItem("user");

        // 💾 Lưu token mới
        localStorage.setItem("token", data.token);
        localStorage.setItem("roles", JSON.stringify(data.roles));
        localStorage.setItem("user", JSON.stringify(data.user));

        return data;
    },
    async getProfile() {
        const res = await apiClient.get("/user");
        return res.data;
    },
};

// export const AuthService = {
//     async login(username, password) {
//         const res = await apiClient.post("/login", {
//             TenDangNhap: username,
//             MatKhau: password,
//         });

//         const data = res.data;

//         // 🧩 Lấy danh sách vai trò từ user
//         const roles = data.user?.DanhSachVaiTro?.map((v) => v.TenVaiTro) || [
//             data.user?.TenVaiTro,
//         ];

//         // 💾 Lưu vào localStorage
//         localStorage.setItem("token", data.token);
//         localStorage.setItem("user", JSON.stringify(data.user));
//         localStorage.setItem("roles", JSON.stringify(roles));

//         return { ...data, roles }; // ✅ trả roles ra ngoài
//     },

//     async getProfile() {
//         const res = await apiClient.get("/user");
//         return res.data;
//     },
// };
