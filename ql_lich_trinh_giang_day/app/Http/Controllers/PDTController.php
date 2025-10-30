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
use Carbon\Carbon;

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
        Khoa::findOrFail($id)->delete();
        return response()->json(['message' => 'Xóa Khoa thành công']);
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
        Nganh::findOrFail($id)->delete();
        return response()->json(['message' => 'Xóa Ngành thành công']);
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
        MonHoc::findOrFail($id)->delete();
        return response()->json(['message' => 'Xóa Môn học thành công']);
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
        PhongHoc::findOrFail($id)->delete();
        return response()->json(['message' => 'Xóa Phòng học thành công']);
    }

    // ===================== 🧾 LỚP HỌC PHẦN =====================
    public function getAllLHP()
    {
        return response()->json(LopHocPhan::with(['monHoc', 'hocKy', 'phongMacDinh'])->get());
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

    // ===================== 👩‍🏫 PHÂN CÔNG =====================
    public function assignGiangVien(Request $request)
    {
        $request->validate([
            'MaLHP' => 'required|exists:LopHocPhan,MaLHP',
            'MaGV' => 'required|exists:GiangVien,MaGV',
        ]);

        $pc = PhanCong::create([
            'MaLHP' => $request->MaLHP,
            'MaGV' => $request->MaGV,
            'NgayPhanCong' => now(),
        ]);

        return response()->json(['message' => '✅ Phân công giảng viên thành công!', 'data' => $pc]);
    }

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

        $lichs = [];
        $ngayBatDau = Carbon::parse($request->NgayBatDau);
        for ($i = 0; $i < $request->SoBuoi; $i++) {
            $ngayHoc = $ngayBatDau->copy()->addWeeks($i);
            $lichs[] = LichTrinhChiTiet::create([
                'MaLHP' => $request->MaLHP,
                'NgayHoc' => $ngayHoc,
                'CaHoc' => $request->CaHoc,
                'MaPhong' => $request->MaPhong
            ]);
        }

        return response()->json(['message' => '✅ Sinh lịch tự động thành công!', 'data' => $lichs], 201);
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
        $gv = GiangVien::with('nguoiDung')->find($id);
        if (!$gv) return response()->json(['message' => 'Không tìm thấy giảng viên'], 404);
        if ($gv->nguoiDung) $gv->nguoiDung->delete();
        $gv->delete();
        return response()->json(['message' => 'Xóa giảng viên thành công']);
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
}
