import { useState, useEffect } from "react";
import {
    Table,
    Button,
    Modal,
    Form,
    Spinner,
    Alert,
    InputGroup,
} from "react-bootstrap";
import { lopHocPhanService } from "../../api/services/pdt/lopHocPhanService";
import { monHocService } from "../../api/services/pdt/monHocService";
import { hocKyService } from "../../api/services/pdt/hocKyService";
import { phongHocService } from "../../api/services/pdt/phongHocService";

export default function LopHocPhanPage() {
    const [lhps, setLhps] = useState([]);
    const [mons, setMons] = useState([]);
    const [hocKys, setHocKys] = useState([]);
    const [phongs, setPhongs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    const [showModal, setShowModal] = useState(false);
    const [showStudents, setShowStudents] = useState(false);
    const [students, setStudents] = useState([]);
    const [selectedLHP, setSelectedLHP] = useState(null);

    const [formData, setFormData] = useState({
        TenLHP: "",
        MaMonHoc: "",
        MaHK: "",
        MaPhongMacDinh: "",
        SiSoToiDa: "",
    });

    // 🔍 Bộ lọc & phân trang
    const [searchTerm, setSearchTerm] = useState("");
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // 🧠 Lấy dữ liệu ban đầu
    useEffect(() => {
        const fetchData = async () => {
            try {
                setLoading(true);
                const [lhpRes, monRes, hkRes, phongRes] = await Promise.all([
                    lopHocPhanService.getAll(),
                    monHocService.getAll(),
                    hocKyService.getAll(),
                    phongHocService.getAll(),
                ]);
                console.log("📘 MonHoc:", monRes);
                console.log("🧭 HocKy:", hkRes);
                console.log("🏫 PhongHoc:", phongRes);
                const lhpData = Array.isArray(lhpRes.data)
                    ? lhpRes.data
                    : lhpRes.data?.data || [];
                setLhps(lhpData);

                setMons(
                    Array.isArray(monRes.data)
                        ? monRes.data
                        : monRes.data?.data || []
                );
                setHocKys(
                    Array.isArray(hkRes.data)
                        ? hkRes.data
                        : hkRes.data?.data || []
                );
                setPhongs(
                    Array.isArray(phongRes.data)
                        ? phongRes.data
                        : phongRes.data?.data || []
                );
            } catch (err) {
                console.error("❌ Lỗi tải dữ liệu:", err);
                setError("Không thể tải dữ liệu lớp học phần.");
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    // 🟢 Thêm lớp học phần
    const handleCreate = async (e) => {
        e.preventDefault();
        try {
            await lopHocPhanService.create(formData);
            const res = await lopHocPhanService.getAll();
            setLhps(res.data?.data || []);
            setShowModal(false);
        } catch (err) {
            alert(
                "Lỗi khi tạo lớp học phần: " +
                    (err.response?.data?.message || err.message)
            );
        }
    };

    // 📤 Import file sinh viên
    const handleUploadFile = async (maLHP) => {
        const fileInput = document.createElement("input");
        fileInput.type = "file";
        fileInput.accept = ".xlsx, .xls";
        fileInput.onchange = async (e) => {
            const file = e.target.files[0];
            if (!file) return;
            const formData = new FormData();
            formData.append("file", file);
            formData.append("MaLHP", maLHP);
            try {
                await lopHocPhanService.importStudents(maLHP, formData);
                alert("✅ Import danh sách sinh viên thành công!");
            } catch (err) {
                alert(
                    "❌ Lỗi import: " +
                        (err.response?.data?.message || err.message)
                );
            }
        };
        fileInput.click();
    };

    // 👀 Xem danh sách sinh viên
    const handleViewStudents = async (maLHP) => {
        try {
            const res = await lopHocPhanService.getStudents(maLHP);
            setStudents(res.data?.data || []);
            setSelectedLHP(maLHP);
            setShowStudents(true);
        } catch (err) {
            alert("❌ Không thể tải danh sách sinh viên", err);
        }
    };

    // 🔎 Lọc danh sách theo tên lớp học phần
    const filteredLhps = lhps.filter((l) =>
        l.TenLHP.toLowerCase().includes(searchTerm.toLowerCase())
    );

    // 📄 Tính phân trang
    const totalPages = Math.ceil(filteredLhps.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredLhps.slice(
        startIndex,
        startIndex + itemsPerPage
    );

    const handlePageChange = (page) => {
        if (page >= 1 && page <= totalPages) setCurrentPage(page);
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
                📘 Quản lý Lớp học phần
            </h4>
            {error && <Alert variant="danger">{error}</Alert>}

            <div className="d-flex justify-content-between align-items-center mb-3">
                <div className="d-flex align-items-center gap-2">
                    <span>Tổng số lớp học phần: {lhps.length}</span>
                    <InputGroup style={{ width: "250px" }}>
                        <Form.Control
                            placeholder="🔍 Tìm theo tên học phần..."
                            value={searchTerm}
                            onChange={(e) => {
                                setSearchTerm(e.target.value);
                                setCurrentPage(1);
                            }}
                        />
                    </InputGroup>
                </div>
                <Button variant="primary" onClick={() => setShowModal(true)}>
                    ➕ Thêm lớp học phần
                </Button>
            </div>

            {/* 📋 Bảng danh sách */}
            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th>#</th>
                        <th>Tên lớp học phần</th>
                        <th>Môn học</th>
                        <th>Học kỳ</th>
                        <th>Phòng học</th>
                        <th>Sĩ số tối đa</th>
                        <th className="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    {paginatedData.length > 0 ? (
                        paginatedData.map((l, idx) => (
                            <tr key={l.MaLHP}>
                                <td>{startIndex + idx + 1}</td>
                                <td>{l.TenLHP}</td>
                                <td>{l.mon_hoc?.TenMonHoc || "—"}</td>
                                <td>{l.hoc_ky?.TenHK || "—"}</td>
                                <td>{l.phong_mac_dinh?.TenPhong || "—"}</td>
                                <td>{l.SiSoToiDa}</td>
                                <td className="text-center">
                                    <Button
                                        size="sm"
                                        variant="info"
                                        className="me-2"
                                        onClick={() =>
                                            handleViewStudents(l.MaLHP)
                                        }
                                    >
                                        📋 Xem SV
                                    </Button>
                                    <Button
                                        size="sm"
                                        variant="success"
                                        onClick={() =>
                                            handleUploadFile(l.MaLHP)
                                        }
                                    >
                                        📤 Import
                                    </Button>
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

            {/* 📄 Phân trang */}
            {totalPages > 1 && (
                <div className="d-flex justify-content-center align-items-center gap-2 mt-3">
                    <Button
                        size="sm"
                        variant="outline-primary"
                        disabled={currentPage === 1}
                        onClick={() => handlePageChange(currentPage - 1)}
                    >
                        ⬅️ Trước
                    </Button>
                    <span>
                        Trang {currentPage} / {totalPages}
                    </span>
                    <Button
                        size="sm"
                        variant="outline-primary"
                        disabled={currentPage === totalPages}
                        onClick={() => handlePageChange(currentPage + 1)}
                    >
                        Tiếp ➡️
                    </Button>
                </div>
            )}

            {/* 🪟 Modal thêm LHP */}
            <Modal show={showModal} onHide={() => setShowModal(false)} centered>
                <Form onSubmit={handleCreate}>
                    <Modal.Header closeButton>
                        <Modal.Title>➕ Thêm Lớp học phần</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Tên lớp học phần</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.TenLHP}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        TenLHP: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label>Môn học</Form.Label>
                            <Form.Select
                                value={formData.MaMonHoc}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        MaMonHoc: e.target.value,
                                    })
                                }
                                required
                            >
                                <option value="">-- Chọn môn học --</option>
                                {mons.map((m) => (
                                    <option key={m.MaMonHoc} value={m.MaMonHoc}>
                                        {m.TenMonHoc}
                                    </option>
                                ))}
                            </Form.Select>
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label>Học kỳ</Form.Label>
                            <Form.Select
                                value={formData.MaHK}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        MaHK: e.target.value,
                                    })
                                }
                                required
                            >
                                <option value="">-- Chọn học kỳ --</option>
                                {hocKys.map((hk) => (
                                    <option key={hk.MaHK} value={hk.MaHK}>
                                        {hk.TenHK}
                                    </option>
                                ))}
                            </Form.Select>
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label>Phòng học mặc định</Form.Label>
                            <Form.Select
                                value={formData.MaPhongMacDinh}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        MaPhongMacDinh: e.target.value,
                                    })
                                }
                            >
                                <option value="">-- Chọn phòng --</option>
                                {phongs.map((p) => (
                                    <option key={p.MaPhong} value={p.MaPhong}>
                                        {p.TenPhong}
                                    </option>
                                ))}
                            </Form.Select>
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label>Sĩ số tối đa</Form.Label>
                            <Form.Control
                                type="number"
                                value={formData.SiSoToiDa}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        SiSoToiDa: e.target.value,
                                    })
                                }
                                min="1"
                                required
                            />
                        </Form.Group>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button
                            variant="secondary"
                            onClick={() => setShowModal(false)}
                        >
                            Hủy
                        </Button>
                        <Button variant="primary" type="submit">
                            Lưu
                        </Button>
                    </Modal.Footer>
                </Form>
            </Modal>

            {/* 🪟 Modal xem danh sách sinh viên */}
            <Modal
                show={showStudents}
                onHide={() => setShowStudents(false)}
                size="lg"
                centered
            >
                <Modal.Header closeButton>
                    <Modal.Title>
                        📋 Danh sách sinh viên lớp #{selectedLHP}
                    </Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Table bordered hover responsive>
                        <thead className="table-light">
                            <tr>
                                <th>#</th>
                                <th>Mã SV</th>
                                <th>Họ tên</th>
                                <th>Email</th>
                                <th>Lớp hành chính</th>
                                <th>Năm nhập học</th>
                            </tr>
                        </thead>
                        <tbody>
                            {students.length > 0 ? (
                                students.map((sv, idx) => (
                                    <tr key={sv.MaSV}>
                                        <td>{idx + 1}</td>
                                        <td>{sv.MaSV}</td>
                                        <td>{sv.HoTen}</td>
                                        <td>{sv.Email}</td>
                                        <td>{sv.MaLopHanhChinh}</td>
                                        <td>{sv.NamNhapHoc}</td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td
                                        colSpan="6"
                                        className="text-center text-muted"
                                    >
                                        Không có sinh viên nào.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </Table>
                </Modal.Body>
                <Modal.Footer>
                    <Button
                        variant="secondary"
                        onClick={() => setShowStudents(false)}
                    >
                        Đóng
                    </Button>
                </Modal.Footer>
            </Modal>
        </div>
    );
}
