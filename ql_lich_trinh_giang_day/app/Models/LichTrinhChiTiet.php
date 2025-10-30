<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LichTrinhChiTiet extends Model
{
    protected $table = 'LichTrinhChiTiet';
    protected $primaryKey = 'MaBuoiHoc';
    public $timestamps = false;
    protected $guarded = false;

    public function lopHocPhan()
    {
        return $this->belongsTo(LopHocPhan::class, 'MaLHP', 'MaLHP');
    }

    public function phongHoc()
    {
        return $this->belongsTo(PhongHoc::class, 'MaPhong', 'MaPhong');
    }

    public function diemDanhs()
    {
        return $this->hasMany(DiemDanh::class, 'MaBuoiHoc', 'MaBuoiHoc');
    }
}
