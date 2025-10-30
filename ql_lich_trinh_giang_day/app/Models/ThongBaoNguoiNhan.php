<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ThongBaoNguoiNhan extends Model
{
    protected $table = 'ThongBao_NguoiNhan';
    public $timestamps = false;
    public $incrementing = false;
    protected $primaryKey = null;
    protected $guarded = false;

    public function thongBao()
    {
        return $this->belongsTo(ThongBao::class, 'MaThongBao', 'MaThongBao');
    }

    public function nguoiNhan()
    {
        return $this->belongsTo(NguoiDung::class, 'MaNguoiNhan', 'MaND');
    }
}
