<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('Khoa', function (Blueprint $table) {
            $table->id('MaKhoa');
            $table->string('TenKhoa', 200);
            $table->string('MoTa', 500)->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('Khoa');
    }
};
