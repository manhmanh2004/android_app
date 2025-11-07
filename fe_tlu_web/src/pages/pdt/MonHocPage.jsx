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
import { monHocService } from "../../api/services/pdt/monHocService";
import { nganhService } from "../../api/services/pdt/nganhService";

export default function MonHocPage() {
    const [monhocs, setMonHocs] = useState([]);
    const [nganhs, setNganhs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [editData, setEditData] = useState(null);
    const [formData, setFormData] = useState({
        TenMonHoc: "",
        SoTinChi: "",
        SoTiet: "",
        MaNganh: "",
    });

    // 🔍 Tìm kiếm + phân trang
    const [searchTerm, setSearchTerm] = useState("");
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // 🧩 Lấy danh sách môn học & ngành
    const fetchData = async () => {
        try {
            setLoading(true);
            const [monhocRes, nganhRes] = await Promise.all([
                monHocService.getAll(),
                nganhService.getAll(),
            ]);
            const monData = Array.isArray(monhocRes?.data)
                ? monhocRes.data
                : monhocRes.data?.data || [];
            const nganhData = Array.isArray(nganhRes?.data)
                ? nganhRes.data
                : nganhRes.data?.data || [];
            setMonHocs(Array.isArray(monData) ? monData : []);
            setNganhs(Array.isArray(nganhData) ? nganhData : []);
        } catch (err) {
            console.error(err);
            setError("Không thể tải dữ liệu môn học / ngành");
            setMonHocs([]);
            setNganhs([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    // 🟢 Mở modal thêm mới
    const handleShowAdd = () => {
        setEditData(null);
        setFormData({
            TenMonHoc: "",
            SoTinChi: "",
            SoTiet: "",
            MaNganh: "",
        });
        setShowModal(true);
    };

    // 🟡 Mở modal sửa
    const handleShowEdit = (item) => {
        setEditData(item);
        setFormData({
            TenMonHoc: item.TenMonHoc,
            SoTinChi: item.SoTinChi,
            SoTiet: item.SoTiet,
            MaNganh: item.MaNganh,
        });
        setShowModal(true);
    };

    // 🔴 Xóa môn học
    const handleDelete = async (id) => {
        if (!window.confirm("Bạn có chắc muốn xóa môn học này?")) return;
        try {
            await monHocService.delete(id);
            await fetchData();
        } catch (err) {
            alert(
                "Lỗi khi xóa môn học: " +
                    (err.response?.data?.message || err.message)
            );
        }
    };

    // 💾 Thêm / Cập nhật môn học
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editData) {
                await monHocService.update(editData.MaMonHoc, formData);
            } else {
                await monHocService.create(formData);
            }
            await fetchData();
            setShowModal(false);
        } catch (err) {
            alert(
                "Lỗi khi lưu môn học: " +
                    (err.response?.data?.message || err.message)
            );
        }
    };

    // 🔍 Lọc danh sách môn học theo tên môn hoặc ngành
    const filteredMonHocs = monhocs.filter((m) => {
        const search = searchTerm.toLowerCase();
        return (
            m.TenMonHoc.toLowerCase().includes(search) ||
            m.nganh?.TenNganh?.toLowerCase().includes(search)
        );
    });

    // 📄 Phân trang dữ liệu
    const totalPages = Math.ceil(filteredMonHocs.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredMonHocs.slice(
        startIndex,
        startIndex + itemsPerPage
    );

    // ⚙️ Đổi trang
    const handlePageChange = (page) => {
        if (page >= 1 && page <= totalPages) {
            setCurrentPage(page);
        }
    };

    // 🌀 Loading
    if (loading)
        return (
            <div className="text-center mt-5">
                <Spinner animation="border" variant="primary" />
                <p className="mt-2 text-secondary">Đang tải dữ liệu...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-4">📚 Quản lý Môn học</h4>

            {error && <Alert variant="danger">{error}</Alert>}

            {/* Thanh tìm kiếm + nút thêm */}
            <div className="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <InputGroup style={{ maxWidth: 300 }}>
                    <Form.Control
                        type="text"
                        placeholder="🔍 Tìm theo tên môn hoặc tên ngành..."
                        value={searchTerm}
                        onChange={(e) => {
                            setSearchTerm(e.target.value);
                            setCurrentPage(1); // reset trang đầu khi tìm kiếm
                        }}
                    />
                </InputGroup>

                <Button variant="primary" onClick={handleShowAdd}>
                    ➕ Thêm môn học
                </Button>
            </div>

            {/* Bảng dữ liệu */}
            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th style={{ width: "60px" }}>#</th>
                        <th>Tên môn học</th>
                        <th>Số tín chỉ</th>
                        <th>Số tiết</th>
                        <th>Ngành</th>
                        <th className="text-center" style={{ width: "180px" }}>
                            Hành động
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {Array.isArray(paginatedData) &&
                    paginatedData.length > 0 ? (
                        paginatedData.map((m, idx) => (
                            <tr key={m.MaMonHoc}>
                                <td>{startIndex + idx + 1}</td>
                                <td>{m.TenMonHoc}</td>
                                <td>{m.SoTinChi}</td>
                                <td>{m.SoTiet}</td>
                                <td>{m.nganh?.TenNganh || "—"}</td>
                                <td className="text-center">
                                    <Button
                                        variant="warning"
                                        size="sm"
                                        className="me-2"
                                        onClick={() => handleShowEdit(m)}
                                    >
                                        ✏️ Sửa
                                    </Button>
                                    <Button
                                        variant="danger"
                                        size="sm"
                                        onClick={() => handleDelete(m.MaMonHoc)}
                                    >
                                        🗑️ Xóa
                                    </Button>
                                </td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td
                                colSpan="6"
                                className="text-center text-muted py-3"
                            >
                                Không có dữ liệu phù hợp
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

            {/* Modal thêm/sửa */}
            <Modal show={showModal} onHide={() => setShowModal(false)} centered>
                <Form onSubmit={handleSubmit}>
                    <Modal.Header closeButton>
                        <Modal.Title>
                            {editData
                                ? "✏️ Cập nhật Môn học"
                                : "➕ Thêm Môn học mới"}
                        </Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Tên môn học</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.TenMonHoc}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        TenMonHoc: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Số tín chỉ</Form.Label>
                            <Form.Control
                                type="number"
                                min="1"
                                value={formData.SoTinChi}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        SoTinChi: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Số tiết</Form.Label>
                            <Form.Control
                                type="number"
                                min="1"
                                value={formData.SoTiet}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        SoTiet: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Thuộc Ngành</Form.Label>
                            <Form.Select
                                value={formData.MaNganh}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        MaNganh: e.target.value,
                                    })
                                }
                                required
                            >
                                <option value="">-- Chọn ngành --</option>
                                {Array.isArray(nganhs) &&
                                    nganhs.map((n) => (
                                        <option
                                            key={n.MaNganh}
                                            value={n.MaNganh}
                                        >
                                            {n.TenNganh}
                                        </option>
                                    ))}
                            </Form.Select>
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
        </div>
    );
}
