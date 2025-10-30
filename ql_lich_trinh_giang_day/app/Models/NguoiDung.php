<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class NguoiDung extends Authenticatable
{
    use HasApiTokens, Notifiable;
    protected $table = 'NguoiDung';
    protected $primaryKey = 'MaND';
    public $timestamps = false;

    protected $hidden = ['MatKhau'];
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'TenDangNhap',
        'Email',
        'MatKhau',
        'HoTen'
    ];


    // Tự động hash mật khẩu khi set
    public function setMatKhauAttribute($value)
    {
        if (!empty($value) && !str_starts_with($value, '$2y$')) {
            $this->attributes['MatKhau'] = Hash::make($value);
        } else {
            $this->attributes['MatKhau'] = $value;
        }
    }

    public function vaiTros()
    {
        return $this->belongsToMany(VaiTro::class, 'NguoiDung_VaiTro', 'MaND', 'MaVaiTro');
    }

    public function giangVien()
    {
        return $this->hasOne(GiangVien::class, 'MaND', 'MaND');
    }

    public function sinhVien()
    {
        return $this->hasOne(SinhVien::class, 'MaND', 'MaND');
    }

    public function thongBaosDaGui()
    {
        return $this->hasMany(ThongBao::class, 'NguoiGui', 'MaND');
    }

    public function thongBaoNhan()
    {
        return $this->belongsToMany(ThongBao::class, 'ThongBao_NguoiNhan', 'MaNguoiNhan', 'MaThongBao')
            ->withPivot('TrangThaiDoc');
    }
}
