<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NguoiDungVaiTro extends Model
{
    protected $table = 'NguoiDung_VaiTro';
    public $timestamps = false;
    protected $primaryKey = null;
    public $incrementing = false;
    protected $fillable = ['MaND', 'MaVaiTro'];
}
