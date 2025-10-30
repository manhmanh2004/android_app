<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('NguoiDung', function (Blueprint $table) {
            $table->id('MaND');
            $table->string('TenDangNhap', 100)->unique();
            $table->string('MatKhau', 255);
            $table->string('HoTen', 200);
            $table->string('Email', 200)->unique();
            $table->boolean('TrangThai')->default(true);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('NguoiDung');
    }
};
