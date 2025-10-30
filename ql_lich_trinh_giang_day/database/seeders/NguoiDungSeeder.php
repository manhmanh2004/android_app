<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class NguoiDungSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('NguoiDung')->insert([
            'TenDangNhap' => 'admin',
            'MatKhau' => Hash::make('123456'),
            'HoTen' => 'Quản trị viên hệ thống',
            'Email' => 'admin@tlu.edu.vn',
            'TrangThai' => 1,
        ]);
    }
}
