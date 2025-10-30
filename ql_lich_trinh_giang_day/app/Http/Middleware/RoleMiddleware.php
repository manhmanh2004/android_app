<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Chưa đăng nhập'], 401);
        }

        // Lấy danh sách tên vai trò của user (Admin, GiangVien, v.v.)
        $userRoles = $user->vaiTros->pluck('TenVaiTro')->toArray();

        // Nếu user không thuộc bất kỳ role nào được phép → chặn
        if (!array_intersect($roles, $userRoles)) {
            return response()->json(['message' => 'Không có quyền truy cập'], 403);
        }

        return $next($request);
    }
}
