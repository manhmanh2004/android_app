<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('LopHocPhan', function (Blueprint $table) {
            $table->id('MaLHP');
            $table->string('TenLHP', 200);
            $table->unsignedBigInteger('MaMonHoc');
            $table->unsignedBigInteger('MaHK');
            $table->unsignedBigInteger('MaPhongMacDinh')->nullable();
            $table->integer('SiSoToiDa');
            $table->string('TrangThai', 20)->default('DangDay');

            $table->foreign('MaMonHoc')->references('MaMonHoc')->on('MonHoc');
            $table->foreign('MaHK')->references('MaHK')->on('HocKy');
            $table->foreign('MaPhongMacDinh')->references('MaPhong')->on('PhongHoc');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('LopHocPhan');
    }
};
