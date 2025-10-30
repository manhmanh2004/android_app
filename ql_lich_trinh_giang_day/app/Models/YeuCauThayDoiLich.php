<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class YeuCauThayDoiLich extends Model
{
    protected $table = 'YeuCauThayDoiLich';
    protected $primaryKey = 'MaYeuCau';
    public $timestamps = false;
    protected $guarded = false;

    public function giangVien()
    {
        return $this->belongsTo(GiangVien::class, 'MaGV', 'MaGV');
    }

    public function buoiHocNguon()
    {
        return $this->belongsTo(LichTrinhChiTiet::class, 'MaBuoiHocNguon', 'MaBuoiHoc');
    }

    public function phongDeNghi()
    {
        return $this->belongsTo(PhongHoc::class, 'MaPhongDeNghi', 'MaPhong');
    }
}
