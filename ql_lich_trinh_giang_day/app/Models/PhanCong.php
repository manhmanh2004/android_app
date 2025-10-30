<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PhanCong extends Model
{
    protected $table = 'PhanCong';
    protected $primaryKey = 'MaPhanCong'; // hoặc 'MaPC' — tùy bảng bạn đặt
    public $timestamps = false;
    protected $fillable = ['MaLHP', 'MaGV', 'NgayPhanCong'];

    public function giangVien()
    {
        return $this->belongsTo(GiangVien::class, 'MaGV', 'MaGV');
    }

    public function lopHocPhan()
    {
        return $this->belongsTo(LopHocPhan::class, 'MaLHP', 'MaLHP');
    }
}
