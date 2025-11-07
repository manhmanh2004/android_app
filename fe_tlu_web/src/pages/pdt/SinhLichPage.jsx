import { useState, useEffect } from "react";
import { Table, Button, Modal, Form, Spinner, Alert } from "react-bootstrap";
import { lopHocPhanService } from "../../api/services/pdt/lopHocPhanService";
import { lichTrinhService } from "../../api/services/pdt/lichTrinhService";

export default function SinhLichPage() {
    const [lhps, setLhps] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showModalSinh, setShowModalSinh] = useState(false);
    const [showModalLich, setShowModalLich] = useState(false);
    const [selectedLHP, setSelectedLHP] = useState(null);
    const [lichs, setLichs] = useState([]);
    const [formData, setFormData] = useState({
        SoBuoi: 10,
        NgayBatDau: "",
        CaHoc: "Ca1",
        MaPhong: "",
    });

    // 🧠 Tải danh sách lớp học phần (có giảng viên và lịch)
    useEffect(() => {
        const fetchData = async () => {
            try {
                setLoading(true);
                const res = await lopHocPhanService.getAllWithGiangVien();
                const data = res.data?.data || [];
                setLhps(Array.isArray(data) ? data : []);
            } catch (err) {
                console.error("❌ Lỗi tải dữ liệu:", err);
                setError("Không thể tải danh sách lớp học phần.");
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    // 🟢 Mở modal sinh lịch
    const moModalSinhLich = (lhp) => {
        setSelectedLHP(lhp);
        setShowModalSinh(true);
    };

    // 📅 Xem lịch đã sinh
    const xemLich = async (maLHP) => {
        try {
            const res = await lichTrinhService.getByLopHocPhan(maLHP);
            setLichs(res.data?.data || []);
            setSelectedLHP(res.data.data?.lop_hoc_phan || null);
            setShowModalLich(true);
        } catch (err) {
            console.error(err);
            alert("Không thể tải lịch của lớp học phần này.");
        }
    };
    // 💾 Gửi yêu cầu sinh lịch
    const handleSinhLich = async (e) => {
        e.preventDefault();
        try {
            await lichTrinhService.sinhLichTuDong({
                MaLHP: selectedLHP.MaLHP,
                ...formData,
            });
            alert("✅ Sinh lịch tự động thành công!");
            setShowModalSinh(false);

            // Reload danh sách lớp học phần
            const res = await lopHocPhanService.getAllWithGiangVien();
            setLhps(res.data?.data || []);
        } catch (err) {
            console.error(err);
            alert(
                "❌ Lỗi khi sinh lịch: " +
                    (err.response?.data?.message || err.message)
            );
        }
    };

    if (loading)
        return (
            <div className="text-center mt-5">
                <Spinner animation="border" variant="primary" />
                <p className="text-muted mt-2">Đang tải dữ liệu...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-4">
                🗓️ Sinh lịch giảng dạy tự động
            </h4>

            {error && <Alert variant="danger">{error}</Alert>}

            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th>#</th>
                        <th>Tên LHP</th>
                        <th>Môn học</th>
                        <th>Giảng viên</th>
                        <th>Học kỳ</th>
                        <th>Phòng</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    {lhps.length > 0 ? (
                        lhps.map((lhp, i) => (
                            <tr key={lhp.MaLHP}>
                                <td>{i + 1}</td>
                                <td>{lhp.TenLHP}</td>
                                <td>{lhp.mon_hoc?.TenMonHoc}</td>
                                <td>
                                    {lhp.giang_viens?.length > 0
                                        ? lhp.giang_viens
                                              .map((gv) => gv.nguoi_dung?.HoTen)
                                              .join(", ")
                                        : "Chưa phân công"}
                                </td>
                                <td>{lhp.hoc_ky?.TenHK}</td>
                                <td>{lhp.phong_mac_dinh?.TenPhong || "—"}</td>
                                <td className="text-center">
                                    {lhp.lich_trinh_chi_tiet?.length > 0 ? (
                                        <>
                                            <Button
                                                variant="info"
                                                size="sm"
                                                className="me-2"
                                                onClick={() =>
                                                    xemLich(lhp.MaLHP)
                                                }
                                            >
                                                📅 Xem lịch
                                            </Button>
                                            <Button
                                                variant="danger"
                                                size="sm"
                                                onClick={async () => {
                                                    if (
                                                        window.confirm(
                                                            `Bạn có chắc muốn xóa toàn bộ lịch của lớp ${lhp.TenLHP}?`
                                                        )
                                                    ) {
                                                        try {
                                                            await lichTrinhService.xoaLichTheoLop(
                                                                lhp.MaLHP
                                                            );
                                                            alert(
                                                                "🗑️ Đã xóa lịch thành công!"
                                                            );
                                                            const res =
                                                                await lopHocPhanService.getAllWithGiangVien();
                                                            setLhps(
                                                                res.data
                                                                    ?.data || []
                                                            );
                                                        } catch (err) {
                                                            console.error(err);
                                                            alert(
                                                                "❌ Lỗi khi xóa lịch: " +
                                                                    (err
                                                                        .response
                                                                        ?.data
                                                                        ?.message ||
                                                                        err.message)
                                                            );
                                                        }
                                                    }
                                                }}
                                            >
                                                🗑️ Xóa lịch
                                            </Button>
                                        </>
                                    ) : (
                                        <Button
                                            variant="success"
                                            size="sm"
                                            onClick={() => moModalSinhLich(lhp)}
                                            disabled={
                                                lhp.giang_viens?.length === 0
                                            }
                                        >
                                            🧮 Sinh lịch
                                        </Button>
                                    )}
                                </td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td colSpan="7" className="text-center text-muted">
                                Không có lớp học phần nào.
                            </td>
                        </tr>
                    )}
                </tbody>
            </Table>

            {/* 🧮 Modal sinh lịch */}
            <Modal
                show={showModalSinh}
                onHide={() => setShowModalSinh(false)}
                centered
            >
                <Form onSubmit={handleSinhLich}>
                    <Modal.Header closeButton>
                        <Modal.Title>
                            🧮 Sinh lịch cho {selectedLHP?.TenLHP}
                        </Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Số buổi học</Form.Label>
                            <Form.Control
                                type="number"
                                min="1"
                                value={formData.SoBuoi}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        SoBuoi: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label>Ngày bắt đầu</Form.Label>
                            <Form.Control
                                type="date"
                                value={formData.NgayBatDau}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        NgayBatDau: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label>Ca học</Form.Label>
                            <Form.Select
                                value={formData.CaHoc}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        CaHoc: e.target.value,
                                    })
                                }
                            >
                                <option value="Ca1">Ca 1 (7h00 - 9h30)</option>
                                <option value="Ca2">Ca 2 (9h45 - 12h15)</option>
                                <option value="Ca3">
                                    Ca 3 (13h30 - 16h00)
                                </option>
                                <option value="Ca4">
                                    Ca 4 (16h15 - 18h45)
                                </option>
                            </Form.Select>
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label>
                                Phòng học (nếu khác mặc định)
                            </Form.Label>
                            <Form.Control
                                type="text"
                                placeholder="Nhập mã phòng hoặc để trống"
                                value={formData.MaPhong}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        MaPhong: e.target.value,
                                    })
                                }
                            />
                        </Form.Group>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button
                            variant="secondary"
                            onClick={() => setShowModalSinh(false)}
                        >
                            Hủy
                        </Button>
                        <Button variant="primary" type="submit">
                            ✅ Sinh lịch
                        </Button>
                    </Modal.Footer>
                </Form>
            </Modal>

            {/* 📅 Modal xem lịch */}
            <Modal
                show={showModalLich}
                onHide={() => setShowModalLich(false)}
                size="lg"
                centered
            >
                <Modal.Header closeButton>
                    <Modal.Title>
                        📅 Lịch giảng dạy của{" "}
                        {selectedLHP?.TenLHP || "Lớp học phần"}
                    </Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Table bordered hover>
                        <thead className="table-info">
                            <tr>
                                <th>#</th>
                                <th>Ngày học</th>
                                <th>Ca học</th>
                                <th>Phòng học</th>
                            </tr>
                        </thead>
                        <tbody>
                            {lichs.length > 0 ? (
                                lichs.map((b, i) => (
                                    <tr key={b.MaBuoiHoc}>
                                        <td>{i + 1}</td>
                                        <td>
                                            {new Date(
                                                b.NgayHoc
                                            ).toLocaleDateString("vi-VN")}
                                        </td>
                                        <td>{b.CaHoc}</td>
                                        <td>{b.phong_hoc?.TenPhong || "—"}</td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td
                                        colSpan="4"
                                        className="text-center text-muted"
                                    >
                                        Chưa có lịch học nào.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </Table>
                </Modal.Body>
            </Modal>
        </div>
    );
}
