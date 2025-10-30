<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('PhongHoc', function (Blueprint $table) {
            $table->id('MaPhong');
            $table->string('TenPhong', 100);
            $table->integer('SucChua');
            $table->string('LoaiPhong', 10);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('PhongHoc');
    }
};
