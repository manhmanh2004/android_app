<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;


return new class extends Migration {
    public function up(): void
    {
        Schema::create('DangKyHocPhan', function (Blueprint $table) {
            $table->unsignedBigInteger('MaLHP');
            $table->unsignedBigInteger('MaSV');
            $table->dateTime('ThoiGian')->default(DB::raw('CURRENT_TIMESTAMP'));


            $table->primary(['MaLHP', 'MaSV']);
            $table->foreign('MaLHP')->references('MaLHP')->on('LopHocPhan');
            $table->foreign('MaSV')->references('MaSV')->on('SinhVien');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('DangKyHocPhan');
    }
};
