<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VThongKeTienDoLHP extends Model
{
    protected $table = 'vThongKeTienDoLHP';
    public $timestamps = false;
    public $incrementing = false;
    protected $primaryKey = null; // view không có PK
    protected $guarded = [];
}
