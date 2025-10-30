<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('NguoiDung_VaiTro', function (Blueprint $table) {
            $table->unsignedBigInteger('MaND');
            $table->unsignedBigInteger('MaVaiTro');

            $table->primary(['MaND', 'MaVaiTro']);

            $table->foreign('MaND')
                ->references('MaND')
                ->on('NguoiDung')
                ->onDelete('cascade');

            $table->foreign('MaVaiTro')
                ->references('MaVaiTro')
                ->on('VaiTro')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('NguoiDung_VaiTro');
    }
};
