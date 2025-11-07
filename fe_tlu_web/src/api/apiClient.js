// src/api/apiClient.js
import axios from "axios";

// const API_BASE_URL = "http://10.0.162.24:8008/api";
const API_BASE_URL = "http://127.0.0.1:8000/api";
// const API_BASE_URL = "http://localhost:8008/api";

// 🧩 Tạo instance
export const apiClient = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
    },
});

// 🧠 Thêm token tự động vào request nếu có
apiClient.interceptors.request.use((config) => {
    const token = localStorage.getItem("token");
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});
