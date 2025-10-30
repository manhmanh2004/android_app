<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\NguoiDung;

class AuthController extends Controller
{
    // 🟢 Đăng nhập
    public function login(Request $request)
    {
        $request->validate([
            'TenDangNhap' => 'required|string',
            'MatKhau' => 'required|string',
        ]);

        $user = NguoiDung::where('TenDangNhap', $request->TenDangNhap)->first();

        if (!$user || !Hash::check($request->MatKhau, $user->MatKhau)) {
            return response()->json(['message' => 'Sai tài khoản hoặc mật khẩu'], 401);
        }

        // Tạo token Sanctum
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Đăng nhập thành công',
            'token' => $token,
            'user' => $user,
        ]);
    }

    // 🔴 Đăng xuất
    public function logout(Request $request)
    {
        $request->user()->tokens()->delete();

        return response()->json(['message' => 'Đăng xuất thành công']);
    }

    // 🧍‍♂️ Lấy thông tin người dùng đăng nhập
    public function me(Request $request)
    {
        return response()->json($request->user());
    }
}
