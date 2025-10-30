<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GiangVien extends Model
{
    protected $table = 'GiangVien';
    protected $primaryKey = 'MaGV';
    public $timestamps = false;
    protected $fillable = [
        'HoTen',
        'MaND',
        'MaBoMon'
    ];

    public function nguoiDung()
    {
        return $this->belongsTo(NguoiDung::class, 'MaND', 'MaND');
    }

    public function boMon()
    {
        return $this->belongsTo(BoMon::class, 'MaBoMon', 'MaBoMon');
    }

    public function phanCongs()
    {
        return $this->hasMany(PhanCong::class, 'MaGV', 'MaGV');
    }

    public function yeuCauThayDoiLiches()
    {
        return $this->hasMany(YeuCauThayDoiLich::class, 'MaGV', 'MaGV');
    }
}
