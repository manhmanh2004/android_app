<?php

namespace App\Http\Controllers;

use App\Models\NguoiDung;
use App\Models\VaiTro;
use App\Models\GiangVien;
use App\Models\NguoiDungVaiTro;
use App\Models\SinhVien;
use App\Models\BoMon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    // ==================== QUẢN LÝ NGƯỜI DÙNG ====================
    public function index()
    {
        $users = NguoiDung::select('MaND', 'HoTen', 'Email', 'TenDangNhap', 'TrangThai')
            ->with('vaiTros:VaiTro.MaVaiTro,TenVaiTro')
            ->get();

        return response()->json($users);
    }
    public function getAllTaiKhoan()
    {
        $nguoiDungs = \App\Models\NguoiDung::with('vaiTros')->get();

        return response()->json([
            'message' => '📋 Danh sách tài khoản',
            'data' => $nguoiDungs
        ]);
    }
    public function getAllVaiTro()
    {
        $roles = VaiTro::all();
        return response()->json([
            'message' => 'Danh sách vai trò',
            'data' => $roles
        ]);
    }
    public function store(Request $request)
    {
        $request->validate([
            'HoTen' => 'required|string|max:100',
            'Email' => 'required|email|unique:NguoiDung,Email',
            'TenDangNhap' => 'required|string|unique:NguoiDung,TenDangNhap',
            'MatKhau' => 'required|string|min:6',
            'VaiTro' => 'required|exists:VaiTro,TenVaiTro', // 🔹 Vai trò: Admin, GiangVien, SinhVien, PhongDaoTao, BoMon
            'MaBoMon' => 'nullable|exists:BoMon,MaBoMon', // 🔹 dùng khi tạo giảng viên
            'NamNhapHoc' => 'nullable|integer',            // 🔹 dùng khi tạo sinh viên
            'MaLopHanhChinh' => 'nullable|string|max:50'   // 🔹 dùng khi tạo sinh viên
        ]);

        DB::beginTransaction();
        try {
            // 1️⃣ Tạo người dùng
            $user = NguoiDung::create([
                'HoTen' => $request->HoTen,
                'Email' => $request->Email,
                'TenDangNhap' => $request->TenDangNhap,
                'MatKhau' => Hash::make($request->MatKhau),
                'TrangThai' => 1,
            ]);

            // 2️⃣ Gán vai trò cho người dùng
            $vaiTro = VaiTro::where('TenVaiTro', $request->VaiTro)->first();
            if ($vaiTro) {
                NguoiDungVaiTro::create([
                    'MaND' => $user->MaND,
                    'MaVaiTro' => $vaiTro->MaVaiTro,
                ]);
            }

            // 3️⃣ Nếu là giảng viên → tạo bản ghi GiangVien
            if ($request->VaiTro === 'GiangVien') {
                $request->validate([
                    'MaBoMon' => 'required|exists:BoMon,MaBoMon',
                ]);

                GiangVien::create([
                    'HoTen' => $user->HoTen,
                    'MaND' => $user->MaND,
                    'MaBoMon' => $request->MaBoMon,
                ]);
            }

            // 4️⃣ Nếu là sinh viên → tạo bản ghi SinhVien
            if ($request->VaiTro === 'SinhVien') {
                SinhVien::create([
                    'MaND' => $user->MaND,
                    'MaLopHanhChinh' => $request->MaLopHanhChinh ?? null,
                    'NamNhapHoc' => $request->NamNhapHoc ?? now()->year,
                ]);
            }

            DB::commit();
            return response()->json([
                'message' => '✅ Tạo tài khoản thành công',
                'user' => $user,
                'vai_tro' => $vaiTro->TenVaiTro,
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => '❌ Lỗi khi tạo tài khoản: ' . $e->getMessage(),
            ], 500);
        }
    }
    public function update(Request $request, $id)
    {
        $user = NguoiDung::findOrFail($id);

        $request->validate([
            'HoTen' => 'sometimes|string|max:100',
            'Email' => 'sometimes|email|unique:NguoiDung,Email,' . $user->MaND . ',MaND',
            'TenDangNhap' => 'sometimes|string|unique:NguoiDung,TenDangNhap,' . $user->MaND . ',MaND',
            'MatKhau' => 'nullable|string|min:6',
            'VaiTro' => 'sometimes|exists:VaiTro,TenVaiTro',
            'MaBoMon' => 'nullable|exists:BoMon,MaBoMon',
            'NamNhapHoc' => 'nullable|integer',
            'MaLopHanhChinh' => 'nullable|string|max:50'
        ]);

        DB::beginTransaction();
        try {
            // 1️⃣ Cập nhật thông tin người dùng
            $user->HoTen = $request->HoTen ?? $user->HoTen;
            $user->Email = $request->Email ?? $user->Email;
            $user->TenDangNhap = $request->TenDangNhap ?? $user->TenDangNhap;
            if ($request->filled('MatKhau')) {
                $user->MatKhau = Hash::make($request->MatKhau);
            }
            $user->save();

            // 2️⃣ Cập nhật vai trò (nếu có)
            if ($request->filled('VaiTro')) {
                // Xóa quyền cũ
                NguoiDungVaiTro::where('MaND', $user->MaND)->delete();

                // Gán quyền mới
                $vaiTro = VaiTro::where('TenVaiTro', $request->VaiTro)->first();
                if ($vaiTro) {
                    NguoiDungVaiTro::create([
                        'MaND' => $user->MaND,
                        'MaVaiTro' => $vaiTro->MaVaiTro,
                    ]);
                }

                // 3️⃣ Nếu là giảng viên → cập nhật hoặc tạo mới
                if ($request->VaiTro === 'GiangVien') {
                    GiangVien::updateOrCreate(
                        ['MaND' => $user->MaND],
                        [
                            'HoTen' => $user->HoTen,
                            'MaBoMon' => $request->MaBoMon ?? null,
                        ]
                    );
                }

                // 4️⃣ Nếu là sinh viên → cập nhật hoặc tạo mới
                if ($request->VaiTro === 'SinhVien') {
                    SinhVien::updateOrCreate(
                        ['MaND' => $user->MaND],
                        [
                            'MaLopHanhChinh' => $request->MaLopHanhChinh ?? null,
                            'NamNhapHoc' => $request->NamNhapHoc ?? now()->year,
                        ]
                    );
                }
            }

            DB::commit();
            return response()->json([
                'message' => '✅ Cập nhật tài khoản thành công!',
                'data' => $user
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => '❌ Lỗi khi cập nhật tài khoản: ' . $e->getMessage()
            ], 500);
        }
    }


    public function destroy($id)
    {
        $user = NguoiDung::find($id);
        if (!$user) {
            return response()->json(['message' => 'Không tìm thấy người dùng'], 404);
        }

        // 🔹 Xóa giảng viên nếu có
        \App\Models\GiangVien::where('MaND', $id)->delete();

        // 🔹 Xóa sinh viên nếu có
        \App\Models\SinhVien::where('MaND', $id)->delete();

        // 🔹 Xóa các vai trò gán
        \App\Models\NguoiDungVaiTro::where('MaND', $id)->delete();

        // 🔹 Cuối cùng mới xóa người dùng
        $user->delete();

        return response()->json(['message' => 'Đã xóa tài khoản và các liên kết liên quan']);
    }




    public function getAllBoMon()
    {
        $boMon = BoMon::select('MaBoMon', 'TenBoMon')->orderBy('TenBoMon')->get();
        return response()->json($boMon);
    }
    // ==================== PHÂN QUYỀN ====================
    public function getUsersWithRoles()
    {
        $users = NguoiDung::with('vaiTros')->get();
        return response()->json($users);
    }

    public function getAllRoles()
    {
        return response()->json(VaiTro::all());
    }

    public function addRole($userId, $roleId)
    {
        $user = NguoiDung::findOrFail($userId);
        $user->vaiTros()->syncWithoutDetaching([$roleId]);
        return response()->json(['message' => 'Đã gán vai trò thành công']);
    }

    public function removeRole($userId, $roleId)
    {
        $user = NguoiDung::findOrFail($userId);
        $user->vaiTros()->detach($roleId);
        return response()->json(['message' => 'Đã gỡ vai trò']);
    }
}
