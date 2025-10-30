<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use App\Models\GiangVien;
use App\Models\LichTrinhChiTiet;
use App\Models\DiemDanh;
use App\Models\YeuCauThayDoiLich;
use App\Models\ThongBaoNguoiNhan;

class GiangVienController extends Controller
{
    // ==================== 🧑‍🏫 THÔNG TIN GIẢNG VIÊN ====================
    public function thongTin()
    {
        $user = Auth::user();
        $gv = GiangVien::with('boMon.khoa')
            ->where('MaND', $user->MaND)
            ->first();

        if (!$gv) {
            return response()->json(['message' => 'Không tìm thấy thông tin giảng viên'], 404);
        }

        return response()->json($gv);
    }

    // ==================== 📅 LỊCH DẠY ====================
    public function lichDay()
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        $lich = LichTrinhChiTiet::with([
            'lopHocPhan.monHoc',
            'lopHocPhan.hocKy',
            'phongHoc'
        ])
            ->whereHas('lopHocPhan.phanCongs', fn($q) => $q->where('MaGV', $gv->MaGV))
            ->orderBy('NgayHoc')
            ->get();

        return response()->json(['message' => '📘 Lịch dạy của giảng viên', 'data' => $lich]);
    }

    public function lichDayTheoNgay($ngay)
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        $lich = LichTrinhChiTiet::with(['lopHocPhan.monHoc', 'phongHoc'])
            ->whereDate('NgayHoc', $ngay)
            ->whereHas('lopHocPhan.phanCongs', fn($q) => $q->where('MaGV', $gv->MaGV))
            ->orderBy('CaHoc')
            ->get();

        return response()->json(['message' => "📅 Lịch dạy ngày {$ngay}", 'data' => $lich]);
    }

    // ==================== ✅ ĐIỂM DANH ====================
    public function moDiemDanh(Request $request)
    {
        $request->validate(['MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc']);
        $buoi = LichTrinhChiTiet::find($request->MaBuoiHoc);

        $buoi->ThoiGianMoDD = now();
        $buoi->TrangThaiBuoiHoc = 'DangDiemDanh';
        $buoi->save();

        return response()->json(['message' => '🔓 Đã mở điểm danh thành công!', 'data' => $buoi]);
    }

    public function ghiDiemDanh(Request $request)
    {
        $request->validate([
            'MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc',
            'DanhSach' => 'required|array'
        ]);

        foreach ($request->DanhSach as $item) {
            DiemDanh::updateOrCreate(
                ['MaBuoiHoc' => $request->MaBuoiHoc, 'MaSV' => $item['MaSV']],
                [
                    'TrangThaiDD' => $item['TrangThaiDD'],
                    'GhiChu' => $item['GhiChu'] ?? null
                ]
            );
        }

        return response()->json(['message' => '📝 Ghi điểm danh thành công!']);
    }

    public function dongDiemDanh(Request $request)
    {
        $request->validate(['MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc']);
        $buoi = LichTrinhChiTiet::find($request->MaBuoiHoc);

        $buoi->ThoiGianDongDD = now();
        if ($buoi->NoiDungGiangDay) {
            $buoi->TrangThaiBuoiHoc = 'HoanThanh';
        } else {
            $buoi->TrangThaiBuoiHoc = 'ChuaHoanThanh';
        }
        $buoi->save();

        return response()->json(['message' => '🔒 Đã đóng điểm danh!', 'data' => $buoi]);
    }

    // ==================== 🧾 BÁO CÁO BUỔI HỌC ====================
    public function baoCaoBuoiHoc(Request $request)
    {
        $request->validate([
            'MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc',
            'NoiDungGiangDay' => 'required|string'
        ]);

        $buoi = LichTrinhChiTiet::find($request->MaBuoiHoc);
        $buoi->NoiDungGiangDay = $request->NoiDungGiangDay;
        $buoi->TrangThaiBuoiHoc = 'HoanThanh';
        $buoi->save();

        return response()->json(['message' => '🧾 Báo cáo buổi học thành công!', 'data' => $buoi]);
    }

    // ==================== 📤 YÊU CẦU NGHỈ / DẠY BÙ ====================
    public function taoYeuCau(Request $request)
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        $request->validate([
            'MaBuoiHocNguon' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc',
            'LoaiYeuCau' => 'required|in:Nghi,DayBu',
            'LyDo' => 'required|string',
            'NgayDeNghiBu' => 'nullable|date',
            'CaDeNghiBu' => 'nullable|string',
            'MaPhongDeNghi' => 'nullable|exists:PhongHoc,MaPhong'
        ]);

        $yc = YeuCauThayDoiLich::create([
            'MaGV' => $gv->MaGV,
            'MaBuoiHocNguon' => $request->MaBuoiHocNguon,
            'LoaiYeuCau' => $request->LoaiYeuCau,
            'LyDo' => $request->LyDo,
            'NgayDeNghiBu' => $request->NgayDeNghiBu,
            'CaDeNghiBu' => $request->CaDeNghiBu,
            'MaPhongDeNghi' => $request->MaPhongDeNghi,
            'TrangThai' => 'ChoDuyet'
        ]);

        return response()->json(['message' => '📩 Gửi yêu cầu thành công!', 'data' => $yc]);
    }

    public function danhSachYeuCau()
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        $yeuCau = YeuCauThayDoiLich::where('MaGV', $gv->MaGV)
            ->orderByDesc('NgayDeXuat')
            ->get();

        return response()->json(['message' => '📋 Danh sách yêu cầu thay đổi lịch', 'data' => $yeuCau]);
    }

    // ==================== 📊 TIẾN ĐỘ GIẢNG DẠY ====================
    public function tienDo()
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        $data = DB::table('vthongketiendoLHP')
            ->where('MaGV', $gv->MaGV)
            ->get();

        return response()->json(['message' => '📈 Tiến độ giảng dạy', 'data' => $data]);
    }

    // ==================== 🔔 THÔNG BÁO ====================
    public function thongBao()
    {
        $user = Auth::user();

        $tb = ThongBaoNguoiNhan::with('thongBao')
            ->where('MaNguoiNhan', $user->MaND)
            ->orderByDesc('thongBao.ThoiGianGui')
            ->get();

        return response()->json(['message' => '🔔 Danh sách thông báo', 'data' => $tb]);
    }
}
