<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('DiemDanh', function (Blueprint $table) {
            $table->id('MaDiemDanh');
            $table->unsignedBigInteger('MaBuoiHoc');
            $table->unsignedBigInteger('MaSV');
            $table->string('TrangThaiDD', 20);
            $table->string('GhiChu', 500)->nullable();
            $table->dateTime('ThoiGianDiemDanh')->useCurrent();

            $table->unique(['MaBuoiHoc', 'MaSV']);
            $table->foreign('MaBuoiHoc')->references('MaBuoiHoc')->on('LichTrinhChiTiet');
            $table->foreign('MaSV')->references('MaSV')->on('SinhVien');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('DiemDanh');
    }
};
