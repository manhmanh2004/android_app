<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Nganh extends Model
{
    protected $table = 'Nganh';
    protected $primaryKey = 'MaNganh';
    public $timestamps = false;
    protected $guarded = false;

    public function khoa()
    {
        return $this->belongsTo(Khoa::class, 'MaKhoa', 'MaKhoa');
    }

    public function monHocs()
    {
        return $this->hasMany(MonHoc::class, 'MaNganh', 'MaNganh');
    }
}
