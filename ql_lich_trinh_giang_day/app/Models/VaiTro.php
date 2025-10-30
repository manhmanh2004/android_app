<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VaiTro extends Model
{
    protected $table = 'VaiTro';
    protected $primaryKey = 'MaVaiTro';
    public $timestamps = false;
    protected $guarded = false;

    public function nguoiDungs()
    {
        return $this->belongsToMany(NguoiDung::class, 'NguoiDung_VaiTro', 'MaVaiTro', 'MaND');
    }
}
