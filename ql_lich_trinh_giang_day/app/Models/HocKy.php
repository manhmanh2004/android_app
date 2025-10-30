<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HocKy extends Model
{
    protected $table = 'HocKy';
    protected $primaryKey = 'MaHK';
    public $timestamps = false;
    protected $guarded = false;

    public function lopHocPhans()
    {
        return $this->hasMany(LopHocPhan::class, 'MaHK', 'MaHK');
    }
}
