import { useEffect, useState } from "react";
import { Table, Spinner, Alert, Form } from "react-bootstrap";
import { boMonService } from "../../api/services/bomon/boMonService";

export default function LichDayBoMonPage() {
    const [lich, setLich] = useState([]);
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(true);
    const [maGV, setMaGV] = useState("");

    useEffect(() => {
        const fetchData = async () => {
            try {
                const res = await boMonService.getGiangVien(1);
                if (res.data?.giangViens?.length)
                    setMaGV(res.data.giangViens[0].MaGV);
            } catch (e) {
                setError("Không tải được danh sách giảng viên.", e);
            }
        };
        fetchData();
    }, []);

    useEffect(() => {
        if (!maGV) return;
        const fetchLich = async () => {
            try {
                const res = await boMonService.getTienTrinh(maGV);
                setLich(res.data?.theoLHP || []);
            } catch (err) {
                setError("Không thể tải lịch dạy.", err);
            } finally {
                setLoading(false);
            }
        };
        fetchLich();
    }, [maGV]);

    if (loading)
        return (
            <div className="text-center mt-5">
                <Spinner animation="border" />
                <p className="mt-2 text-muted">Đang tải lịch dạy...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-3">
                📅 Lịch dạy của Bộ môn
            </h4>
            {error && <Alert variant="danger">{error}</Alert>}

            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th>#</th>
                        <th>Mã lớp học phần</th>
                        <th>Số buổi đã dạy</th>
                        <th>Số buổi nghỉ</th>
                        <th>Số buổi dạy bù</th>
                        <th>Tổng số buổi</th>
                        <th>Tiến độ (%)</th>
                    </tr>
                </thead>
                <tbody>
                    {lich.length > 0 ? (
                        lich.map((row, i) => (
                            <tr key={i}>
                                <td>{i + 1}</td>
                                <td>{row.MaLHP}</td>
                                <td>{row.SoBuoiDaDay}</td>
                                <td>{row.SoBuoiNghi}</td>
                                <td>{row.SoBuoiDayBu}</td>
                                <td>{row.TongSoBuoi}</td>
                                <td>{row["TienDo(%)"] || row.TienDo || 0}%</td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td
                                colSpan="7"
                                className="text-center text-muted py-3"
                            >
                                Không có dữ liệu lịch dạy.
                            </td>
                        </tr>
                    )}
                </tbody>
            </Table>
        </div>
    );
}
