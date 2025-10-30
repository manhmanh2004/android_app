<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('YeuCauThayDoiLich', function (Blueprint $table) {
            $table->id('MaYeuCau');
            $table->unsignedBigInteger('MaGV');
            $table->unsignedBigInteger('MaBuoiHocNguon');
            $table->string('LoaiYeuCau', 20);  // Nghi | DayBu
            $table->date('NgayDeXuat')->default(DB::raw('CURRENT_DATE'));

            $table->date('NgayDeNghiBu')->nullable();
            $table->string('CaDeNghiBu', 20)->nullable();
            $table->unsignedBigInteger('MaPhongDeNghi')->nullable();
            $table->string('LyDo', 1000)->nullable();
            $table->string('TrangThai', 20)->default('ChoDuyet'); // ChoDuyet | Duyet | TuChoi

            $table->foreign('MaGV')->references('MaGV')->on('GiangVien');
            $table->foreign('MaBuoiHocNguon')->references('MaBuoiHoc')->on('LichTrinhChiTiet');
            $table->foreign('MaPhongDeNghi')->references('MaPhong')->on('PhongHoc');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('YeuCauThayDoiLich');
    }
};
