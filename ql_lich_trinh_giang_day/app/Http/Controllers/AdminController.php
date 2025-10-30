<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\NguoiDung;
use App\Models\VaiTro;

class AdminController extends Controller
{
    // 📋 Danh sách tất cả người dùng
    public function index()
    {
        $users = NguoiDung::with('vaiTros')->get();
        return response()->json($users);
    }

    // ➕ Tạo tài khoản mới
    public function store(Request $request)
    {
        $request->validate([
            'TenDangNhap' => 'required|unique:NguoiDung',
            'HoTen' => 'required',
            'Email' => 'required|email|unique:NguoiDung',
            'MatKhau' => 'required|min:6',
        ]);

        $user = NguoiDung::create([
            'TenDangNhap' => $request->TenDangNhap,
            'HoTen' => $request->HoTen,
            'Email' => $request->Email,
            'MatKhau' => bcrypt($request->MatKhau),
        ]);

        return response()->json(['message' => 'Tạo tài khoản thành công', 'user' => $user], 201);
    }

    // 🛠️ Gán vai trò cho người dùng
    public function assignRole(Request $request, $MaND)
    {
        $request->validate([
            'MaVaiTro' => 'required|exists:VaiTro,MaVaiTro',
        ]);

        $user = NguoiDung::findOrFail($MaND);
        $user->vaiTros()->syncWithoutDetaching([$request->MaVaiTro]);

        return response()->json(['message' => 'Phân quyền thành công']);
    }

    // ❌ Xóa người dùng
    public function destroy($MaND)
    {
        $user = NguoiDung::findOrFail($MaND);
        $user->delete();

        return response()->json(['message' => 'Xóa người dùng thành công']);
    }
}
