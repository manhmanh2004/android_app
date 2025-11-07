// src/api/services/pdtService.js
import api from "../apiClient";

export const PDTService = {
    // ===== KHOA =====
    getAllKhoa: () => api.get("/pdt/khoa"),
    createKhoa: (data) => api.post("/pdt/khoa", data),
    updateKhoa: (id, data) => api.put(`/pdt/khoa/${id}`, data),
    deleteKhoa: (id) => api.delete(`/pdt/khoa/${id}`),

    // ===== NGÀNH =====
    getAllNganh: () => api.get("/pdt/nganh"),
    createNganh: (data) => api.post("/pdt/nganh", data),
    updateNganh: (id, data) => api.put(`/pdt/nganh/${id}`, data),
    deleteNganh: (id) => api.delete(`/pdt/nganh/${id}`),

    // ===== MÔN HỌC =====
    getAllMonHoc: () => api.get("/pdt/monhoc"),
    createMonHoc: (data) => api.post("/pdt/monhoc", data),
    updateMonHoc: (id, data) => api.put(`/pdt/monhoc/${id}`, data),
    deleteMonHoc: (id) => api.delete(`/pdt/monhoc/${id}`),

    // ===== HỌC KỲ =====
    getAllHocKy: () => api.get("/pdt/hocky"),
    createHocKy: (data) => api.post("/pdt/hocky", data),
    updateHocKy: (id, data) => api.put(`/pdt/hocky/${id}`, data),
    deleteHocKy: (id) => api.delete(`/pdt/hocky/${id}`),

    // ===== PHÒNG HỌC =====
    getAllPhongHoc: () => api.get("/pdt/phonghoc"),
    createPhongHoc: (data) => api.post("/pdt/phonghoc", data),
    updatePhongHoc: (id, data) => api.put(`/pdt/phonghoc/${id}`, data),
    deletePhongHoc: (id) => api.delete(`/pdt/phonghoc/${id}`),

    // ===== LỚP HỌC PHẦN =====
    getAllLHP: () => api.get("/pdt/lophocphan"),
    createLHP: (data) => api.post("/pdt/lophocphan", data),

    // ===== PHÂN CÔNG =====
    assignGiangVien: (data) => api.post("/pdt/phancong", data),

    // ===== YÊU CẦU THAY ĐỔI LỊCH =====
    getAllYeuCau: () => api.get("/pdt/yeucau"),
    duyetYeuCau: (id, data) => api.put(`/pdt/yeucau/${id}/duyet`, data),

    // ===== TIẾN ĐỘ GIẢNG DẠY =====
    getTienDoHK: (maHK) => api.get(`/pdt/tiendo/${maHK}`),
};
