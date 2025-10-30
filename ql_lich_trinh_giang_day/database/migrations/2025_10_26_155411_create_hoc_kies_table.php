<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('HocKy', function (Blueprint $table) {
            $table->id('MaHK');
            $table->string('TenHK', 100);
            $table->date('NgayBatDau');
            $table->date('NgayKetThuc');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('HocKy');
    }
};
