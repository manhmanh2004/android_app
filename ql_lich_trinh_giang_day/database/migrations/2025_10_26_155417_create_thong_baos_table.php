<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ThongBao', function (Blueprint $table) {
            $table->id('MaThongBao');
            $table->string('TieuDe', 300);
            $table->text('NoiDung');
            $table->unsignedBigInteger('NguoiGui');
            $table->dateTime('ThoiGianGui')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->foreign('NguoiGui')->references('MaND')->on('NguoiDung');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ThongBao');
    }
};
