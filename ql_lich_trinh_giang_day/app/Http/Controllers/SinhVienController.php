<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class SinhVienController extends Controller
{
    /**
     * 1️⃣ Xem thông tin sinh viên
     */
    public function thongTin()
    {
        $user = Auth::user();

        $sv = DB::table('SinhVien')
            ->join('NguoiDung', 'SinhVien.MaND', '=', 'NguoiDung.MaND')
            ->leftJoin('DangKyHocPhan', 'SinhVien.MaSV', '=', 'DangKyHocPhan.MaSV')
            ->leftJoin('LopHocPhan', 'DangKyHocPhan.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->leftJoin('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->select(
                'SinhVien.MaSV',
                'NguoiDung.HoTen',
                'NguoiDung.Email',
                'SinhVien.MaLopHanhChinh',
                'SinhVien.NamNhapHoc',
                DB::raw('COUNT(DISTINCT LopHocPhan.MaLHP) AS SoLopDangKy')
            )
            ->where('NguoiDung.MaND', $user->MaND)
            ->groupBy(
                'SinhVien.MaSV',
                'NguoiDung.HoTen',
                'NguoiDung.Email',
                'SinhVien.MaLopHanhChinh',
                'SinhVien.NamNhapHoc'
            )
            ->first();

        if (!$sv) {
            return response()->json(['message' => 'Không tìm thấy thông tin sinh viên'], 404);
        }

        return response()->json([
            'message' => 'Thông tin sinh viên',
            'data' => $sv
        ]);
    }

    /**
     * 2️⃣ Lịch học hôm nay
     */
    public function lichHocHomNay()
    {
        $user = Auth::user();
        $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

        $today = Carbon::today()->toDateString();

        $lich = DB::table('DangKyHocPhan')
            ->join('LopHocPhan', 'DangKyHocPhan.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('LichTrinhChiTiet', 'LichTrinhChiTiet.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->leftJoin('PhongHoc', 'LichTrinhChiTiet.MaPhong', '=', 'PhongHoc.MaPhong')
            ->where('DangKyHocPhan.MaSV', $sv->MaSV)
            ->whereDate('LichTrinhChiTiet.NgayHoc', $today)
            ->select(
                'LichTrinhChiTiet.MaBuoiHoc',
                'MonHoc.TenMonHoc',
                'LichTrinhChiTiet.NgayHoc',
                'LichTrinhChiTiet.CaHoc',
                'PhongHoc.TenPhong',
                'LichTrinhChiTiet.TrangThaiBuoiHoc'
            )
            ->orderBy('LichTrinhChiTiet.CaHoc')
            ->get();

        return response()->json([
            'message' => 'Lịch học hôm nay',
            'data' => $lich
        ]);
    }

    /**
     * 3️⃣ Lịch học toàn học kỳ hoặc tìm kiếm theo môn
     */
    public function lichHocHocKy(Request $request)
    {
        $user = Auth::user();
        $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

        $query = DB::table('DangKyHocPhan')
            ->join('LopHocPhan', 'DangKyHocPhan.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->join('HocKy', 'LopHocPhan.MaHK', '=', 'HocKy.MaHK')
            ->where('DangKyHocPhan.MaSV', $sv->MaSV)
            ->select(
                'LopHocPhan.MaLHP',
                'LopHocPhan.TenLHP',
                'MonHoc.TenMonHoc',
                'HocKy.TenHK',
                'LopHocPhan.TrangThai'
            );

        if ($request->filled('maHK')) {
            $query->where('LopHocPhan.MaHK', $request->maHK);
        }

        if ($request->filled('keyword')) {
            $query->where('MonHoc.TenMonHoc', 'LIKE', '%' . $request->keyword . '%');
        }

        $data = $query->orderBy('LopHocPhan.TenLHP')->get();

        return response()->json([
            'message' => 'Danh sách lớp học phần / lịch học',
            'data' => $data
        ]);
    }
    public function lopHocPhanDaDangKy()
    {
        $user = Auth::user();
        $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

        if (!$sv) {
            return response()->json(['message' => 'Không tìm thấy sinh viên'], 404);
        }

        $data = DB::table('DangKyHocPhan')
            ->join('LopHocPhan', 'DangKyHocPhan.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->join('HocKy', 'LopHocPhan.MaHK', '=', 'HocKy.MaHK')
            ->leftJoin('PhanCong', 'LopHocPhan.MaLHP', '=', 'PhanCong.MaLHP')
            ->leftJoin('GiangVien', 'PhanCong.MaGV', '=', 'GiangVien.MaGV')
            ->leftJoin('NguoiDung AS GV', 'GiangVien.MaND', '=', 'GV.MaND')
            ->where('DangKyHocPhan.MaSV', $sv->MaSV)
            ->select(
                'LopHocPhan.MaLHP',
                'LopHocPhan.TenLHP',
                'MonHoc.TenMonHoc',
                'HocKy.TenHK',
                'GV.HoTen AS GiangVien',
                'LopHocPhan.TrangThai'
            )
            ->orderBy('HocKy.MaHK', 'desc')
            ->get();

        return response()->json([
            'message' => 'Danh sách lớp học phần đã đăng ký',
            'data' => $data
        ]);
    }
    /**
     * 🔔 Đăng ký một lớp học phần
     */
    public function dangKyHocPhan(Request $request)
    {
        $request->validate([
            'MaLHP' => 'required|exists:LopHocPhan,MaLHP'
        ]);

        $user = Auth::user();
        $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

        if (!$sv) {
            return response()->json(['message' => 'Không tìm thấy sinh viên'], 404);
        }

        // Kiểm tra xem lớp còn chỗ không
        $lhp = DB::table('LopHocPhan')->where('MaLHP', $request->MaLHP)->first();
        $soLuongDaDK = DB::table('DangKyHocPhan')->where('MaLHP', $request->MaLHP)->count();

        if ($soLuongDaDK >= $lhp->SiSoToiDa) {
            return response()->json(['message' => 'Lớp học phần đã đầy, không thể đăng ký thêm'], 400);
        }

        // Kiểm tra trùng đăng ký
        $tonTai = DB::table('DangKyHocPhan')
            ->where('MaLHP', $request->MaLHP)
            ->where('MaSV', $sv->MaSV)
            ->exists();

        if ($tonTai) {
            return response()->json(['message' => 'Bạn đã đăng ký lớp học phần này rồi'], 409);
        }

        // Thực hiện đăng ký
        DB::table('DangKyHocPhan')->insert([
            'MaLHP' => $request->MaLHP,
            'MaSV' => $sv->MaSV,
            'ThoiGian' => now()
        ]);

        return response()->json(['message' => 'Đăng ký lớp học phần thành công']);
    }

    /**
     * 4️⃣ Điểm danh
     */
    public function diemDanh(Request $request)
    {
        $request->validate([
            'MaBuoiHoc' => 'required|integer',
            'TrangThaiDD' => 'required|string|in:CoMat,Vang,Muon,CoPhep'
        ]);

        $user = Auth::user();
        $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

        $buoi = DB::table('LichTrinhChiTiet')->find($request->MaBuoiHoc);
        if (!$buoi) return response()->json(['message' => 'Không tồn tại buổi học'], 404);

        $now = Carbon::now();
        if ($buoi->ThoiGianMoDD && $buoi->ThoiGianDongDD) {
            if ($now->lt(Carbon::parse($buoi->ThoiGianMoDD)) || $now->gt(Carbon::parse($buoi->ThoiGianDongDD))) {
                return response()->json(['message' => 'Không nằm trong thời gian điểm danh'], 403);
            }
        }

        DB::table('DiemDanh')->updateOrInsert(
            ['MaBuoiHoc' => $request->MaBuoiHoc, 'MaSV' => $sv->MaSV],
            [
                'TrangThaiDD' => $request->TrangThaiDD,
                'ThoiGianDiemDanh' => $now,
                'GhiChu' => $request->GhiChu ?? null
            ]
        );

        return response()->json(['message' => 'Điểm danh thành công']);
    }

    /**
     * 5️⃣ Lịch sử điểm danh
     */
    public function lichSuDiemDanh(Request $request)
    {
        $user = Auth::user();
        $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

        $query = DB::table('DiemDanh')
            ->join('LichTrinhChiTiet', 'DiemDanh.MaBuoiHoc', '=', 'LichTrinhChiTiet.MaBuoiHoc')
            ->join('LopHocPhan', 'LichTrinhChiTiet.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->where('DiemDanh.MaSV', $sv->MaSV)
            ->select(
                'MonHoc.TenMonHoc',
                'LichTrinhChiTiet.NgayHoc',
                'LichTrinhChiTiet.CaHoc',
                'DiemDanh.TrangThaiDD',
                'DiemDanh.ThoiGianDiemDanh'
            );

        if ($request->filled('maLHP')) {
            $query->where('LopHocPhan.MaLHP', $request->maLHP);
        }

        $data = $query->orderByDesc('LichTrinhChiTiet.NgayHoc')->get();

        return response()->json(['message' => 'Lịch sử điểm danh', 'data' => $data]);
    }

    /**
     * 6️⃣ Thống kê chuyên cần (view vThongKeChuyenCanSV)
     */
    public function thongKeChuyenCan()
    {
        $user = Auth::user();
        $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

        $data = DB::table('vThongKeChuyenCanSV')
            ->where('MaSV', $sv->MaSV)
            ->select('MaLHP', 'TenMonHoc', 'TongBuoi', 'SoBuoiCoMat', 'TiLeChuyenCan')
            ->get();

        return response()->json(['message' => 'Thống kê chuyên cần', 'data' => $data]);
    }

    /**
     * 7️⃣ Xem thông báo
     */
    public function thongBao()
    {
        $user = Auth::user();

        $data = DB::table('ThongBao_NguoiNhan')
            ->join('ThongBao', 'ThongBao.MaThongBao', '=', 'ThongBao_NguoiNhan.MaThongBao')
            ->join('NguoiDung AS NguoiGui', 'ThongBao.NguoiGui', '=', 'NguoiGui.MaND')
            ->where('ThongBao_NguoiNhan.MaNguoiNhan', $user->MaND)
            ->select(
                'ThongBao.MaThongBao',
                'ThongBao.TieuDe',
                'ThongBao.NoiDung',
                'NguoiGui.HoTen AS NguoiGui',
                'ThongBao.ThoiGianGui',
                'ThongBao_NguoiNhan.TrangThaiDoc'
            )
            ->orderByDesc('ThongBao.ThoiGianGui')
            ->get();

        return response()->json(['message' => 'Danh sách thông báo', 'data' => $data]);
    }
}
