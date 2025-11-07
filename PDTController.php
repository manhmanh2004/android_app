<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Khoa;
use App\Models\Nganh;
use App\Models\MonHoc;
use App\Models\HocKy;
use App\Models\PhongHoc;
use App\Models\LopHocPhan;
use App\Models\PhanCong;
use App\Models\NguoiDung;
use App\Models\NguoiDungVaiTro;
use App\Models\VaiTro;
use App\Models\GiangVien;
use App\Models\LichTrinhChiTiet;
use App\Models\BoMon;
use App\Models\YeuCauThayDoiLich;
use App\Models\ThongBao;
use App\Models\ThongBaoNguoiNhan;
use Maatwebsite\Excel\Facades\Excel;
use App\Models\SinhVien;
use App\Models\DangKyHocPhan;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;


class PDTController extends Controller
{
    // ===================== 🏫 QUẢN LÝ KHOA =====================
    public function getAllKhoa()
    {
        return response()->json(Khoa::all());
    }

    public function createKhoa(Request $request)
    {
        $request->validate(['TenKhoa' => 'required|unique:Khoa']);
        $khoa = Khoa::create(['TenKhoa' => $request->TenKhoa]);
        return response()->json(['message' => 'Thêm Khoa thành công', 'data' => $khoa]);
    }

    public function updateKhoa(Request $request, $id)
    {
        $khoa = Khoa::findOrFail($id);
        $khoa->update(['TenKhoa' => $request->TenKhoa]);
        return response()->json(['message' => 'Cập nhật Khoa thành công']);
    }

    public function deleteKhoa($id)
    {
        $khoa = Khoa::findOrFail($id);

        // 🔹 Xóa Bộ môn của Khoa
        BoMon::where('MaKhoa', $id)->delete();

        // 🔹 Xóa Ngành và các Môn học liên quan
        $nganhs = Nganh::where('MaKhoa', $id)->get();
        foreach ($nganhs as $nganh) {
            // Xóa các môn học thuộc ngành này
            $monHocs = MonHoc::where('MaNganh', $nganh->MaNganh)->get();
            foreach ($monHocs as $mon) {
                // Xóa lớp học phần liên quan
                $lhps = LopHocPhan::where('MaMonHoc', $mon->MaMonHoc)->get();
                foreach ($lhps as $lhp) {
                    PhanCong::where('MaLHP', $lhp->MaLHP)->delete();
                    LichTrinhChiTiet::where('MaLHP', $lhp->MaLHP)->delete();
                    DB::table('DangKyHocPhan')->where('MaLHP', $lhp->MaLHP)->delete();
                    $lhp->delete();
                }
                $mon->delete();
            }
            $nganh->delete();
        }

        // 🔹 Cuối cùng xóa Khoa
        $khoa->delete();

        return response()->json(['message' => '✅ Đã xóa Khoa và toàn bộ dữ liệu liên quan.']);
    }



    // ===================== 🎓 QUẢN LÝ NGÀNH =====================
    public function getAllNganh()
    {
        return response()->json(Nganh::with('khoa')->get());
    }

    public function createNganh(Request $request)
    {
        $request->validate([
            'TenNganh' => 'required|unique:Nganh',
            'MaKhoa' => 'required|exists:Khoa,MaKhoa'
        ]);
        $nganh = Nganh::create($request->only('TenNganh', 'MaKhoa'));
        return response()->json(['message' => 'Thêm Ngành thành công', 'data' => $nganh]);
    }

    public function updateNganh(Request $request, $id)
    {
        $nganh = Nganh::findOrFail($id);
        $nganh->update($request->only('TenNganh', 'MaKhoa'));
        return response()->json(['message' => 'Cập nhật Ngành thành công']);
    }

    public function deleteNganh($id)
    {
        $nganh = Nganh::findOrFail($id);

        // Xóa môn học thuộc ngành
        MonHoc::where('MaNganh', $id)->delete();

        $nganh->delete();

        return response()->json(['message' => '✅ Đã xóa Ngành và các Môn học liên quan.']);
    }


    // ===================== 📚 QUẢN LÝ MÔN HỌC =====================
    public function getAllMonHoc()
    {
        return response()->json(MonHoc::with('nganh')->get());
    }

    public function createMonHoc(Request $request)
    {
        $request->validate([
            'TenMonHoc' => 'required|unique:MonHoc',
            'SoTinChi' => 'required|integer|min:1',
            'SoTiet' => 'required|integer|min:1',
            'MaNganh' => 'required|exists:Nganh,MaNganh'
        ]);
        $mon = MonHoc::create($request->only('TenMonHoc', 'SoTinChi', 'SoTiet', 'MaNganh'));
        return response()->json(['message' => 'Thêm Môn học thành công', 'data' => $mon]);
    }

    public function updateMonHoc(Request $request, $id)
    {
        $mon = MonHoc::findOrFail($id);
        $mon->update($request->only('TenMonHoc', 'SoTinChi', 'SoTiet', 'MaNganh'));
        return response()->json(['message' => 'Cập nhật Môn học thành công']);
    }

    public function deleteMonHoc($id)
    {
        $mon = MonHoc::findOrFail($id);

        // Xóa lớp học phần của môn này (bao gồm lịch & phân công)
        $lhps = LopHocPhan::where('MaMonHoc', $id)->get();
        foreach ($lhps as $lhp) {
            PhanCong::where('MaLHP', $lhp->MaLHP)->delete();
            LichTrinhChiTiet::where('MaLHP', $lhp->MaLHP)->delete();
            $lhp->delete();
        }

        $mon->delete();

        return response()->json(['message' => '✅ Đã xóa Môn học và các lớp học phần liên quan.']);
    }


    // ===================== 🗓️ QUẢN LÝ HỌC KỲ =====================
    public function getAllHocKy()
    {
        return response()->json(HocKy::all());
    }

    public function createHocKy(Request $request)
    {
        $request->validate([
            'TenHK' => 'required|unique:HocKy',
            'NgayBatDau' => 'required|date',
            'NgayKetThuc' => 'required|date|after_or_equal:NgayBatDau'
        ]);
        $hk = HocKy::create($request->only('TenHK', 'NgayBatDau', 'NgayKetThuc'));
        return response()->json(['message' => 'Thêm Học kỳ thành công', 'data' => $hk]);
    }

