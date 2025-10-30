<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('LichTrinhChiTiet', function (Blueprint $table) {
            $table->id('MaBuoiHoc');
            $table->unsignedBigInteger('MaLHP');
            $table->date('NgayHoc');
            $table->string('CaHoc', 20);
            $table->unsignedBigInteger('MaPhong')->nullable();
            $table->string('TrangThaiBuoiHoc', 20)->default('BinhThuong');
            $table->dateTime('ThoiGianMoDD')->nullable();
            $table->dateTime('ThoiGianDongDD')->nullable();
            $table->text('NoiDungGiangDay')->nullable();

            $table->unique(['MaLHP', 'NgayHoc', 'CaHoc']);
            $table->foreign('MaLHP')->references('MaLHP')->on('LopHocPhan');
            $table->foreign('MaPhong')->references('MaPhong')->on('PhongHoc');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('LichTrinhChiTiet');
    }
};
