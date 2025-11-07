import { useEffect, useState } from "react";
import { Table, Spinner, Alert, InputGroup, Form } from "react-bootstrap";
import { boMonService } from "../../api/services/bomon/boMonService";

export default function GiangVienBoMonPage() {
    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [searchTerm, setSearchTerm] = useState("");

    useEffect(() => {
        const fetchData = async () => {
            try {
                const maBoMon = localStorage.getItem("maBoMon") || 1; // tạm test
                const res = await boMonService.getGiangVien(maBoMon);
                setData(res.data?.giangViens || []);
            } catch (err) {
                console.error(err);
                setError("Không thể tải danh sách giảng viên.");
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    const filtered = data.filter((gv) =>
        gv.HoTen?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    if (loading)
        return (
            <div className="text-center mt-5">
                <Spinner animation="border" />
                <p className="mt-2 text-muted">Đang tải dữ liệu...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-3">
                👨‍🏫 Danh sách Giảng viên Bộ môn
            </h4>
            {error && <Alert variant="danger">{error}</Alert>}

            <InputGroup className="mb-3" style={{ maxWidth: 300 }}>
                <Form.Control
                    placeholder="🔍 Tìm theo tên..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                />
            </InputGroup>

            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th>#</th>
                        <th>Họ tên</th>
                        <th>Email</th>
                        <th>Trình độ</th>
                    </tr>
                </thead>
                <tbody>
                    {filtered.length > 0 ? (
                        filtered.map((gv, i) => (
                            <tr key={gv.MaGV}>
                                <td>{i + 1}</td>
                                <td>{gv.HoTen}</td>
                                <td>{gv.Email}</td>
                                <td>{gv.TrinhDo || "—"}</td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td
                                colSpan="4"
                                className="text-center text-muted py-3"
                            >
                                Không có giảng viên phù hợp.
                            </td>
                        </tr>
                    )}
                </tbody>
            </Table>
        </div>
    );
}
