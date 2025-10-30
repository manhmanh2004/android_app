<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LopHocPhan extends Model
{
    protected $table = 'LopHocPhan';
    protected $primaryKey = 'MaLHP';
    public $timestamps = false;
    protected $fillable = [
        'TenLHP',
        'MaMonHoc',
        'MaHK',
        'MaPhongMacDinh',
        'SiSoToiDa'
    ];
    protected $attributes = [
        'SiSoToiDa' => 50,
    ];


    public function monHoc()
    {
        return $this->belongsTo(MonHoc::class, 'MaMonHoc', 'MaMonHoc');
    }

    public function hocKy()
    {
        return $this->belongsTo(HocKy::class, 'MaHK', 'MaHK');
    }

    public function phongMacDinh()
    {
        return $this->belongsTo(PhongHoc::class, 'MaPhongMacDinh', 'MaPhong');
    }

    public function phanCongs()
    {
        return $this->hasMany(PhanCong::class, 'MaLHP', 'MaLHP');
    }

    public function giangViens()
    {
        return $this->belongsToMany(GiangVien::class, 'PhanCong', 'MaLHP', 'MaGV')
            ->withPivot('NgayPhanCong');
    }

    public function sinhViens()
    {
        return $this->belongsToMany(SinhVien::class, 'DangKyHocPhan', 'MaLHP', 'MaSV')
            ->withPivot('NgayDangKy');
    }

    public function lichTrinhChiTiet()
    {
        return $this->hasMany(LichTrinhChiTiet::class, 'MaLHP', 'MaLHP');
    }
}
