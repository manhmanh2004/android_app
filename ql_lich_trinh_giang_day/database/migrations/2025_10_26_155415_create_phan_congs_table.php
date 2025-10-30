<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('PhanCong', function (Blueprint $table) {
            $table->id('MaPhanCong');
            $table->unsignedBigInteger('MaLHP');
            $table->unsignedBigInteger('MaGV');
            $table->date('NgayPhanCong')->default(DB::raw('CURRENT_DATE'));


            $table->unique(['MaLHP', 'MaGV']);
            $table->foreign('MaLHP')->references('MaLHP')->on('LopHocPhan');
            $table->foreign('MaGV')->references('MaGV')->on('GiangVien');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('PhanCong');
    }
};
