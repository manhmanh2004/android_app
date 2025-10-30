<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MonHoc extends Model
{
    protected $table = 'MonHoc';
    protected $primaryKey = 'MaMonHoc';
    public $timestamps = false;
    protected $guarded = false;

    public function nganh()
    {
        return $this->belongsTo(Nganh::class, 'MaNganh', 'MaNganh');
    }

    public function lopHocPhans()
    {
        return $this->hasMany(LopHocPhan::class, 'MaMonHoc', 'MaMonHoc');
    }
}
