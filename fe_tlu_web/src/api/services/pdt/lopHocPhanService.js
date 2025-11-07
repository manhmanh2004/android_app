import { apiClient } from "../../apiClient";

export const lopHocPhanService = {
    async getAll() {
        return apiClient.get("/pdt/lop-hoc-phan");
    },
    async getAllWithGiangVien() {
        return apiClient.get("/pdt/lop-hoc-phan/phan-cong");
    },
    async getStudents(maLHP) {
        return apiClient.get(`/pdt/lop-hoc-phan/${maLHP}/sinh-vien`);
    },
    async create(data) {
        return apiClient.post("/pdt/lop-hoc-phan", data);
    },

    // Tên gốc bạn đang dùng ở backend
    async importSinhVien(maLHP, formData) {
        return apiClient.post(
            `/pdt/lop-hoc-phan/${maLHP}/import-sinh-vien`,
            formData,
            { headers: { "Content-Type": "multipart/form-data" } }
        );
    },

    // ✅ Alias để chỗ nào gọi importStudents vẫn chạy được
    async importStudents(maLHP, payload) {
        // chấp nhận truyền vào là File hoặc FormData để linh hoạt
        let formData =
            payload instanceof FormData
                ? payload
                : (() => {
                      const fd = new FormData();
                      fd.append("file", payload); // payload là File
                      return fd;
                  })();
        return this.importSinhVien(maLHP, formData);
    },
};
