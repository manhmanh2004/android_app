import { useEffect, useState } from "react";
import { Alert, Spinner, Table } from "react-bootstrap";
import { boMonService } from "../../api/services/bomon/boMonService";

export default function TienTrinhBoMonPage() {
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [data, setData] = useState([]);
    const [summary, setSummary] = useState({});

    useEffect(() => {
        const fetchData = async () => {
            try {
                setLoading(true);
                setError("");

                // 🔹 Không cần lấy maBoMon nữa, backend tự nhận
                const res = await boMonService.getBaoCao();
                console.log("✅ Dữ liệu báo cáo:", res.data);

                setSummary(res.data?.summary || {});
                setData(res.data?.byGV || []);
            } catch (err) {
                console.error("❌ Lỗi tải tiến trình:", err);
                const msg =
                    err.response?.data?.message ||
                    "Không thể tải tiến trình giảng dạy.";
                setError(msg);
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, []);

    if (loading)
        return (
            <div className="text-center mt-4">
                <Spinner animation="border" />
                <p>Đang tải dữ liệu tiến trình...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-3">
                📘 Tiến trình giảng dạy của Bộ môn
            </h4>

            {error && <Alert variant="danger">{error}</Alert>}

            <div className="mb-3">
                Tổng buổi: {summary.TongSoBuoi || 0} • Đã dạy:{" "}
                {summary.SoBuoiDaDay || 0} • Tỷ lệ hoàn thành:{" "}
                {summary["TienDo(%)"] || 0}%
            </div>

            <Table bordered hover responsive>
                <thead className="table-primary">
                    <tr>
                        <th>#</th>
                        <th>Giảng viên</th>
                        <th>Số buổi dạy</th>
                        <th>Số buổi nghỉ</th>
                        <th>Số buổi dạy bù</th>
                        <th>Tổng buổi</th>
                        <th>Tiến độ (%)</th>
                    </tr>
                </thead>
                <tbody>
                    {data.length > 0 ? (
                        data.map((gv, idx) => (
                            <tr key={gv.MaGV}>
                                <td>{idx + 1}</td>
                                <td>{gv.HoTen}</td>
                                <td>{gv.SoBuoiDaDay}</td>
                                <td>{gv.SoBuoiNghi}</td>
                                <td>{gv.SoBuoiDayBu}</td>
                                <td>{gv.TongSoBuoi}</td>
                                <td>{gv.TienDo}%</td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td colSpan="7" className="text-center text-muted">
                                Không có dữ liệu tiến trình.
                            </td>
                        </tr>
                    )}
                </tbody>
            </Table>
        </div>
    );
}
