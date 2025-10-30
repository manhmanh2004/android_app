<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PhongHoc extends Model
{
    protected $table = 'PhongHoc';
    protected $primaryKey = 'MaPhong';
    public $timestamps = false;
    protected $guarded = false;

    public function lichTrinhChiTiets()
    {
        return $this->hasMany(LichTrinhChiTiet::class, 'MaPhong', 'MaPhong');
    }
}