    public function updateHocKy(Request $request, $id)
    {
        $hk = HocKy::findOrFail($id);
        $hk->update($request->only('TenHK', 'NgayBatDau', 'NgayKetThuc'));
        return response()->json(['message' => 'Cập nhật Học kỳ thành công']);
    }

    public function deleteHocKy($id)
    {
        HocKy::findOrFail($id)->delete();
        return response()->json(['message' => 'Xóa Học kỳ thành công']);
    }
    // bộ môn
    // ===================== 🏫 QUẢN LÝ BỘ MÔN =====================
    // ==================== 📘 API: BỘ MÔN ====================
    public function getAllBoMon()
    {
        try {
            $boMon = DB::table('BoMon as bm')
                ->join('Khoa as k', 'bm.MaKhoa', '=', 'k.MaKhoa')
                ->select('bm.*', 'k.TenKhoa')
                ->get()
                ->map(function ($item) {
                    return [
                        'MaBoMon' => $item->MaBoMon,
                        'TenBoMon' => $item->TenBoMon,
                        'MaKhoa' => $item->MaKhoa,
                        // Gói thông tin khoa thành object con
                        'khoa' => [
                            'TenKhoa' => $item->TenKhoa
                        ],
                    ];
                });

            return response()->json($boMon);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }


    public function createBoMon(Request $request)
    {
        $request->validate([
            'TenBoMon' => 'required|string|max:255',
            'MaKhoa' => 'required|integer|exists:Khoa,MaKhoa',
        ]);

        DB::table('BoMon')->insert([
            'TenBoMon' => $request->TenBoMon,
            'MaKhoa' => $request->MaKhoa,
        ]);

        return response()->json(['message' => 'Thêm bộ môn thành công']);
    }

    public function updateBoMon(Request $request, $id)
    {
        $request->validate([
            'TenBoMon' => 'required|string|max:255',
            'MaKhoa' => 'required|integer|exists:Khoa,MaKhoa',
        ]);

        DB::table('BoMon')
            ->where('MaBoMon', $id)
            ->update([
                'TenBoMon' => $request->TenBoMon,
                'MaKhoa' => $request->MaKhoa,
            ]);

        return response()->json(['message' => 'Cập nhật bộ môn thành công']);
    }

    public function deleteBoMon($id)
    {
        $giangVienCount = DB::table('GiangVien')->where('MaBoMon', $id)->count();

        if ($giangVienCount > 0) {
            return response()->json([
                'error' => 'Không thể xóa vì bộ môn này vẫn còn giảng viên trực thuộc!'
            ], 400);
        }

        DB::table('BoMon')->where('MaBoMon', $id)->delete();

        return response()->json(['message' => 'Xóa bộ môn thành công']);
    }




    // ===================== 🏫 QUẢN LÝ PHÒNG HỌC =====================
    public function getAllPhongHoc()
    {
        return response()->json(PhongHoc::all());
    }

    public function createPhongHoc(Request $request)
    {
        $request->validate([
            'TenPhong' => 'required|unique:PhongHoc',
            'SucChua' => 'required|integer|min:1',
            'LoaiPhong' => 'required|in:LT,TH'
        ]);
        $phong = PhongHoc::create($request->only('TenPhong', 'SucChua', 'LoaiPhong'));
        return response()->json(['message' => 'Thêm Phòng học thành công', 'data' => $phong]);
    }

    public function updatePhongHoc(Request $request, $id)
    {
        $phong = PhongHoc::findOrFail($id);
        $phong->update($request->only('TenPhong', 'SucChua', 'LoaiPhong'));
        return response()->json(['message' => 'Cập nhật Phòng học thành công']);
    }

    public function deletePhongHoc($id)
    {
        // Hủy tham chiếu phòng học ở các lớp
        LopHocPhan::where('MaPhongMacDinh', $id)->update(['MaPhongMacDinh' => null]);
        LichTrinhChiTiet::where('MaPhong', $id)->update(['MaPhong' => null]);
        YeuCauThayDoiLich::where('MaPhongDeNghi', $id)->update(['MaPhongDeNghi' => null]);

        PhongHoc::findOrFail($id)->delete();

        return response()->json(['message' => '✅ Đã xóa Phòng học và làm sạch các tham chiếu.']);
    }


    // ===================== 🧾 LỚP HỌC PHẦN =====================
    public function getAllLHP(Request $request)
    {
        // Tạo query cơ bản
        $query = LopHocPhan::with(['monHoc', 'hocKy', 'phongMacDinh']);

        // Nếu có query param includeGV=true thì thêm thông tin giảng viên
        if ($request->query('includeGV') === 'true') {
            $query->with(['giangViens.nguoiDung']);
        }

        $data = $query->get();

        return response()->json([
            'message' => '📘 Danh sách lớp học phần',
            'data' => $data
        ]);
    }

    public function getAllWithGiangVien()
    {
        $data = LopHocPhan::with([
            'monHoc',
            'hocKy',
            'phongMacDinh',
            'giangViens.nguoiDung',
            'lichTrinhChiTiet'
        ])->get();
        return response()->json([
            'message' => '📘 Danh sách lớp học phần kèm giảng viên',
            'data' => $data
        ]);
    }
    public function createLHP(Request $request)
    {
        $request->validate([
            'MaMonHoc' => 'required|exists:MonHoc,MaMonHoc',
            'MaHK' => 'required|exists:HocKy,MaHK',
            'TenLHP' => 'required|string',
            'MaPhongMacDinh' => 'nullable|exists:PhongHoc,MaPhong',
            'SiSoToiDa' => 'nullable|integer|min:1'
        ]);

        $phong = null;
        $sucChua = null;
        if ($request->MaPhongMacDinh) {
            $phong = PhongHoc::find($request->MaPhongMacDinh);
            $sucChua = $phong ? $phong->SucChua : null;
        }
        $siSoToiDa = $request->SiSoToiDa ?? $sucChua ?? 50;

        $lhp = LopHocPhan::create([
            'TenLHP' => $request->TenLHP,
            'MaMonHoc' => $request->MaMonHoc,
            'MaHK' => $request->MaHK,
            'MaPhongMacDinh' => $request->MaPhongMacDinh,
            'SiSoToiDa' => $siSoToiDa,
        ]);

        return response()->json(['message' => '✅ Tạo lớp học phần thành công', 'data' => $lhp], 201);
    }
    public function deleteLopHocPhan($id)
    {
        $lhp = LopHocPhan::findOrFail($id);

        // Xóa phân công
        PhanCong::where('MaLHP', $id)->delete();

        // Xóa lịch chi tiết
        LichTrinhChiTiet::where('MaLHP', $id)->delete();

        // Xóa đăng ký học phần (nếu có)
        DB::table('DangKyHocPhan')->where('MaLHP', $id)->delete();

        $lhp->delete();

        return response()->json(['message' => '✅ Đã xóa lớp học phần và toàn bộ dữ liệu liên quan.']);
    }
    public function importSinhVien(Request $request, $maLHP)
    {
        $request->validate([
            'file' => 'required|mimes:xlsx,xls'
        ]);

        $rows = Excel::toArray([], $request->file('file'))[0];
        $countCreated = 0;
        $countLinked = 0;

        // Lấy vai trò sinh viên
        $vaiTroSV = VaiTro::where('TenVaiTro', 'SinhVien')->first();

        foreach ($rows as $index => $row) {
            if ($index === 0) continue; // bỏ header

            // Giả sử file Excel có cấu trúc:
            // | MaSV | HoTen | Email | LopHanhChinh | NamNhapHoc |
            [$maSV, $hoTen, $email, $lopHC, $namNhapHoc] = $row;

            if (!$email) continue;

            // 1️⃣ Tạo hoặc lấy tài khoản người dùng
            $user = NguoiDung::firstOrCreate(
                ['Email' => $email],
                [
                    'TenDangNhap' => $maSV ?? explode('@', $email)[0],
                    'HoTen' => $hoTen,
                    'MatKhau' => bcrypt('123456'),
                    'TrangThai' => 1
                ]
            );

            // 2️⃣ Gán vai trò Sinh viên (nếu chưa có)
            if ($vaiTroSV && !NguoiDungVaiTro::where([
                'MaND' => $user->MaND,
                'MaVaiTro' => $vaiTroSV->MaVaiTro
            ])->exists()) {
                NguoiDungVaiTro::create([
                    'MaND' => $user->MaND,
                    'MaVaiTro' => $vaiTroSV->MaVaiTro
                ]);
            }

            // 3️⃣ Tạo hoặc lấy Sinh viên
            $sv = SinhVien::firstOrCreate(
                ['MaND' => $user->MaND],
                [
                    'MaLopHanhChinh' => $lopHC,
                    'NamNhapHoc' => $namNhapHoc
                ]
            );

            // 4️⃣ Ghi vào bảng Đăng ký học phần
            if (!DangKyHocPhan::where(['MaLHP' => $maLHP, 'MaSV' => $sv->MaSV])->exists()) {
                DangKyHocPhan::create([
                    'MaLHP' => $maLHP,
                    'MaSV' => $sv->MaSV
                ]);
                $countLinked++;
            }

            $countCreated++;
        }

        return response()->json([
            'message' => "✅ Import thành công {$countCreated} sinh viên, đã liên kết {$countLinked} sinh viên vào lớp học phần {$maLHP}",
        ]);
    }

    public function getDanhSachSinhVien($maLHP)
    {
        $lopHocPhan = LopHocPhan::with(['sinhViens.nguoiDung'])->find($maLHP);

        if (!$lopHocPhan) {
            return response()->json(['message' => 'Không tìm thấy lớp học phần'], 404);
        }

        $sinhViens = $lopHocPhan->sinhViens->map(function ($sv) {
            return [
                'MaSV' => $sv->MaSV,
                'HoTen' => $sv->nguoiDung?->HoTen ?? '—',
                'Email' => $sv->nguoiDung?->Email ?? '—',
                'TenDangNhap' => $sv->nguoiDung?->TenDangNhap ?? '—',
                'MaLopHanhChinh' => $sv->MaLopHanhChinh ?? '—',
                'NamNhapHoc' => $sv->NamNhapHoc ?? '—',
                'ThoiGian' => $sv->pivot?->ThoiGian ?? null, // ⚙️ dùng đúng tên cột trong DB
            ];
        });

        return response()->json([
            'message' => '📋 Danh sách sinh viên của lớp học phần',
            'MaLHP' => $lopHocPhan->MaLHP,
            'TenLHP' => $lopHocPhan->TenLHP,
            'SoLuong' => $sinhViens->count(),
            'data' => $sinhViens,
        ]);
    }



    // ===================== 👩‍🏫 PHÂN CÔNG =====================
    public function assignGiangVien(Request $request)
    {
        $request->validate([
            'MaLHP' => 'required|exists:LopHocPhan,MaLHP',
            'MaGV' => 'required|exists:GiangVien,MaGV',
        ]);

        // ✅ Cập nhật nếu lớp học phần đã có phân công, ngược lại thì tạo mới
        $pc = PhanCong::updateOrCreate(
            ['MaLHP' => $request->MaLHP], // điều kiện tìm
            [
                'MaGV' => $request->MaGV,
                'NgayPhanCong' => now(),
            ]
        );

        return response()->json([
            'message' => '✅ Phân công giảng viên thành công!',
            'data' => $pc
        ]);
    }

    public function deletePhanCong($id)
    {
        $phanCong = \App\Models\PhanCong::find($id);
        if (!$phanCong) {
            return response()->json(['message' => 'Không tìm thấy phân công'], 404);
        }

        $phanCong->delete();

        return response()->json(['message' => '🗑️ Đã xóa phân công giảng viên thành công!']);
    }


    // ===================== 🗓️ SINH LỊCH GIẢNG DẠY =====================
    // ===================== 🗓️ SINH LỊCH GIẢNG DẠY =====================
    public function sinhLich(Request $request)
    {
        $request->validate([
            'MaLHP' => 'required|exists:LopHocPhan,MaLHP',
            'SoBuoi' => 'required|integer|min:1',
            'NgayBatDau' => 'required|date',
            'CaHoc' => 'required|string',
            'MaPhong' => 'nullable|exists:PhongHoc,MaPhong'
        ]);

        $ngayBatDau = Carbon::parse($request->NgayBatDau);
        $now = Carbon::now();
        $lichs = [];

        for ($i = 0; $i < $request->SoBuoi; $i++) {
            $ngayHoc = $ngayBatDau->copy()->addWeeks($i);

            // ✅ Xác định trạng thái buổi học dựa vào thời gian hiện tại
            $trangThai = $ngayHoc->lt($now)
                ? 'BinhThuong'   // buổi đã qua
                : 'ChuaDienRa';  // buổi chưa diễn ra

            $lichs[] = LichTrinhChiTiet::create([
                'MaLHP' => $request->MaLHP,
                'NgayHoc' => $ngayHoc,
                'CaHoc' => $request->CaHoc,
                'MaPhong' => $request->MaPhong,
                'TrangThaiBuoiHoc' => $trangThai
            ]);
        }

        return response()->json([
            'message' => '✅ Sinh lịch thủ công thành công!',
            'soBuoiSinh' => count($lichs),
            'data' => $lichs
        ], 201);
    }

    public function sinhLichTuDong(Request $request)
    {
        $request->validate([
            'MaLHP' => 'required|exists:LopHocPhan,MaLHP',
            'SoBuoi' => 'required|integer|min:1',
            'NgayBatDau' => 'required|date',
            'CaHoc' => 'required|string|in:Ca1,Ca2,Ca3,Ca4',
            'MaPhong' => 'nullable|exists:PhongHoc,MaPhong'
        ]);

        $lhp = \App\Models\LopHocPhan::with('hocKy')->find($request->MaLHP);
        if (!$lhp || !$lhp->hocKy) {
            return response()->json(['message' => 'Không tìm thấy học kỳ của lớp học phần này.'], 404);
        }

        $ngayBatDau = Carbon::parse($request->NgayBatDau);
        $ngayBDHK = Carbon::parse($lhp->hocKy->NgayBatDau);
        $ngayKTHK = Carbon::parse($lhp->hocKy->NgayKetThuc);
        $now = Carbon::now();

        if ($ngayBatDau->lt($ngayBDHK) || $ngayBatDau->gt($ngayKTHK)) {
            return response()->json([
                'message' => '⛔ Ngày bắt đầu phải nằm trong thời gian học kỳ (' .
                    $ngayBDHK->format('d/m/Y') . ' - ' . $ngayKTHK->format('d/m/Y') . ')'
            ], 400);
        }

        if (LichTrinhChiTiet::where('MaLHP', $request->MaLHP)->exists()) {
            return response()->json([
                'message' => '⚠️ Lớp học phần này đã có lịch. Vui lòng xóa lịch cũ trước khi sinh lại.'
            ], 409);
        }

        $lichs = [];
        $currentDate = $ngayBatDau->copy();

        for ($i = 0; $i < $request->SoBuoi; $i++) {
            if ($currentDate->gt($ngayKTHK)) break;

            // ✅ Tự động xác định trạng thái
            $trangThai = $currentDate->lt($now)
                ? 'BinhThuong'
                : 'ChuaDienRa';

            $lichs[] = LichTrinhChiTiet::create([
                'MaLHP' => $request->MaLHP,
                'NgayHoc' => $currentDate,
                'CaHoc' => $request->CaHoc,
                'MaPhong' => $request->MaPhong ?? $lhp->MaPhongMacDinh,
                'TrangThaiBuoiHoc' => $trangThai
            ]);

            $currentDate->addWeek();
        }

        return response()->json([
            'message' => '✅ Sinh lịch tự động thành công!',
            'lop_hoc_phan' => [
                'MaLHP' => $lhp->MaLHP,
                'TenLHP' => $lhp->TenLHP,
                'HocKy' => $lhp->hocKy->TenHK,
            ],
            'soBuoiSinh' => count($lichs),
            'data' => $lichs
        ]);
    }


    public function getLichTheoLHP($maLHP)
    {
        $lich = \App\Models\LichTrinhChiTiet::with(
            'lopHocPhan.monHoc',
            'lopHocPhan.hocKy',
            'phongHoc'
        )
            ->where('MaLHP', $maLHP)
            ->orderBy('NgayHoc')
            ->get();

        if ($lich->isEmpty()) {
            return response()->json([
                'message' => '⛔ Chưa có lịch học nào cho lớp học phần này.',
                'data' => []
            ]);
        }

        return response()->json([
            'message' => '📅 Danh sách lịch học chi tiết của lớp học phần',
            'count' => $lich->count(),
            'data' => $lich
        ]);
    }
    public function xoaLichTheoLHP($maLHP)
    {
        $count = \App\Models\LichTrinhChiTiet::where('MaLHP', $maLHP)->count();

        if ($count === 0) {
            return response()->json([
                'message' => '⛔ Không tìm thấy lịch để xóa.',
                'deleted' => 0
            ], 404);
        }

        \App\Models\LichTrinhChiTiet::where('MaLHP', $maLHP)->delete();

        return response()->json([
            'message' => "🗑️ Đã xóa toàn bộ {$count} lịch học của lớp học phần {$maLHP}.",
            'deleted' => $count
        ]);
    }

    // ===================== 👨‍🏫 GIẢNG VIÊN =====================
    public function taoGiangVien(Request $request)
    {
        $request->validate([
            'TenDangNhap' => 'required|unique:NguoiDung,TenDangNhap',
            'Email' => 'required|email|unique:NguoiDung,Email',
            'MatKhau' => 'required|min:6',
            'HoTen' => 'required|string|max:100',
            'MaBoMon' => 'required|exists:BoMon,MaBoMon',
        ]);

        $user = NguoiDung::create([
            'TenDangNhap' => $request->TenDangNhap,
            'Email' => $request->Email,
            'MatKhau' => bcrypt($request->MatKhau),
            'HoTen' => $request->HoTen,
        ]);

        $vaiTroGV = VaiTro::where('TenVaiTro', 'GiangVien')->first();
        if ($vaiTroGV) {
            NguoiDungVaiTro::create(['MaND' => $user->MaND, 'MaVaiTro' => $vaiTroGV->MaVaiTro]);
        }

        $gv = GiangVien::create([
            'HoTen' => $request->HoTen,
            'MaND' => $user->MaND,
            'MaBoMon' => $request->MaBoMon,
        ]);

        return response()->json(['message' => 'Tạo giảng viên thành công!', 'NguoiDung' => $user, 'GiangVien' => $gv]);
    }

    public function getAllGiangVien()
    {
        return response()->json(GiangVien::with(['nguoiDung', 'boMon'])->get());
    }

    public function getGiangVienById($id)
    {
        $gv = GiangVien::with(['nguoiDung', 'boMon'])->find($id);
        if (!$gv) return response()->json(['message' => 'Không tìm thấy giảng viên'], 404);
        return response()->json($gv);
    }

    public function updateGiangVien(Request $request, $id)
    {
        $gv = GiangVien::with('nguoiDung')->findOrFail($id);
        $request->validate([
            'HoTen' => 'sometimes|string|max:100',
            'Email' => 'sometimes|email|unique:NguoiDung,Email,' . $gv->nguoiDung->MaND . ',MaND',
            'MaBoMon' => 'sometimes|exists:BoMon,MaBoMon',
        ]);
        if ($request->has('HoTen')) $gv->HoTen = $request->HoTen;
        if ($request->has('MaBoMon')) $gv->MaBoMon = $request->MaBoMon;
        $gv->save();
        if ($request->has('HoTen')) $gv->nguoiDung->HoTen = $request->HoTen;
        if ($request->has('Email')) $gv->nguoiDung->Email = $request->Email;
        $gv->nguoiDung->save();
        return response()->json(['message' => 'Cập nhật giảng viên thành công', 'data' => $gv]);
    }

    public function deleteGiangVien($id)
    {
        $gv = GiangVien::with('nguoiDung')->findOrFail($id);

        // Xóa phân công & yêu cầu thay đổi lịch của giảng viên này
        PhanCong::where('MaGV', $id)->delete();
        YeuCauThayDoiLich::where('MaGV', $id)->delete();

        // Xóa tài khoản người dùng nếu có
        if ($gv->nguoiDung) $gv->nguoiDung->delete();

        $gv->delete();

        return response()->json(['message' => '✅ Đã xóa giảng viên và các phân công, yêu cầu liên quan.']);
    }


    // ===================== 📅 LỊCH GIẢNG DẠY =====================
    public function getLichTrinhTheoHocKy($maHK)
    {
        $lich = LichTrinhChiTiet::with([
            'lopHocPhan.monHoc',
            'lopHocPhan.hocKy',
            'lopHocPhan.giangViens',
            'phongHoc'
        ])->whereHas('lopHocPhan', fn($q) => $q->where('MaHK', $maHK))
            ->orderBy('NgayHoc')->get();

        return response()->json(['message' => '📅 Lịch chi tiết của học kỳ', 'data' => $lich]);
    }

    public function getLichTheoGiangVien($maGV)
    {
        $lich = LichTrinhChiTiet::with([
            'lopHocPhan.monHoc',
            'lopHocPhan.hocKy',
            'phongHoc'
        ])->whereHas('lopHocPhan.phanCongs', fn($q) => $q->where('MaGV', $maGV))
            ->orderBy('NgayHoc')->get();

        return response()->json(['message' => '🧑‍🏫 Lịch giảng dạy của giảng viên', 'data' => $lich]);
    }

    public function timKiemLich(Request $request)
    {
        $query = LichTrinhChiTiet::with([
            'lopHocPhan.monHoc.nganh.khoa',
            'lopHocPhan.hocKy',
            'lopHocPhan.giangViens',
            'phongHoc'
        ]);

        if ($request->filled('MaKhoa'))
            $query->whereHas('lopHocPhan.monHoc.nganh.khoa', fn($q) => $q->where('MaKhoa', $request->MaKhoa));

        if ($request->filled('MaNganh'))
            $query->whereHas('lopHocPhan.monHoc', fn($q) => $q->where('MaNganh', $request->MaNganh));

        if ($request->filled('MaBoMon'))
            $query->whereHas('lopHocPhan.giangViens.boMon', fn($q) => $q->where('MaBoMon', $request->MaBoMon));

        if ($request->filled('MaHK'))
            $query->whereHas('lopHocPhan', fn($q) => $q->where('MaHK', $request->MaHK));

        $result = $query->orderBy('NgayHoc')->get();

        return response()->json(['message' => '🔍 Kết quả lọc lịch chi tiết', 'count' => $result->count(), 'data' => $result]);
    }

    public function capNhatLich(Request $request)
    {
        $request->validate([
            'MaBuoiHoc' => 'required|exists:LichTrinhChiTiet,MaBuoiHoc',
            'LoaiYeuCau' => 'required|in:NghiDay,DayBu',
            'NgayMoi' => 'nullable|date',
            'LyDo' => 'nullable|string'
        ]);

        $lich = LichTrinhChiTiet::find($request->MaBuoiHoc);

        if ($request->LoaiYeuCau === 'NghiDay') {
            $lich->TrangThai = 'Nghi';
        } elseif ($request->LoaiYeuCau === 'DayBu' && $request->NgayMoi) {
            LichTrinhChiTiet::create([
                'MaLHP' => $lich->MaLHP,
                'NgayHoc' => $request->NgayMoi,
                'CaHoc' => 'CaHoc',
                'MaPhong' => $lich->MaPhong
            ]);
            $lich->TrangThai = 'ChuyenDayBu';
        }
        $lich->save();

        YeuCauThayDoiLich::create([
            'MaGV' => $request->MaGV ?? null,
            'MaBuoiHoc' => $lich->MaBuoiHoc,
            'LoaiYeuCau' => $request->LoaiYeuCau,
            'NgayMoi' => $request->NgayMoi,
            'LyDo' => $request->LyDo,
            'NgayTao' => now(),
            'TrangThai' => 'DaDuyet'
        ]);

        return response()->json(['message' => '📝 Cập nhật lịch thành công!', 'data' => $lich]);
    }
    // tien do
    // 🧾 Lấy tiến độ giảng dạy của tất cả lớp học phần trong học kỳ
    public function getTienDoGiangDay($maHK)
    {
        $data = DB::table('vThongKeTienDoLHP')
            ->join('GiangVien', 'vThongKeTienDoLHP.MaGV', '=', 'GiangVien.MaGV')
            ->join('NguoiDung', 'GiangVien.MaND', '=', 'NguoiDung.MaND') // 🔹 Lấy họ tên
            ->join('LopHocPhan', 'vThongKeTienDoLHP.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->join('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->select(
                'vThongKeTienDoLHP.MaGV',
                'NguoiDung.HoTen as TenGiangVien',
                'MonHoc.TenMonHoc',
                'LopHocPhan.TenLHP',
                'vThongKeTienDoLHP.SoBuoiDaDay',
                'vThongKeTienDoLHP.SoBuoiDayBu',
                'vThongKeTienDoLHP.SoBuoiNghi',
                'vThongKeTienDoLHP.TongSoBuoi',
                'vThongKeTienDoLHP.TienDoPhanTram',
            )
            ->where('vThongKeTienDoLHP.TenHK', '=', function ($q) use ($maHK) {
                $q->select('TenHK')->from('HocKy')->where('MaHK', $maHK)->limit(1);
            })
            ->get();

        return response()->json([
            'message' => '📊 Tiến độ giảng dạy học kỳ ' . $maHK,
            'count' => $data->count(),
            'data' => $data
        ]);
    }
    public function thongKeTienDoHocPhan(Request $request)
    {
        $query = DB::table('LopHocPhan as lhp')
            ->join('MonHoc as mh', 'lhp.MaMonHoc', '=', 'mh.MaMonHoc')
            ->join('Nganh as n', 'mh.MaNganh', '=', 'n.MaNganh')
            ->join('Khoa as k', 'n.MaKhoa', '=', 'k.MaKhoa')
            ->join('HocKy as hk', 'lhp.MaHK', '=', 'hk.MaHK')
            ->join('PhanCong as pc', 'pc.MaLHP', '=', 'lhp.MaLHP')
            ->join('GiangVien as gv', 'pc.MaGV', '=', 'gv.MaGV')
            ->join('NguoiDung as nd', 'gv.MaND', '=', 'nd.MaND') // ✅ để lấy tên giảng viên
            ->leftJoin('LichTrinhChiTiet as ltc', 'ltc.MaLHP', '=', 'lhp.MaLHP')
            ->select(
                'lhp.MaLHP',
                'lhp.TenLHP',
                'mh.TenMonHoc as TenMH',
                'hk.TenHK',
                'nd.HoTen as GiangVien', // ✅ tên giảng viên thực tế
                'k.TenKhoa',
                'n.TenNganh',
                DB::raw('COUNT(DISTINCT ltc.MaBuoiHoc) as TongBuoi'),
                DB::raw('SUM(CASE WHEN ltc.TrangThaiBuoiHoc IN ("BinhThuong", "DayBu") THEN 1 ELSE 0 END) as DaDay')
            )
            ->groupBy(
                'lhp.MaLHP',
                'lhp.TenLHP',
                'mh.TenMonHoc',
                'hk.TenHK',
                'nd.HoTen',
                'k.TenKhoa',
                'n.TenNganh'
            );

        // 🎯 Bộ lọc
        $query
            ->when($request->filled('hocKy') && (int)$request->hocKy > 0, fn($q) =>
            $q->where('lhp.MaHK', (int)$request->hocKy))
            ->when($request->filled('khoa') && (int)$request->khoa > 0, fn($q) =>
            $q->where('k.MaKhoa', (int)$request->khoa))
            ->when($request->filled('nganh') && (int)$request->nganh > 0, fn($q) =>
            $q->where('n.MaNganh', (int)$request->nganh))
            ->when($request->filled('giangVien') && trim($request->giangVien) !== '', fn($q) =>
            $q->where('nd.HoTen', 'like', '%' . trim($request->giangVien) . '%'))
            ->when($request->filled('tenMH') && trim($request->tenMH) !== '', fn($q) =>
            $q->where('mh.TenMonHoc', 'like', '%' . trim($request->tenMH) . '%'));

        $data = $query->get()->map(function ($item) {
            $item->TongBuoi = (int) $item->TongBuoi;
            $item->DaDay = (int) $item->DaDay;
            $item->TiLeHoanThanh = $item->TongBuoi > 0
                ? round(($item->DaDay / $item->TongBuoi) * 100, 1)
                : 0;
            $item->TrangThai = $item->TiLeHoanThanh >= 100
                ? 'Hoàn thành'
                : ($item->DaDay > 0 ? 'Đang dạy' : 'Chưa bắt đầu');
            return $item;
        });

        return response()->json(['data' => $data]);
    }
    public function chiTietTienDoHocPhan($maLHP)
    {
        $lopHocPhan = LopHocPhan::with([
            'monHoc',
            'hocKy',
            'phanCongs.giangVien',
            'lichTrinhChiTiet.phongHoc'
        ])->find($maLHP);

        if (!$lopHocPhan) {
            return response()->json(['message' => 'Không tìm thấy lớp học phần'], 404);
        }

        $lich = $lopHocPhan->lichTrinhChiTiet->map(function ($item) {
            $trangThai = match ($item->TrangThaiBuoiHoc) {
                'Nghi' => 'Nghỉ',
                'DayBu' => 'Dạy bù',
                'BinhThuong' => 'Bình thường',
                'HoanThanh' => 'Hoàn thành',
                default => 'Chưa diễn ra'
            };

            return [
                'MaBuoiHoc' => $item->MaBuoiHoc,
                'NgayHoc' => $item->NgayHoc,
                'CaHoc' => $item->CaHoc,
                'Phong' => $item->phongHoc?->TenPhong,
                'TrangThaiHienThi' => $trangThai,
                'NoiDungGiangDay' => $item->NoiDungGiangDay,
            ];
        });

        $tongBuoi = $lich->count();
        $daDay = $lich->whereIn('TrangThaiHienThi', ['Bình thường', 'Dạy bù'])->count();

        $tiLeHoanThanh = $tongBuoi > 0
            ? round(($daDay / $tongBuoi) * 100, 1)
            : 0;

        return response()->json([
            'ThongTin' => [
                'MaLHP' => $lopHocPhan->MaLHP,
                'TenLHP' => $lopHocPhan->TenLHP,
                'TenMonHoc' => $lopHocPhan->monHoc->TenMonHoc,
                'HocKy' => $lopHocPhan->hocKy->TenHK,
                'GiangVien' => $lopHocPhan->phanCongs->first()?->giangVien?->HoTen ?? 'Chưa phân công',
                'TongBuoi' => $tongBuoi,
                'DaDay' => $daDay,
                'TiLeHoanThanh' => $tiLeHoanThanh,
            ],
            'BuoiHoc' => $lich
        ]);
    }





    // ===================== 📋 XEM DANH SÁCH YÊU CẦU THAY ĐỔI LỊCH =====================
    public function getAllYeuCau()
    {
        $yeuCau = DB::table('YeuCauThayDoiLich')
            ->join('GiangVien', 'YeuCauThayDoiLich.MaGV', '=', 'GiangVien.MaGV')
            ->join('NguoiDung', 'GiangVien.MaND', '=', 'NguoiDung.MaND')
            ->leftJoin('PhongHoc', 'YeuCauThayDoiLich.MaPhongDeNghi', '=', 'PhongHoc.MaPhong')
            ->leftJoin('LichTrinhChiTiet', 'YeuCauThayDoiLich.MaBuoiHocNguon', '=', 'LichTrinhChiTiet.MaBuoiHoc')
            ->leftJoin('LopHocPhan', 'LichTrinhChiTiet.MaLHP', '=', 'LopHocPhan.MaLHP')
            ->leftJoin('MonHoc', 'LopHocPhan.MaMonHoc', '=', 'MonHoc.MaMonHoc')
            ->select(
                'YeuCauThayDoiLich.MaYeuCau',
                'NguoiDung.HoTen as TenGiangVien',
                'LopHocPhan.TenLHP',
                'MonHoc.TenMonHoc',
                'YeuCauThayDoiLich.LoaiYeuCau',
                'YeuCauThayDoiLich.NgayDeXuat',
                'YeuCauThayDoiLich.NgayDeNghiBu',
                'YeuCauThayDoiLich.CaDeNghiBu',
                'PhongHoc.TenPhong as PhongDeNghi',
                'YeuCauThayDoiLich.LyDo',
                'YeuCauThayDoiLich.TrangThai',

                // 🧩 Thông tin buổi học gốc
                'LichTrinhChiTiet.NgayHoc as NgayHocGoc',
                'LichTrinhChiTiet.CaHoc as CaHocGoc',
                'LichTrinhChiTiet.TrangThaiBuoiHoc',
                'LichTrinhChiTiet.MaBuoiHoc as MaBuoiHocNguon',
                DB::raw('COALESCE(LichTrinhChiTiet.NoiDungGiangDay, "Chưa có nội dung") as NoiDungGiangDay')
            )
            ->orderBy('YeuCauThayDoiLich.NgayDeXuat', 'desc')
            ->get();

        return response()->json([
            'message' => '📋 Danh sách yêu cầu thay đổi lịch',
            'count' => $yeuCau->count(),
            'data' => $yeuCau
        ]);
    }

    // ===================== ✅ DUYỆT / TỪ CHỐI YÊU CẦU =====================
    public function duyetYeuCau(Request $request, $maYeuCau)
    {
        try {
            // 🧾 Kiểm tra dữ liệu đầu vào
            $request->validate([
                'TrangThai' => 'required|in:Duyet,TuChoi'
            ]);

            // 🔍 Tìm yêu cầu
            $yc = DB::table('YeuCauThayDoiLich')->where('MaYeuCau', $maYeuCau)->first();
            if (!$yc) {
                return response()->json(['message' => '⛔ Không tìm thấy yêu cầu.'], 404);
            }

            // ✅ Cập nhật trạng thái yêu cầu
            DB::table('YeuCauThayDoiLich')
                ->where('MaYeuCau', $maYeuCau)
                ->update(['TrangThai' => $request->TrangThai]);

            // ❌ Nếu từ chối thì dừng tại đây
            if ($request->TrangThai === 'TuChoi') {
                return response()->json([
                    'message' => '🚫 Đã từ chối yêu cầu thay đổi lịch.',
                    'MaYeuCau' => $maYeuCau,
                    'LoaiYeuCau' => $yc->LoaiYeuCau
                ]);
            }

            // ✅ Nếu được duyệt
            if ($yc->LoaiYeuCau === 'Nghi') {
                // 🔹 Cập nhật trạng thái buổi học thành "Nghi"
                $affected = DB::table('LichTrinhChiTiet')
                    ->where('MaBuoiHoc', $yc->MaBuoiHocNguon)
                    ->update(['TrangThaiBuoiHoc' => 'Nghi']);

                if ($affected === 0) {
                    return response()->json([
                        'message' => '⚠️ Không tìm thấy buổi học gốc để cập nhật trạng thái nghỉ.',
                    ], 404);
                }

                return response()->json([
                    'message' => '✅ Đã duyệt yêu cầu nghỉ và cập nhật trạng thái buổi học.',
                    'MaYeuCau' => $maYeuCau
                ]);
            }

            if ($yc->LoaiYeuCau === 'DayBu') {
                // 🔹 Lấy thông tin buổi học gốc
                $buoiGoc = DB::table('LichTrinhChiTiet')
                    ->where('MaBuoiHoc', $yc->MaBuoiHocNguon)
                    ->first();

                if (!$buoiGoc) {
                    return response()->json([
                        'message' => '⚠️ Không tìm thấy buổi học gốc để tạo buổi dạy bù.',
                    ], 404);
                }

                // 🔎 Kiểm tra trùng lịch dạy bù
                $exists = DB::table('LichTrinhChiTiet')
                    ->where('MaLHP', $buoiGoc->MaLHP)
                    ->whereDate('NgayHoc', $yc->NgayDeNghiBu ?? $buoiGoc->NgayHoc)
                    ->where('CaHoc', $yc->CaDeNghiBu ?? $buoiGoc->CaHoc)
                    ->exists();

                if ($exists) {
                    return response()->json([
                        'message' => '⚠️ Buổi học dạy bù này đã tồn tại trong lịch, không thể tạo trùng.',
                    ], 409);
                }

                // ✅ Thêm buổi học mới (dạy bù)
                DB::table('LichTrinhChiTiet')->insert([
                    'MaLHP' => $buoiGoc->MaLHP,
                    'NgayHoc' => $yc->NgayDeNghiBu ?? $buoiGoc->NgayHoc,
                    'CaHoc' => $yc->CaDeNghiBu ?? $buoiGoc->CaHoc,
                    'MaPhong' => $yc->MaPhongDeNghi ?? $buoiGoc->MaPhong,
                    'TrangThaiBuoiHoc' => 'DayBu',
                    'NoiDungGiangDay' => $buoiGoc->NoiDungGiangDay,
                    'ThoiGianMoDD' => null,
                    'ThoiGianDongDD' => null
                ]);

                return response()->json([
                    'message' => '✅ Đã duyệt yêu cầu dạy bù và thêm lịch học mới.',
                    'MaYeuCau' => $maYeuCau
                ]);
            }

            return response()->json([
                'message' => '⚠️ Loại yêu cầu không hợp lệ hoặc chưa xử lý.',
                'MaYeuCau' => $maYeuCau
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'message' => '❌ Lỗi hệ thống: ' . $e->getMessage(),
                'line' => $e->getLine()
            ], 500);
        }
    }
    // thông báo
    public function guiThongBao(Request $request)
    {
        $user = Auth::user();

        $request->validate([
            'TieuDe'   => 'required|string|max:255',
            'NoiDung'  => 'required|string',
            'DoiTuong' => 'required|in:TatCa,GiangVien,SinhVien,BoMon',
            'MaBoMon'  => 'nullable|integer'
        ]);

        // 1️⃣ Tạo thông báo
        $thongBao = ThongBao::create([
            'TieuDe'      => $request->TieuDe,
            'NoiDung'     => $request->NoiDung,
            'NguoiGui'    => $user->MaND,
            'ThoiGianGui' => now(),
        ]);

        // 2️⃣ Tìm danh sách người nhận theo vai trò
        $nguoiNhans = NguoiDung::query()
            ->when($request->DoiTuong === 'GiangVien', function ($q) {
                $q->whereHas('vaiTros', fn($v) => $v->where('TenVaiTro', 'GiangVien'));
            })
            ->when($request->DoiTuong === 'SinhVien', function ($q) {
                $q->whereHas('vaiTros', fn($v) => $v->where('TenVaiTro', 'SinhVien'));
            })
            ->when($request->DoiTuong === 'BoMon' && $request->MaBoMon, function ($q) use ($request) {
                $q->whereHas('giangVien', fn($gv) => $gv->where('MaBoMon', $request->MaBoMon));
            })
            ->pluck('MaND');

        // 3️⃣ Ghi danh sách người nhận
        foreach ($nguoiNhans as $id) {
            DB::table('ThongBao_NguoiNhan')->insert([
                'MaThongBao' => $thongBao->MaThongBao,
                'MaNguoiNhan' => $id,
                'TrangThaiDoc' => 0,
            ]);
        }

        return response()->json([
            'message' => '📢 Gửi thông báo thành công!',
            'thong_bao' => $thongBao,
            'so_nguoi_nhan' => count($nguoiNhans),
            'doi_tuong' => $request->DoiTuong
        ], 201);
    }
    public function getThongBaoDaGui()
    {
        $user = Auth::user();

        $thongBaos = ThongBao::with([
            'nguoiNhans.vaiTros' => fn($q) => $q->select('TenVaiTro')
        ])
            ->where('NguoiGui', $user->MaND)
            ->orderByDesc('ThoiGianGui')
            ->get();

        // Xác định nhóm đối tượng nhận
        $thongBaos->map(function ($tb) {
            $roles = $tb->nguoiNhans
                ->flatMap(fn($u) => $u->vaiTros->pluck('TenVaiTro'))
                ->unique()
                ->values();

            if ($roles->isEmpty()) $tb->DoiTuong = 'Không rõ';
            elseif ($roles->count() === 1) $tb->DoiTuong = $roles->first();
            else $tb->DoiTuong = 'Tất cả';

            $tb->SoNguoiNhan = $tb->nguoiNhans->count();

            // Ẩn danh sách chi tiết người nhận để trả JSON gọn
            unset($tb->nguoiNhans);
            return $tb;
        });

        return response()->json([
            'message' => '📋 Danh sách thông báo đã gửi',
            'count'   => $thongBaos->count(),
            'data'    => $thongBaos
        ]);
    }
    public function updateThongBao(Request $request, $id)
    {
        $request->validate([
            'TieuDe'  => 'required|string|max:255',
            'NoiDung' => 'required|string'
        ]);

        $tb = ThongBao::find($id);
        if (!$tb) {
            return response()->json(['message' => 'Không tìm thấy thông báo'], 404);
        }

        $tb->update([
            'TieuDe'  => $request->TieuDe,
            'NoiDung' => $request->NoiDung
        ]);

        return response()->json([
            'message' => '✏️ Cập nhật thông báo thành công!',
            'data' => $tb
        ]);
    }
    public function deleteThongBao($id)
    {
        $tb = ThongBao::find($id);
        if (!$tb) {
            return response()->json(['message' => 'Không tìm thấy thông báo'], 404);
        }

        DB::table('ThongBao_NguoiNhan')->where('MaThongBao', $id)->delete();
        $tb->delete();

        return response()->json(['message' => '🗑️ Đã xóa thông báo thành công!']);
    }
    public function chiTietThongBao($id)
    {
        $thongBao = ThongBao::with(['nguoiGui', 'nguoiNhans.vaiTros'])
            ->find($id);

        if (!$thongBao) {
            return response()->json(['message' => 'Không tìm thấy thông báo'], 404);
        }

        // Danh sách người nhận chi tiết
        $nguoiNhans = $thongBao->nguoiNhans->map(function ($nd) {
            $isRead = (int) $nd->pivot->TrangThaiDoc;

            return [
                'MaND' => $nd->MaND,
                'HoTen' => $nd->HoTen,
                'Email' => $nd->Email,
                'VaiTros' => $nd->vaiTros->pluck('TenVaiTro')->implode(', '),
                'TrangThaiDoc' => $isRead, // ✅ số 0 hoặc 1
                'TrangThaiDocLabel' => $isRead ? '✅ Đã đọc' : '📩 Chưa đọc', // ✅ để hiển thị
            ];
        });


        // Đếm tổng số đã đọc / chưa đọc
        $tong = $nguoiNhans->count();
        $daDoc = $nguoiNhans->where('TrangThaiDoc', 1)->count();

        $chuaDoc = $tong - $daDoc;

        return response()->json([
            'ThongBao' => [
                'MaThongBao' => $thongBao->MaThongBao,
                'TieuDe' => $thongBao->TieuDe,
                'NoiDung' => $thongBao->NoiDung,
                'ThoiGianGui' => $thongBao->ThoiGianGui,
                'NguoiGui' => $thongBao->nguoiGui?->HoTen,
                'DoiTuong' => $thongBao->DoiTuong,
            ],
            'ThongKe' => [
                'Tong' => $tong,
                'DaDoc' => $daDoc,
                'ChuaDoc' => $chuaDoc
            ],
            'NguoiNhans' => $nguoiNhans
        ]);
    }
}
