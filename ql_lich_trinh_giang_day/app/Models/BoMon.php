<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BoMon extends Model
{
    protected $table = 'BoMon';
    protected $primaryKey = 'MaBoMon';
    public $timestamps = false;
    protected $fillable = ['TenBoMon', 'MaKhoa'];

    public function khoa()
    {
        return $this->belongsTo(Khoa::class, 'MaKhoa', 'MaKhoa');
    }

    public function giangViens()
    {
        return $this->hasMany(GiangVien::class, 'MaBoMon', 'MaBoMon');
    }
}
