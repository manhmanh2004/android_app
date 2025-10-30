<?php

use Illuminate\Support\Facades\Route;
use App\Models\LopHocPhan;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\PDTController;
use App\Http\Controllers\BoMonController;
use App\Http\Controllers\GiangVienController;
use App\Http\Controllers\SinhVienController;

Route::get('/test', function () {
    return LopHocPhan::with([
        'monHoc',
        'hocKy',
        'phongMacDinh',
        'giangViens.nguoiDung',
        'sinhViens.nguoiDung',
        'lichTrinhChiTiet.diemDanhs.sinhVien.nguoiDung'
    ])->limit(5)->get();
});

// ================= AUTH =================
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
});

// ================= ADMIN =================
Route::middleware(['auth:sanctum', 'role:Admin'])->group(function () {
    Route::get('/admin/dashboard', fn() => response()->json(['message' => 'Chào mừng Admin']));
});
Route::middleware(['auth:sanctum', 'role:Admin'])->prefix('admin')->group(function () {
    Route::get('/users', [AdminController::class, 'index']);
    Route::post('/users', [AdminController::class, 'store']);
    Route::post('/users/{id}/assign-role', [AdminController::class, 'assignRole']);
    Route::delete('/users/{id}', [AdminController::class, 'destroy']);
});

// ================= PHÒNG ĐÀO TẠO =================
Route::middleware(['auth:sanctum', 'role:PhongDaoTao'])->prefix('pdt')->group(function () {
    Route::get('/khoa', [PDTController::class, 'getAllKhoa']);
    Route::post('/khoa', [PDTController::class, 'createKhoa']);
    Route::put('/khoa/{id}', [PDTController::class, 'updateKhoa']);
    Route::delete('/khoa/{id}', [PDTController::class, 'deleteKhoa']);

    Route::get('/nganh', [PDTController::class, 'getAllNganh']);
    Route::post('/nganh', [PDTController::class, 'createNganh']);
    Route::put('/nganh/{id}', [PDTController::class, 'updateNganh']);
    Route::delete('/nganh/{id}', [PDTController::class, 'deleteNganh']);

    // ----- Môn học -----
    Route::get('/mon-hoc', [PDTController::class, 'getAllMonHoc']);
    Route::post('/mon-hoc', [PDTController::class, 'createMonHoc']);
    Route::put('/mon-hoc/{id}', [PDTController::class, 'updateMonHoc']);
    Route::delete('/mon-hoc/{id}', [PDTController::class, 'deleteMonHoc']);

    // ----- Học kỳ -----
    Route::get('/hoc-ky', [PDTController::class, 'getAllHocKy']);
    Route::post('/hoc-ky', [PDTController::class, 'createHocKy']);
    Route::put('/hoc-ky/{id}', [PDTController::class, 'updateHocKy']);
    Route::delete('/hoc-ky/{id}', [PDTController::class, 'deleteHocKy']);

    // ----- Phòng học -----
    Route::get('/phong-hoc', [PDTController::class, 'getAllPhongHoc']);
    Route::post('/phong-hoc', [PDTController::class, 'createPhongHoc']);
    Route::put('/phong-hoc/{id}', [PDTController::class, 'updatePhongHoc']);
    Route::delete('/phong-hoc/{id}', [PDTController::class, 'deletePhongHoc']);

    Route::get('/lop-hoc-phan', [PDTController::class, 'getAllLHP']);
    Route::post('/lop-hoc-phan', [PDTController::class, 'createLHP']);

    Route::post('/phan-cong', [PDTController::class, 'assignGiangVien']);
    Route::post('/sinh-lich', [PDTController::class, 'sinhLich']);
    Route::get('/lich-hoc-ky/{maHK}', [PDTController::class, 'getLichTrinhTheoHocKy']);
    Route::get('/lich-giang-vien/{maGV}', [PDTController::class, 'getLichTheoGiangVien']);
    Route::get('/tim-lich', [PDTController::class, 'timKiemLich']);
    Route::post('/cap-nhat-lich', [PDTController::class, 'capNhatLich']);

    Route::post('/tao-giang-vien', [PDTController::class, 'taoGiangVien']);
    Route::get('/giang-vien', [PDTController::class, 'getAllGiangVien']);
    Route::get('/giang-vien/{id}', [PDTController::class, 'getGiangVienById']);
    Route::put('/giang-vien/{id}', [PDTController::class, 'updateGiangVien']);
    Route::delete('/giang-vien/{id}', [PDTController::class, 'deleteGiangVien']);
});

// ================= BỘ MÔN =================
Route::middleware(['auth:sanctum', 'role:BoMon'])->prefix('bo-mon')->group(function () {
    Route::get('/dashboard', fn() => response()->json(['message' => 'Chào mừng Bộ môn!']));
    Route::get('/giang-vien', [BoMonController::class, 'listGiangVien']);
    Route::get('/giang-vien/{maGV}/tien-trinh', [BoMonController::class, 'tienTrinhGiangVien']);
    Route::get('/bao-cao', [BoMonController::class, 'baoCaoBoMon']);
});
// --------------giảng viên
Route::middleware(['auth:sanctum', 'role:GiangVien'])->prefix('giang-vien')->group(function () {
    Route::get('/thong-tin', [GiangVienController::class, 'thongTin']);
    Route::get('/lich-day', [GiangVienController::class, 'lichDay']);
    Route::get('/lich-day/{ngay}', [GiangVienController::class, 'lichDayTheoNgay']);
    Route::post('/diem-danh/mo', [GiangVienController::class, 'moDiemDanh']);
    Route::post('/diem-danh/ghi', [GiangVienController::class, 'ghiDiemDanh']);
    Route::post('/diem-danh/dong', [GiangVienController::class, 'dongDiemDanh']);
    Route::post('/bao-cao', [GiangVienController::class, 'baoCaoBuoiHoc']);
    Route::post('/yeu-cau', [GiangVienController::class, 'taoYeuCau']);
    Route::get('/yeu-cau', [GiangVienController::class, 'danhSachYeuCau']);
    Route::get('/tien-do', [GiangVienController::class, 'tienDo']);
    Route::get('/thong-bao', [GiangVienController::class, 'danhSachThongBao']);
    Route::get('/thong-bao/{id}', [GiangVienController::class, 'chiTietThongBao']);
});
// ================= SINH VIÊN =================
Route::middleware(['auth:sanctum', 'role:SinhVien'])->prefix('sinh-vien')->group(function () {
    Route::get('/thong-tin', [SinhVienController::class, 'thongTin']);
    Route::get('/lich-hoc/hom-nay', [SinhVienController::class, 'lichHocHomNay']);
    Route::get('/lich-hoc', [SinhVienController::class, 'lichHocHocKy']);
    Route::get('/lop-hoc-phan', [SinhVienController::class, 'lopHocPhanDaDangKy']); // ✅ thêm dòng này
    Route::post('/diem-danh', [SinhVienController::class, 'diemDanh']);
    Route::get('/lich-su-diem-danh', [SinhVienController::class, 'lichSuDiemDanh']);
    Route::get('/thong-ke-chuyen-can', [SinhVienController::class, 'thongKeChuyenCan']);
    Route::get('/thong-bao', [SinhVienController::class, 'thongBao']);
    Route::post('/dang-ky', [SinhVienController::class, 'dangKyHocPhan']);
});
