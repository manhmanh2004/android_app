<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DiemDanh extends Model
{
    protected $table = 'DiemDanh';
    protected $primaryKey = 'MaDiemDanh';
    public $timestamps = false;
    protected $guarded = false;

    public function buoiHoc()
    {
        return $this->belongsTo(LichTrinhChiTiet::class, 'MaBuoiHoc', 'MaBuoiHoc');
    }

    public function sinhVien()
    {
        return $this->belongsTo(SinhVien::class, 'MaSV', 'MaSV');
    }
}
