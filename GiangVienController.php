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
use Carbon\Carbon;

class GiangVienController extends Controller
{
    // ==================== 🧑‍🏫 THÔNG TIN GIẢNG VIÊN ====================
    public function thongTin()
    {
        $user = Auth::user();

        // Lấy thông tin giảng viên theo tài khoản đăng nhập
        $gv = GiangVien::with('boMon.khoa')
            ->where('MaND', $user->MaND)
            ->first();

        if (!$gv) {
            return response()->json(['message' => 'Không tìm thấy thông tin giảng viên'], 404);
        }

        // Bổ sung dữ liệu từ bảng NguoiDung
        $gv->HoTen = $user->HoTen;
        $gv->Email = $user->Email;

        return response()->json([
            'MaGV' => $gv->MaGV,
            'HoTen' => $gv->HoTen,
            'Email' => $gv->Email,
            'TrinhDo' => $gv->TrinhDo,
            'BoMon' => $gv->boMon->TenBoMon ?? null,
            'Khoa' => $gv->boMon->khoa->TenKhoa ?? null,
        ]);
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

    // ==================== 🗓️ LỊCH DẠY THEO THÁNG ====================
    public function lichDayTheoThang($year, $month)
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        if (!$gv) {
            return response()->json(['message' => 'Không tìm thấy giảng viên'], 404);
        }

        $ngayCoHoc = LichTrinhChiTiet::select('NgayHoc')
            ->join('LopHocPhan', 'LichTrinhChiTiet.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('PhanCong', 'LopHocPhan.MaLHP', '=', 'PhanCong.MaLHP')
            ->where('PhanCong.MaGV', $gv->MaGV)
            ->whereYear('LichTrinhChiTiet.NgayHoc', $year)
            ->whereMonth('LichTrinhChiTiet.NgayHoc', $month)
            ->distinct()
            ->pluck('NgayHoc')
            ->map(fn($d) => date('Y-m-d', strtotime($d)))
            ->toArray();

        $start = Carbon::createFromDate($year, $month, 1);
        $end = $start->copy()->endOfMonth();
        $days = [];

        for ($date = $start->copy(); $date->lte($end); $date->addDay()) {
            $ngay = $date->format('Y-m-d');
            $days[] = [
                'Ngay' => $ngay,
                'CoHoc' => in_array($ngay, $ngayCoHoc)
            ];
        }

        return response()->json([
            'message' => "📅 Lịch dạy tháng {$month}/{$year}",
            'data' => $days
        ]);
    }

    // ==================== ✅ MỞ ĐIỂM DANH (CÓ KHUNG GIỜ) ====================
    public function moDiemDanh(Request $request)
    {
        $request->validate([
            'MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc',
            'ThoiGianMoDD' => 'required|date',
            'ThoiGianDongDD' => 'required|date|after:ThoiGianMoDD'
        ]);

        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();
        $buoi = LichTrinhChiTiet::find($request->MaBuoiHoc);

        if (!$buoi) {
            return response()->json(['message' => 'Không tìm thấy buổi học'], 404);
        }

        $isAssigned = DB::table('PhanCong')
            ->where('MaLHP', $buoi->MaLHP)
            ->where('MaGV', $gv->MaGV)
            ->exists();

        if (!$isAssigned) {
            return response()->json(['message' => 'Buổi học này không thuộc quyền giảng viên'], 403);
        }

        $buoi->TrangThaiBuoiHoc = 'DangDiemDanh';
        $buoi->ThoiGianMoDD = $request->ThoiGianMoDD;
        $buoi->ThoiGianDongDD = $request->ThoiGianDongDD;
        $buoi->save();

        return response()->json(['message' => '🔓 Đã mở điểm danh với khung giờ!', 'data' => $buoi]);
    }

    // ==================== 🧾 TẠO DANH SÁCH ĐIỂM DANH THEO BUỔI ====================
    public function taoDanhSachDiemDanh(Request $request)
    {
        $request->validate([
            'MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc',
        ]);

        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();
        $buoi = LichTrinhChiTiet::with(['lopHocPhan.monHoc', 'lopHocPhan.hocKy'])->find($request->MaBuoiHoc);

        if (!$buoi) {
            return response()->json(['message' => 'Không tìm thấy buổi học'], 404);
        }

        $isAssigned = DB::table('PhanCong')
            ->where('MaLHP', $buoi->MaLHP)
            ->where('MaGV', $gv->MaGV)
            ->exists();

        if (!$isAssigned) {
            return response()->json(['message' => 'Buổi học này không thuộc quyền giảng viên'], 403);
        }

        $sinhVien = DB::table('DangKyHocPhan')->where('MaLHP', $buoi->MaLHP)->pluck('MaSV');
        foreach ($sinhVien as $maSV) {
            DiemDanh::firstOrCreate([
                'MaBuoiHoc' => $buoi->MaBuoiHoc,
                'MaSV' => $maSV,
            ], [
                'TrangThaiDD' => 'ChuaDiemDanh'
            ]);
        }

        $buoi->TrangThaiBuoiHoc = 'DangDiemDanh';
        $buoi->ThoiGianMoDD = now();
        $buoi->save();

        return response()->json([
            'message' => '✅ Đã tạo danh sách điểm danh!',
            'data' => [
                'MaBuoiHoc' => $buoi->MaBuoiHoc,
                'TenMonHoc' => $buoi->lopHocPhan->monHoc->TenMonHoc,
                'MaMonHoc' => $buoi->lopHocPhan->monHoc->MaMonHoc,
                'MaLHP' => $buoi->MaLHP,
                'MaGV' => $gv->MaGV,
                'TenGiangVien' => $gv->HoTen,
                'KyHoc' => $buoi->lopHocPhan->hocKy->TenHK,
            ]
        ]);
    }

    // ==================== 🧾 GHI ĐIỂM DANH (CÓ KIỂM TRA HẾT GIỜ) ====================
    public function ghiDiemDanh(Request $request)
    {
        $request->validate([
            'MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc',
            'DanhSach' => 'required|array|min:1',
            'DanhSach.*.MaSV' => 'required|exists:SinhVien,MaSV',
            'DanhSach.*.TrangThaiDD' => 'required|string|in:CoMat,Vang,Muon,CoPhep,ChuaDiemDanh'
        ]);

        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();
        $buoi = LichTrinhChiTiet::find($request->MaBuoiHoc);

        $isAssigned = DB::table('PhanCong')
            ->where('MaLHP', $buoi->MaLHP)
            ->where('MaGV', $gv->MaGV)
            ->exists();

        if (!$isAssigned)
            return response()->json(['message' => 'Buổi học này không thuộc quyền giảng viên'], 403);

        // ⏰ Kiểm tra thời gian hết hạn
        $now = Carbon::now();
        if ($buoi->ThoiGianDongDD && $now->gt(Carbon::parse($buoi->ThoiGianDongDD))) {
            return response()->json(['message' => '❌ Hết thời gian điểm danh!'], 403);
        }

        foreach ($request->DanhSach as $item) {
            DiemDanh::updateOrCreate(
                [
                    'MaBuoiHoc' => $request->MaBuoiHoc,
                    'MaSV' => $item['MaSV']
                ],
                [
                    'TrangThaiDD' => $item['TrangThaiDD'],
                    'GhiChu' => $item['GhiChu'] ?? null
                ]
            );
        }

        $buoi->TrangThaiBuoiHoc = 'DaDiemDanh';
        $buoi->ThoiGianDongDD = now();
        $buoi->save();

        return response()->json(['message' => '📝 Ghi điểm danh thành công!']);
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

        // 🔹 Lấy tất cả lớp học phần mà giảng viên phụ trách
        $lopHocPhan = DB::table('PhanCong')
            ->where('MaGV', $gv->MaGV)
            ->pluck('MaLHP');

        // 🔹 Tính thống kê cho từng lớp
        $data = DB::table('LopHocPhan')
            ->whereIn('MaLHP', $lopHocPhan)
            ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->select(
                'LopHocPhan.MaLHP',
                'LopHocPhan.TenLHP',
                'MonHoc.TenMonHoc',
                DB::raw('(SELECT COUNT(*) FROM LichTrinhChiTiet WHERE MaLHP = LopHocPhan.MaLHP) AS TongBuoi'),
                DB::raw('(SELECT COUNT(*) FROM LichTrinhChiTiet WHERE MaLHP = LopHocPhan.MaLHP AND TrangThaiBuoiHoc IN ("HoanThanh","DaDiemDanh")) AS DaDay')
            )
            ->get()
            ->map(function ($item) {
                $item->TienDo = $item->TongBuoi > 0
                    ? round(($item->DaDay / $item->TongBuoi) * 100, 1)
                    : 0;
                return $item;
            });

        return response()->json([
            'message' => '📊 Thống kê tiến độ giảng dạy',
            'data' => $data
        ]);
    }

    // ==================== 🔔 THÔNG BÁO ====================
    // ==================== 🔔 THÔNG BÁO (CÓ TÌM KIẾM) ====================
    public function thongBao(Request $request)
    {
        $user = Auth::user();
        $keyword = $request->input('keyword'); // 🔍 từ khóa tìm kiếm (tùy chọn)

        $query = ThongBaoNguoiNhan::join('ThongBao', 'ThongBao.MaThongBao', '=', 'ThongBao_NguoiNhan.MaThongBao')
            ->where('ThongBao_NguoiNhan.MaNguoiNhan', $user->MaND)
            ->select(
                'ThongBao_NguoiNhan.*',
                'ThongBao.TieuDe',
                'ThongBao.NoiDung',
                'ThongBao.ThoiGianGui'
            )
            ->orderByDesc('ThongBao.ThoiGianGui');

        // 🔎 Nếu có keyword → lọc theo tiêu đề hoặc nội dung
        if (!empty($keyword)) {
            $query->where(function ($q) use ($keyword) {
                $q->where('ThongBao.TieuDe', 'LIKE', "%$keyword%");
            });
        }

        $tb = $query->get();

        return response()->json([
            'message' => $keyword
                ? "🔔 Kết quả tìm kiếm thông báo với từ khóa '$keyword'"
                : '🔔 Danh sách thông báo',
            'data' => $tb
        ]);
    }
    public function XoaThongBao($maThongBao)
    {
        $user = Auth::user();

        // Kiểm tra thông báo tồn tại cho người này chưa
        $exists = ThongBaoNguoiNhan::where('MaThongBao', $maThongBao)
            ->where('MaNguoiNhan', $user->MaND)
            ->exists();

        if (!$exists) {
            return response()->json([
                'message' => 'Không tìm thấy thông báo cho người dùng này.'
            ], 404);
        }

        // Xóa thông báo
        ThongBaoNguoiNhan::where('MaThongBao', $maThongBao)
            ->where('MaNguoiNhan', $user->MaND)
            ->delete();

        return response()->json([
            'message' => 'Đã xóa thông báo.',
            'MaThongBao' => $maThongBao,
            'MaNguoiNhan' => $user->MaND
        ]);
    }

    public function dongDiemDanh(Request $request)
    {
        $request->validate(['MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc']);
        $buoi = LichTrinhChiTiet::find($request->MaBuoiHoc);

        // 🔹 1. Cập nhật sinh viên chưa điểm danh => "Vắng"
        DB::table('DiemDanh')
            ->where('MaBuoiHoc', $buoi->MaBuoiHoc)
            ->where('TrangThaiDD', 'ChuaDiemDanh')
            ->update(['TrangThaiDD' => 'Vang']);

        // 🔹 2. Cập nhật trạng thái buổi học
        $buoi->TrangThaiBuoiHoc = 'DaDiemDanh';
        $buoi->ThoiGianDongDD = now();
        $buoi->save();

        return response()->json([
            'message' => '🔒 Đã đóng điểm danh! Các sinh viên chưa điểm danh được đánh là VẮNG.',
            'data' => $buoi
        ]);
    }
    // ==================== 🧾 LẤY DANH SÁCH SINH VIÊN THEO BUỔI HỌC ====================
    public function danhSachDiemDanh($maBuoiHoc)
    {
        $buoi = LichTrinhChiTiet::with('lopHocPhan.sinhViens.nguoiDung')
            ->find($maBuoiHoc);

        if (!$buoi) {
            return response()->json(['message' => 'Không tìm thấy buổi học'], 404);
        }

        // 🔹 Lấy danh sách sinh viên thuộc lớp học phần
        $sinhVienLop = $buoi->lopHocPhan->sinhViens;

        // 🔹 Lấy trạng thái điểm danh của sinh viên (nếu đã có)
        $diemDanhData = DiemDanh::where('MaBuoiHoc', $maBuoiHoc)
            ->pluck('TrangThaiDD', 'MaSV');

        // 🔹 Kết hợp lại danh sách
        $danhSach = $sinhVienLop->map(function ($sv) use ($diemDanhData) {
            return [
                'MaSV' => $sv->MaSV,
                'HoTen' => $sv->nguoiDung->HoTen ?? '',
                'Email' => $sv->nguoiDung->Email ?? '',
                'TrangThaiDD' => $diemDanhData[$sv->MaSV] ?? 'ChuaDiemDanh'
            ];
        });

        return response()->json([
            'message' => '📋 Danh sách sinh viên theo buổi học',
            'data' => $danhSach
        ]);
    }

    // ==================== ✅ ĐÁNH DẤU ĐÃ ĐỌC THÔNG BÁO ====================
    public function danhDauThongBaoDaDoc($maThongBao)
    {
        $user = Auth::user();

        // Kiểm tra thông báo tồn tại cho người này chưa
        $exists = ThongBaoNguoiNhan::where('MaThongBao', $maThongBao)
            ->where('MaNguoiNhan', $user->MaND)
            ->exists();

        if (!$exists) {
            return response()->json([
                'message' => 'Không tìm thấy thông báo cho người dùng này.'
            ], 404);
        }

        // Cập nhật trạng thái đã đọc
        ThongBaoNguoiNhan::where('MaThongBao', $maThongBao)
            ->where('MaNguoiNhan', $user->MaND)
            ->update(['TrangThaiDoc' => 1]);

        return response()->json([
            'message' => 'Đã đánh dấu thông báo là đã đọc.',
            'MaThongBao' => $maThongBao,
            'MaNguoiNhan' => $user->MaND
        ]);
    }
    public function kiemTraDongDiemDanh(Request $request)
    {
        $request->validate([
            'MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc',
        ]);

        $buoi = LichTrinhChiTiet::find($request->MaBuoiHoc);

        if (!$buoi) {
            return response()->json(['message' => 'Không tìm thấy buổi học'], 404);
        }

        // Nếu chưa tới giờ đóng thì không làm gì
        if (!$buoi->ThoiGianDongDD || now()->lt(Carbon::parse($buoi->ThoiGianDongDD))) {
            return response()->json([
                'message' => '⏳ Chưa tới thời gian đóng điểm danh',
                'data' => $buoi,
            ]);
        }

        // Nếu buổi học chưa được đóng => tự động đóng
        if ($buoi->TrangThaiBuoiHoc === 'DangDiemDanh') {
            DB::table('DiemDanh')
                ->where('MaBuoiHoc', $buoi->MaBuoiHoc)
                ->where('TrangThaiDD', 'ChuaDiemDanh')
                ->update(['TrangThaiDD' => 'Vang']);

            $buoi->TrangThaiBuoiHoc = 'DaDiemDanh';
            $buoi->ThoiGianDongDD = now();
            $buoi->save();

            return response()->json([
                'message' => '🔒 Đã tự động đóng điểm danh!',
                'data' => $buoi,
            ]);
        }

        return response()->json([
            'message' => '✅ Buổi học đã được đóng trước đó.',
            'data' => $buoi,
        ]);
    }
    // ==================== 🎓 LỌC LỊCH DẠY THEO MÔN HỌC ====================
    public function lichTheoMon(Request $request)
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        $maMon = $request->input('MaMon'); // mã môn cần lọc (tùy chọn)
        $query = LichTrinhChiTiet::with([
            'lopHocPhan.monHoc',
            'lopHocPhan.hocKy',
            'phongHoc'
        ])
            ->whereHas('lopHocPhan.phanCongs', fn($q) => $q->where('MaGV', $gv->MaGV));

        if (!empty($maMon)) {
            $query->whereHas('lopHocPhan.monHoc', fn($q) => $q->where('MaMonHoc', $maMon));
        }

        $lich = $query->orderByDesc('NgayHoc')->get();

        return response()->json([
            'message' => $maMon
                ? "📚 Lịch dạy của giảng viên cho môn $maMon"
                : "📚 Lịch dạy tất cả môn học",
            'data' => $lich
        ]);
    }
    // ==================== 🗂️ LỌC YÊU CẦU THEO TRẠNG THÁI ====================
    // ==================== 🗂️ LỌC YÊU CẦU THEO TRẠNG THÁI + NGÀY + TỪ KHÓA ====================
    public function locYeuCau(Request $request)
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        $trangThai = $request->input('TrangThai'); // ChoDuyet, DaDuyet, TuChoi (tùy chọn)
        $keyword = $request->input('keyword');   // tìm theo loại yêu cầu / lý do (tùy chọn)
        $fromDate = $request->input('from');      // lọc từ ngày (YYYY-MM-DD)
        $toDate = $request->input('to');        // lọc đến ngày (YYYY-MM-DD)

