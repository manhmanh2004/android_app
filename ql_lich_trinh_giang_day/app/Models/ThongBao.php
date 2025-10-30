<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ThongBao extends Model
{
    protected $table = 'ThongBao';
    protected $primaryKey = 'MaThongBao';
    public $timestamps = false;
    protected $guarded = false;

    public function nguoiGui()
    {
        return $this->belongsTo(NguoiDung::class, 'NguoiGui', 'MaND');
    }

    public function nguoiNhans()
    {
        return $this->belongsToMany(NguoiDung::class, 'ThongBao_NguoiNhan', 'MaThongBao', 'MaNguoiNhan')
            ->withPivot('TrangThaiDoc');
    }
}
