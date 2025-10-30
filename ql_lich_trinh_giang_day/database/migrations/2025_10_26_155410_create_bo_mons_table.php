<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('BoMon', function (Blueprint $table) {
            $table->id('MaBoMon');
            $table->string('TenBoMon', 200);
            $table->unsignedBigInteger('MaKhoa');
            $table->foreign('MaKhoa')->references('MaKhoa')->on('Khoa');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('BoMon');
    }
};
