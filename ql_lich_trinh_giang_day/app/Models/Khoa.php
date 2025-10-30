<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Khoa extends Model
{
    protected $table = 'Khoa';
    protected $primaryKey = 'MaKhoa';
    public $timestamps = false;
    protected $fillable = ['TenKhoa'];

    public function boMons()
    {
        return $this->hasMany(BoMon::class, 'MaKhoa', 'MaKhoa');
    }

    public function nganhs()
    {
        return $this->hasMany(Nganh::class, 'MaKhoa', 'MaKhoa');
    }
}
