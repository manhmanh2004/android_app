<?php

namespace App\Http\Controllers;

use App\Models\BoMon;
use App\Models\GiangVien;
use App\Models\PhanCong;
use App\Models\LichTrinhChiTiet;
use App\Models\VThongKeTienDoLHP;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BoMonController extends Controller
{
    /**
     * 1) Danh sách giảng viên theo Bộ Môn
     * GET /api/bo-mon/giang-vien?maBoMon=...
     * - Nếu không truyền maBoMon: cố gắng suy ra từ tài khoản đăng nhập (nếu bạn có mapping)
     */
    public function listGiangVien(Request $request)
    {
        $maBoMon = $request->query('maBoMon');

        if (!$maBoMon) {
            return response()->json(['message' => 'Thiếu tham số maBoMon'], 422);
        }

        $boMon = BoMon::with(['khoa'])
            ->where('MaBoMon', $maBoMon)
            ->first();

        if (!$boMon) {
            return response()->json(['message' => 'Bộ môn không tồn tại'], 404);
        }

        $giangViens = GiangVien::with(['nguoiDung'])
            ->where('MaBoMon', $maBoMon)
            ->orderBy('MaGV', 'asc')
            ->get()
            ->map(function ($gv) {
                return [
                    'MaGV'    => $gv->MaGV,
                    'HoTen'   => $gv->nguoiDung->HoTen ?? null,
                    'Email'   => $gv->nguoiDung->Email ?? null,
                    'TrinhDo' => $gv->TrinhDo,
                ];
            });

        return response()->json([
            'boMon' => [
                'MaBoMon' => $boMon->MaBoMon,
                'TenBoMon' => $boMon->TenBoMon,
                'Khoa'    => $boMon->khoa->TenKhoa ?? null
            ],
            'giangViens' => $giangViens
        ]);
    }

    /**
     * 2) Tiến trình giảng dạy của 1 giảng viên
     * GET /api/bo-mon/giang-vien/{maGV}/tien-trinh?maHK=&from=&to=
     * - Ưu tiên maHK; nếu có from/to thì lọc theo ngày buổi học
     */
    public function tienTrinhGiangVien($maGV, Request $request)
    {
        $gv = GiangVien::with('nguoiDung', 'boMon')->find($maGV);
        if (!$gv) {
            return response()->json(['message' => 'Giảng viên không tồn tại'], 404);
        }

        $maHK = $request->query('maHK');
        $from = $request->query('from'); // YYYY-MM-DD
        $to   = $request->query('to');   // YYYY-MM-DD

        // Lấy các LHP mà GV được phân công
        $pcQuery = PhanCong::where('MaGV', $maGV);

        if ($maHK) {
            $pcQuery->whereHas('lopHocPhan', function ($q) use ($maHK) {
                $q->where('MaHK', $maHK);
            });
        }

        $maLHPs = $pcQuery->pluck('MaLHP');

        // Lọc lịch theo LHP và (HK hoặc from/to)
        $lichQuery = LichTrinhChiTiet::whereIn('MaLHP', $maLHPs);

        if ($from) $lichQuery->whereDate('NgayHoc', '>=', $from);
        if ($to)   $lichQuery->whereDate('NgayHoc', '<=', $to);

        $tong = (clone $lichQuery)->count();
        $daDay = (clone $lichQuery)->whereIn('TrangThaiBuoiHoc', ['BinhThuong', 'DayBu'])->count();
        $nghi = (clone $lichQuery)->where('TrangThaiBuoiHoc', 'Nghi')->count();
        $dayBu = (clone $lichQuery)->where('TrangThaiBuoiHoc', 'DayBu')->count();

        // Gom theo lớp học phần
        $byLHP = (clone $lichQuery)
            ->select(
                'MaLHP',
                DB::raw("SUM(CASE WHEN TrangThaiBuoiHoc IN ('BinhThuong','DayBu') THEN 1 ELSE 0 END) as SoBuoiDaDay"),
                DB::raw("SUM(CASE WHEN TrangThaiBuoiHoc = 'Nghi' THEN 1 ELSE 0 END) as SoBuoiNghi"),
                DB::raw("SUM(CASE WHEN TrangThaiBuoiHoc = 'DayBu' THEN 1 ELSE 0 END) as SoBuoiDayBu"),
                DB::raw("COUNT(*) as TongSoBuoi")
            )
            ->groupBy('MaLHP')
            ->get();

        return response()->json([
            'giangVien' => [
                'MaGV' => $gv->MaGV,
                'HoTen' => $gv->nguoiDung->HoTen ?? null,
                'BoMon' => $gv->boMon->TenBoMon ?? null,
            ],
            'filter' => ['maHK' => $maHK, 'from' => $from, 'to' => $to],
            'tongQuan' => [
                'TongSoBuoi' => $tong,
                'SoBuoiDaDay' => $daDay,
                'SoBuoiNghi' => $nghi,
                'SoBuoiDayBu' => $dayBu,
                'TienDo(%)'  => $tong ? round(100 * $daDay / $tong, 2) : 0
            ],
            'theoLHP' => $byLHP
        ]);
    }

    /**
     * 3) Báo cáo tổng hợp Bộ Môn (dựa trên view vThongKeTienDoLHP)
     * GET /api/bo-mon/bao-cao?maBoMon=&maHK=&from=&to=
     * - Nếu có maHK: ưu tiên dùng view + join theo GV thuộc bộ môn
     * - Nếu có from/to: fallback tính trực tiếp từ LichTrinhChiTiet
     */
    public function baoCaoBoMon(Request $request)
    {
        $maBoMon = $request->query('maBoMon');
        $maHK    = $request->query('maHK');
        $from    = $request->query('from');
        $to      = $request->query('to');

        if (!$maBoMon) {
            return response()->json(['message' => 'Thiếu tham số maBoMon'], 422);
        }

        // Khi có maHK → dùng view vThongKeTienDoLHP (nhanh, gọn)
        if ($maHK && !$from && !$to) {
            $rows = VThongKeTienDoLHP::query()
                ->join('GiangVien as gv', 'gv.MaGV', '=', 'vThongKeTienDoLHP.MaGV')
                ->where('gv.MaBoMon', $maBoMon)
                ->where('vThongKeTienDoLHP.TenHK', function ($q) use ($maHK) {
                    // map TenHK bằng MaHK: bạn có thể sửa view để expose MaHK; tạm thời join qua LopHocPhan để đúng tuyệt đối
                    // Ở đây giữ đơn giản: nếu TenHK bạn set như "HK1 2025", thay bằng join phức tạp ở dưới nếu cần.
                    $q->select('TenHK')->from('HocKy')->where('MaHK', $maHK);
                })
                ->select([
                    'gv.MaGV',
                    'vThongKeTienDoLHP.MaLHP',
                    'vThongKeTienDoLHP.TenLHP',
                    'vThongKeTienDoLHP.TenHK',
                    'vThongKeTienDoLHP.SoBuoiDaDay',
                    'vThongKeTienDoLHP.SoBuoiNghi',
                    'vThongKeTienDoLHP.SoBuoiDayBu',
                    'vThongKeTienDoLHP.TongSoBuoi',
                    'vThongKeTienDoLHP.TienDoPhanTram'
                ])
                ->get();

            return response()->json([
                'filter' => ['maBoMon' => $maBoMon, 'maHK' => $maHK],
                'data'   => $rows,
            ]);
        }

        // Có from/to hoặc không có maHK → tính trực tiếp
        $gvIds = GiangVien::where('MaBoMon', $maBoMon)->pluck('MaGV');
        if ($gvIds->isEmpty()) {
            return response()->json(['filter' => compact('maBoMon', 'maHK', 'from', 'to'), 'data' => []]);
        }

        // Tìm LHP theo giảng viên thuộc bộ môn
        $lhpIds = PhanCong::whereIn('MaGV', $gvIds)
            ->when($maHK, fn($q) => $q->whereHas('lopHocPhan', fn($qq) => $qq->where('MaHK', $maHK)))
            ->pluck('MaLHP');

        $lich = LichTrinhChiTiet::whereIn('MaLHP', $lhpIds)
            ->when($from, fn($q) => $q->whereDate('NgayHoc', '>=', $from))
            ->when($to,   fn($q) => $q->whereDate('NgayHoc', '<=', $to));

        $summary = [
            'TongSoBuoi' => (clone $lich)->count(),
            'SoBuoiDaDay' => (clone $lich)->whereIn('TrangThaiBuoiHoc', ['BinhThuong', 'DayBu'])->count(),
            'SoBuoiNghi' => (clone $lich)->where('TrangThaiBuoiHoc', 'Nghi')->count(),
            'SoBuoiDayBu' => (clone $lich)->where('TrangThaiBuoiHoc', 'DayBu')->count(),
        ];
        $summary['TienDo(%)'] = $summary['TongSoBuoi'] ? round(100 * $summary['SoBuoiDaDay'] / $summary['TongSoBuoi'], 2) : 0;

        // Gom theo GV
        $byGV = LichTrinhChiTiet::whereIn('MaLHP', $lhpIds)
            ->when($from, fn($q) => $q->whereDate('NgayHoc', '>=', $from))
            ->when($to,   fn($q) => $q->whereDate('NgayHoc', '<=', $to))
            ->join('LopHocPhan as lhp', 'lhp.MaLHP', '=', 'LichTrinhChiTiet.MaLHP')
            ->join('PhanCong as pc', 'pc.MaLHP', '=', 'lhp.MaLHP')
            ->join('GiangVien as gv', 'gv.MaGV', '=', 'pc.MaGV')
            ->join('NguoiDung as nd', 'nd.MaND', '=', 'gv.MaND')
            ->groupBy('gv.MaGV', 'nd.HoTen')
            ->selectRaw("
                gv.MaGV, nd.HoTen,
                SUM(CASE WHEN TrangThaiBuoiHoc IN ('BinhThuong','DayBu') THEN 1 ELSE 0 END) as SoBuoiDaDay,
                SUM(CASE WHEN TrangThaiBuoiHoc = 'Nghi' THEN 1 ELSE 0 END) as SoBuoiNghi,
                SUM(CASE WHEN TrangThaiBuoiHoc = 'DayBu' THEN 1 ELSE 0 END) as SoBuoiDayBu,
                COUNT(*) as TongSoBuoi
            ")
            ->get()
            ->map(function ($r) {
                $r->TienDo = $r->TongSoBuoi ? round(100 * ($r->SoBuoiDaDay) / $r->TongSoBuoi, 2) : 0;
                return $r;
            });

        return response()->json([
            'filter'  => ['maBoMon' => $maBoMon, 'maHK' => $maHK, 'from' => $from, 'to' => $to],
            'summary' => $summary,
            'byGV'    => $byGV,
        ]);
    }
}
