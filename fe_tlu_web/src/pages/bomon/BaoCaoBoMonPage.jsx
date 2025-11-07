import { useEffect, useState } from "react";
import { Table, Spinner, Alert } from "react-bootstrap";
import { boMonService } from "../../api/services/bomon/boMonService";

export default function BaoCaoBoMonPage() {
    const [rows, setRows] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    useEffect(() => {
        const fetchData = async () => {
            try {
                const res = await boMonService.getBaoCao(1);
                setRows(res.data?.data || res.data?.byGV || []);
            } catch (err) {
                setError("Không thể tải báo cáo bộ môn.", err);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    if (loading)
        return (
            <div className="text-center mt-5">
                <Spinner animation="border" />
                <p className="text-muted mt-2">Đang tải báo cáo...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-3">📊 Báo cáo Bộ môn</h4>
            {error && <Alert variant="danger">{error}</Alert>}

            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th>#</th>
                        <th>Mã GV</th>
                        <th>Tên LHP</th>
                        <th>Học kỳ</th>
                        <th>Số buổi đã dạy</th>
                        <th>Số buổi nghỉ</th>
                        <th>Tổng số buổi</th>
                        <th>Tiến độ (%)</th>
                    </tr>
                </thead>
                <tbody>
                    {rows.length > 0 ? (
                        rows.map((r, i) => (
                            <tr key={i}>
                                <td>{i + 1}</td>
                                <td>{r.MaGV}</td>
                                <td>{r.TenLHP || "—"}</td>
                                <td>{r.TenHK || "—"}</td>
                                <td>{r.SoBuoiDaDay}</td>
                                <td>{r.SoBuoiNghi}</td>
                                <td>{r.TongSoBuoi}</td>
                                <td>{r.TienDoPhanTram || r.TienDo || 0}%</td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td
                                colSpan="8"
                                className="text-center text-muted py-3"
                            >
                                Không có dữ liệu báo cáo.
                            </td>
                        </tr>
                    )}
                </tbody>
            </Table>
        </div>
    );
}
