<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('VaiTro', function (Blueprint $table) {
            $table->id('MaVaiTro');
            $table->string('TenVaiTro', 100)->unique();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('VaiTro');
    }
};
