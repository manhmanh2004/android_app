<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('GiangVien', function (Blueprint $table) {
            // ⚡ Thêm cột HoTen (nullable để không ảnh hưởng dữ liệu cũ)
            $table->string('HoTen', 100)->nullable()->after('MaGV');
        });
    }

    public function down(): void
    {
        Schema::table('GiangVien', function (Blueprint $table) {
            $table->dropColumn('HoTen');
        });
    }
};