        $query = YeuCauThayDoiLich::where('MaGV', $gv->MaGV)
            ->orderByDesc('NgayDeXuat');

        // 🔹 Lọc trạng thái
        if (!empty($trangThai)) {
            $query->where('TrangThai', $trangThai);
        }

        // 🔹 Lọc theo từ khóa (Loại yêu cầu hoặc Lý do)
        if (!empty($keyword)) {
            $query->where(function ($q) use ($keyword) {
                $q->where('LoaiYeuCau', 'LIKE', "%$keyword%")
                    ->orWhere('LyDo', 'LIKE', "%$keyword%");
            });
        }

        // 🔹 Lọc theo khoảng thời gian (nếu có)
        if (!empty($fromDate) && !empty($toDate)) {
            $query->whereBetween(DB::raw('DATE(NgayDeXuat)'), [$fromDate, $toDate]);
        } elseif (!empty($fromDate)) {
            $query->whereDate('NgayDeXuat', '>=', $fromDate);
        } elseif (!empty($toDate)) {
            $query->whereDate('NgayDeXuat', '<=', $toDate);
        }

        $yeuCau = $query->get();

        return response()->json([
            'message' => '📋 Kết quả lọc yêu cầu thay đổi lịch',
            'data' => $yeuCau
        ]);
    }
    // ==================== 🎓 LỌC LỊCH DẠY THEO NĂM HỌC - HỌC KỲ - MÔN HỌC ====================
    // ==================== 🎓 LỌC LỊCH DẠY THEO NĂM HỌC - HỌC KỲ - MÔN HỌC - KHOẢNG THỜI GIAN ====================
    public function locLichDay(Request $request)
    {
        $user = Auth::user();
        $gv = GiangVien::where('MaND', $user->MaND)->first();

        if (!$gv) {
            return response()->json(['message' => 'Không tìm thấy giảng viên'], 404);
        }

        // 🔹 Nhận các tham số lọc
        $namHoc = $request->input('NamHoc'); // ví dụ: 2025
        $hocKy = $request->input('HocKy');  // ví dụ: HK1, HK2, Học kỳ 1
        $maMon = $request->input('MaMonHoc'); // ví dụ: CSDL101
        $tenMon = $request->input('TenMonHoc'); // ví dụ: Cơ sở dữ liệu
        $fromDate = $request->input('from'); // lọc từ ngày (YYYY-MM-DD)
        $toDate = $request->input('to');   // lọc đến ngày (YYYY-MM-DD)

        // 🔹 Truy vấn lịch dạy có liên kết các bảng liên quan
        $query = LichTrinhChiTiet::with([
            'lopHocPhan.monHoc',
            'lopHocPhan.hocKy',
            'phongHoc'
        ])
            ->whereHas('lopHocPhan.phanCongs', fn($q) => $q->where('MaGV', $gv->MaGV));

        // 🔸 Lọc theo năm học
        if (!empty($namHoc)) {
            $query->whereYear('NgayHoc', $namHoc);
        }

        // 🔸 Lọc theo học kỳ
        if (!empty($hocKy)) {
            $query->whereHas('lopHocPhan.hocKy', function ($q) use ($hocKy) {
                $q->where('TenHK', 'LIKE', "%$hocKy%");
            });
        }

        // 🔸 Lọc theo mã môn học
        if (!empty($maMon)) {
            $query->whereHas('lopHocPhan.monHoc', function ($q) use ($maMon) {
                $q->where('MaMonHoc', 'LIKE', "%$maMon%");
            });
        }

        // 🔸 Lọc theo tên môn học
        if (!empty($tenMon)) {
            $query->whereHas('lopHocPhan.monHoc', function ($q) use ($tenMon) {
                $q->where('TenMonHoc', 'LIKE', "%$tenMon%");
            });
        }

        // 🔸 Lọc theo khoảng thời gian (nếu có)
        if ($fromDate && $toDate) {
            $query->whereBetween('NgayHoc', [$fromDate, $toDate]);
        } elseif ($fromDate) {
            $query->whereDate('NgayHoc', '>=', $fromDate);
        } elseif ($toDate) {
            $query->whereDate('NgayHoc', '<=', $toDate);
        }

        // 🔹 Sắp xếp theo ngày học mới nhất
        $lich = $query->orderByDesc('NgayHoc')->get();

        return response()->json([
            'message' => '📚 Kết quả lọc lịch dạy theo điều kiện',
            'data' => $lich
        ]);
    }





}

