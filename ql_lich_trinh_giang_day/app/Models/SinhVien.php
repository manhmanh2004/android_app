<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SinhVien extends Model
{
    protected $table = 'SinhVien';
    protected $primaryKey = 'MaSV';
    public $timestamps = false;
    protected $guarded = false;

    public function nguoiDung()
    {
        return $this->belongsTo(NguoiDung::class, 'MaND', 'MaND');
    }

    public function lopHocPhans()
    {
        return $this->belongsToMany(LopHocPhan::class, 'DangKyHocPhan', 'MaSV', 'MaLHP')
            ->withPivot('NgayDangKy');
    }

    public function diemDanhs()
    {
        return $this->hasMany(DiemDanh::class, 'MaSV', 'MaSV');
    }
}
