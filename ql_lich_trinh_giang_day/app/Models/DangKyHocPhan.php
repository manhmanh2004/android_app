<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DangKyHocPhan extends Model
{
    protected $table = 'DangKyHocPhan';
    public $timestamps = false;
    public $incrementing = false; // PK kép
    protected $primaryKey = null;
    protected $guarded = false;

    public function lopHocPhan()
    {
        return $this->belongsTo(LopHocPhan::class, 'MaLHP', 'MaLHP');
    }

    public function sinhVien()
    {
        return $this->belongsTo(SinhVien::class, 'MaSV', 'MaSV');
    }
}
