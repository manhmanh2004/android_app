// src/api/services/pdt/giangVienService.js
import { apiClient } from "../../apiClient";

export const giangVienService = {
    async getAll() {
        // BE trả MẢNG [] trực tiếp (theo payload bạn cho)
        return apiClient.get("/pdt/giang-vien");
    },
};
