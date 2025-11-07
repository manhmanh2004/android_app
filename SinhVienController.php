<?php

namespace App\Http\Controllers;
use App\Models\SinhVien;
use App\Models\LopHocPhan;
use App\Models\DiemDanh;
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
     * 8️⃣ Buổi học đang mở điểm danh
     */
    public function buoiHocDangMoDD()
    {
        $user = Auth::user();
        $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

        if (!$sv) {
            return response()->json(['message' => 'Không tìm thấy sinh viên'], 404);
        }

        $now = Carbon::now();

        $data = DB::table('DangKyHocPhan')
            ->join('LopHocPhan', 'DangKyHocPhan.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('LichTrinhChiTiet', 'LichTrinhChiTiet.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->leftJoin('PhongHoc', 'LichTrinhChiTiet.MaPhong', '=', 'PhongHoc.MaPhong')
            ->leftJoin('DiemDanh', function ($join) use ($sv) {
                $join->on('DiemDanh.MaBuoiHoc', '=', 'LichTrinhChiTiet.MaBuoiHoc')
                     ->where('DiemDanh.MaSV', '=', $sv->MaSV);
            })
            ->where('DangKyHocPhan.MaSV', $sv->MaSV)
            ->whereNotNull('LichTrinhChiTiet.ThoiGianMoDD')
            ->whereNotNull('LichTrinhChiTiet.ThoiGianDongDD')
            ->where('LichTrinhChiTiet.ThoiGianMoDD', '<=', $now)
            ->where('LichTrinhChiTiet.ThoiGianDongDD', '>=', $now)
            ->select(
                'LichTrinhChiTiet.MaBuoiHoc',
                'MonHoc.TenMonHoc',
                'LopHocPhan.TenLHP',
                'LichTrinhChiTiet.NgayHoc',
                'LichTrinhChiTiet.CaHoc',
                'PhongHoc.TenPhong',
                'LichTrinhChiTiet.ThoiGianMoDD',
                'LichTrinhChiTiet.ThoiGianDongDD',
                'DiemDanh.TrangThaiDD'
            )
            ->orderBy('LichTrinhChiTiet.ThoiGianMoDD', 'asc')
            ->get();

        return response()->json([
            'message' => 'Các buổi học đang mở điểm danh',
            'data' => $data
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
//chi tiet lop hp
    public function getLichTheoLHP($maLHP)
{
    if (empty($maLHP)) {
        return response()->json([
            'message' => '⚠️ Thiếu mã lớp học phần (maLHP)',
            'data' => [],
        ], 400);
    }

    $lich = \App\Models\LichTrinhChiTiet::with([
        'lopHocPhan.monHoc',
        'lopHocPhan.hocKy',
        'phongHoc'
    ])
        ->where('MaLHP', $maLHP)
        ->orderBy('NgayHoc', 'asc')
        ->get();

    if ($lich->isEmpty()) {
        return response()->json([
            'message' => '⛔ Chưa có lịch học nào cho lớp học phần này.',
            'count' => 0,
            'data' => []
        ]);
    }

    return response()->json([
        'message' => '📅 Danh sách lịch học chi tiết của lớp học phần',
        'count' => $lich->count(),
        'data' => $lich
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

    // ✅ Sửa chỗ này
    $buoi = DB::table('LichTrinhChiTiet')->where('MaBuoiHoc', $request->MaBuoiHoc)->first();
    if (!$buoi) {
        return response()->json(['message' => 'Không tồn tại buổi học'], 404);
    }

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

    public function chiTietChuyenCan(Request $request)
{
    $maLHP = $request->query('maLHP');
    $user = Auth::user();
    $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

    if (!$maLHP || !$sv) {
        return response()->json([
            'message' => 'Thiếu mã lớp học phần hoặc sinh viên không tồn tại',
            'data' => []
        ], 400);
    }

    // Lấy thông tin lớp học phần
    $lhp = DB::table('LopHocPhan')
        ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
        ->where('LopHocPhan.MaLHP', $maLHP)
        ->select('LopHocPhan.TenLHP', 'MonHoc.TenMonHoc')
        ->first();

    if (!$lhp) {
        return response()->json(['message' => 'Không tìm thấy lớp học phần', 'data' => []], 404);
    }

    // Lấy danh sách buổi học
    $buoiHoc = DB::table('LichTrinhChiTiet')
        ->leftJoin('DiemDanh', function ($join) use ($sv) {
            $join->on('LichTrinhChiTiet.MaBuoiHoc', '=', 'DiemDanh.MaBuoiHoc')
                ->where('DiemDanh.MaSV', '=', $sv->MaSV);
        })
        ->leftJoin('PhongHoc', 'LichTrinhChiTiet.MaPhong', '=', 'PhongHoc.MaPhong')
        ->where('LichTrinhChiTiet.MaLHP', $maLHP)
        ->select(
            'LichTrinhChiTiet.MaBuoiHoc',
            'LichTrinhChiTiet.NgayHoc',
            'LichTrinhChiTiet.CaHoc',
            'PhongHoc.TenPhong AS PhongHoc',
            'LichTrinhChiTiet.TrangThaiBuoiHoc',
            'DiemDanh.TrangThaiDD'
        )
        ->orderBy('LichTrinhChiTiet.NgayHoc')
        ->get();

    $tongBuoi = $buoiHoc->count();
    $soBuoiCoMat = $buoiHoc->whereIn('TrangThaiDD', ['CoMat', 'CoPhep'])->count();

    return response()->json([
        'message' => 'Chi tiết chuyên cần lớp học phần',
        'data' => [
            'TenMonHoc' => $lhp->TenMonHoc,
            'TenLHP' => $lhp->TenLHP,
            'TongBuoi' => $tongBuoi,
            'SoBuoiCoMat' => $soBuoiCoMat,
            'BuoiHoc' => $buoiHoc
        ]
    ]);
}


    /**
     * 6️⃣ Thống kê chuyên cần (view vThongKeChuyenCanSV)
     */
public function thongKeChuyenCan()
{
    $user = Auth::user();
    $sv = DB::table('SinhVien')->where('MaND', $user->MaND)->first();

    if (!$sv) {
        return response()->json(['message' => 'Không tìm thấy sinh viên'], 404);
    }

    // 🔹 Lấy tất cả lớp học phần mà sinh viên đã đăng ký
    $lopHocPhans = DB::table('DangKyHocPhan')
        ->join('LopHocPhan', 'DangKyHocPhan.MaLHP', '=', 'LopHocPhan.MaLHP')
        ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
        ->join('HocKy', 'LopHocPhan.MaHK', '=', 'HocKy.MaHK')
        ->where('DangKyHocPhan.MaSV', $sv->MaSV)
        ->select(
            'LopHocPhan.MaLHP',
            'LopHocPhan.TenLHP',
            'MonHoc.TenMonHoc',
            'HocKy.TenHK'
        )
        ->get();

    $result = [];

    foreach ($lopHocPhans as $lhp) {
        // Tổng số buổi học của lớp học phần này
        $tongBuoi = DB::table('LichTrinhChiTiet')
            ->where('MaLHP', $lhp->MaLHP)
            ->count();

        // Số buổi sinh viên có mặt hoặc có phép
        $soBuoiCoMat = DB::table('DiemDanh')
            ->join('LichTrinhChiTiet', 'DiemDanh.MaBuoiHoc', '=', 'LichTrinhChiTiet.MaBuoiHoc')
            ->where('LichTrinhChiTiet.MaLHP', $lhp->MaLHP)
            ->where('DiemDanh.MaSV', $sv->MaSV)
            ->whereIn('DiemDanh.TrangThaiDD', ['CoMat', 'CoPhep'])
            ->count();

        // Số buổi vắng
        $soBuoiVang = DB::table('DiemDanh')
            ->join('LichTrinhChiTiet', 'DiemDanh.MaBuoiHoc', '=', 'LichTrinhChiTiet.MaBuoiHoc')
            ->where('LichTrinhChiTiet.MaLHP', $lhp->MaLHP)
            ->where('DiemDanh.MaSV', $sv->MaSV)
            ->where('DiemDanh.TrangThaiDD', 'Vang')
            ->count();

        // Tính tỷ lệ chuyên cần (%)
        $tiLe = $tongBuoi > 0 ? round(($soBuoiCoMat / $tongBuoi) * 100, 2) : 0;

        $result[] = [
            'MaLHP' => $lhp->MaLHP,
            'TenMonHoc' => $lhp->TenMonHoc,
            'TenLHP' => $lhp->TenLHP,
            'TenHK' => $lhp->TenHK,
            'TongBuoi' => $tongBuoi,
            'SoBuoiCoMat' => $soBuoiCoMat,
            'SoBuoiVang' => $soBuoiVang,
            'TiLeChuyenCan' => $tiLe,
        ];
    }

    // 🔹 Nếu không có lớp học phần nào
    if (empty($result)) {
        return response()->json([
            'message' => 'Chưa có dữ liệu chuyên cần',
            'data' => []
        ]);
    }

    return response()->json([
        'message' => 'Thống kê chuyên cần theo lớp học phần',
        'data' => $result
    ]);
}

public function danhDauDaDoc(Request $request)
{
    $maThongBao = $request->input('ma_thong_bao');
    $maNguoiNhan = $request->input('ma_nguoi_nhan');

    if (!$maThongBao || !$maNguoiNhan) {
        return response()->json(['message' => 'Thiếu thông tin cần thiết'], 400);
    }

    $thongBaoNguoiNhan = \App\Models\ThongBaoNguoiNhan::where('MaThongBao', $maThongBao)
        ->where('MaNguoiNhan', $maNguoiNhan)
        ->first();

    if (!$thongBaoNguoiNhan) {
        return response()->json(['message' => 'Không tìm thấy bản ghi'], 404);
    }

    $thongBaoNguoiNhan->TrangThaiDoc = 1;
    $thongBaoNguoiNhan->save();

    return response()->json([
        'status' => true,
        'message' => 'Đã cập nhật trạng thái đọc thành công',
    ]);
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
    public function tienDoTongQuan()
    {
        $user = Auth::user();
        $userId = $user ? $user->MaND : null;

        $sv = \App\Models\SinhVien::where('MaND', $userId)->first();

        if (!$sv) {
            return response()->json(['message' => 'Không tìm thấy sinh viên'], 404);
        }

        // 🔹 Lấy tất cả lớp học phần sinh viên đã đăng ký
        $lopHocPhans = LopHocPhan::with(['monHoc', 'lichTrinhChiTiet'])
            ->whereHas('sinhViens', function ($q) use ($sv) {
                $q->where('SinhVien.MaSV', $sv->MaSV);
            })
            ->get();

        if ($lopHocPhans->isEmpty()) {
            return response()->json([
                'ChuyenCanTB' => 0,
                'MonHoc' => []
            ]);
        }

        $tongTienDo = 0;
        $monHocData = [];

        foreach ($lopHocPhans as $lhp) {
            $tongBuoi = $lhp->lichTrinhChiTiet->count();

            $soBuoiCoMat = DiemDanh::whereIn('MaBuoiHoc', $lhp->lichTrinhChiTiet->pluck('MaBuoiHoc'))
                ->where('MaSV', $sv->MaSV)
                ->whereIn('TrangThaiDD', ['CoMat', 'CoPhep'])
                ->count();

            $tienDo = $tongBuoi > 0 ? round(($soBuoiCoMat / $tongBuoi) * 100) : 0;

            $monHocData[] = [
                'TenMonHoc' => $lhp->monHoc->TenMonHoc ?? '—',
                'TienDo' => $tienDo,
            ];

            $tongTienDo += $tienDo;
        }

        $chuyenCanTB = count($monHocData) > 0 ? round($tongTienDo / count($monHocData)) : 0;

        return response()->json([
            'ChuyenCanTB' => $chuyenCanTB,
            'MonHoc' => $monHocData
        ]);
    }

}
