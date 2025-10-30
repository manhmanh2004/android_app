<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ThongBao_NguoiNhan', function (Blueprint $table) {
            $table->unsignedBigInteger('MaThongBao');
            $table->unsignedBigInteger('MaNguoiNhan');
            $table->boolean('TrangThaiDoc')->default(false);

            $table->primary(['MaThongBao', 'MaNguoiNhan']);
            $table->foreign('MaThongBao')->references('MaThongBao')->on('ThongBao');
            $table->foreign('MaNguoiNhan')->references('MaND')->on('NguoiDung');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ThongBao_NguoiNhan');
    }
};
