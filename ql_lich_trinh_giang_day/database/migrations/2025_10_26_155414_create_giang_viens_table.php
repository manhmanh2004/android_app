<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('GiangVien', function (Blueprint $table) {
            $table->id('MaGV');
            $table->unsignedBigInteger('MaND')->unique();
            $table->unsignedBigInteger('MaBoMon');
            $table->string('TrinhDo', 100)->nullable();

            $table->foreign('MaND')->references('MaND')->on('NguoiDung');
            $table->foreign('MaBoMon')->references('MaBoMon')->on('BoMon');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('GiangVien');
    }
};
