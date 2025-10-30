<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('MonHoc', function (Blueprint $table) {
            $table->id('MaMonHoc');
            $table->string('TenMonHoc', 200);
            $table->integer('SoTinChi')->check('SoTinChi > 0');
            $table->integer('SoTiet')->check('SoTiet > 0');
            $table->unsignedBigInteger('MaNganh');
            $table->foreign('MaNganh')->references('MaNganh')->on('Nganh');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('MonHoc');
    }
};
