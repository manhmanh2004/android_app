// src/api/services/pdt/thongKeService.js
import { apiClient } from "../../apiClient";

export const thongKeService = {
    async getTienDoHocPhan(params = {}) {
        // Bỏ các field rỗng/0/"" để BE không where sai
        const clean = {};
        if (params.hocKy && Number(params.hocKy) > 0)
            clean.hocKy = Number(params.hocKy);
        if (params.khoa && Number(params.khoa) > 0)
            clean.khoa = Number(params.khoa);
        if (params.nganh && Number(params.nganh) > 0)
            clean.nganh = Number(params.nganh);
        if (params.giangVien && params.giangVien.trim() !== "")
            clean.giangVien = params.giangVien.trim();
        if (params.tenMH && params.tenMH.trim() !== "")
            clean.tenMH = params.tenMH.trim();

        return await apiClient.get("/pdt/thongke/tien-do-hoc-phan", {
            params: clean,
        });
    },
};
