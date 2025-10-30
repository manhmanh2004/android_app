<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('SinhVien', function (Blueprint $table) {
            $table->id('MaSV');
            $table->unsignedBigInteger('MaND')->unique();
            $table->string('MaLopHanhChinh', 50)->nullable();
            $table->integer('NamNhapHoc')->nullable();

            $table->foreign('MaND')->references('MaND')->on('NguoiDung');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('SinhVien');
    }
};
