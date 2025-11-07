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
import { nganhService } from "../../api/services/pdt/nganhService";
import { khoaService } from "../../api/services/pdt/khoaService";

export default function NganhPage() {
    const [nganhs, setNganhs] = useState([]);
    const [khoas, setKhoas] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [editData, setEditData] = useState(null);
    const [formData, setFormData] = useState({ TenNganh: "", MaKhoa: "" });

    // 🔍 Bộ lọc tìm kiếm & phân trang
    const [searchTerm, setSearchTerm] = useState("");
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // 🧩 Lấy danh sách ngành & khoa
    const fetchData = async () => {
        try {
            setLoading(true);
            const [nganhRes, khoaRes] = await Promise.all([
                nganhService.getAll(),
                khoaService.getAll(),
            ]);

            const nganhData = Array.isArray(nganhRes?.data)
                ? nganhRes.data
                : nganhRes.data?.data || [];
            const khoaData = Array.isArray(khoaRes?.data)
                ? khoaRes.data
                : khoaRes.data?.data || [];

            setNganhs(Array.isArray(nganhData) ? nganhData : []);
            setKhoas(Array.isArray(khoaData) ? khoaData : []);
        } catch (err) {
            console.error(err);
            setError("Không thể tải dữ liệu ngành / khoa");
            setNganhs([]);
            setKhoas([]);
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
        setFormData({ TenNganh: "", MaKhoa: "" });
        setShowModal(true);
    };

    // 🟡 Mở modal sửa
    const handleShowEdit = (item) => {
        setEditData(item);
        setFormData({ TenNganh: item.TenNganh, MaKhoa: item.MaKhoa });
        setShowModal(true);
    };

    // 🔴 Xóa ngành
    const handleDelete = async (id) => {
        if (!window.confirm("Bạn có chắc muốn xóa ngành này?")) return;
        try {
            await nganhService.delete(id);
            await fetchData();
        } catch (err) {
            alert(
                "Lỗi khi xóa ngành: " +
                    (err.response?.data?.message || err.message)
            );
        }
    };

    // 💾 Thêm / Cập nhật ngành
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editData) {
                await nganhService.update(editData.MaNganh, formData);
            } else {
                await nganhService.create(formData);
            }

            await fetchData();
            setShowModal(false);
        } catch (err) {
            alert(
                "Lỗi khi lưu ngành: " +
                    (err.response?.data?.message || err.message)
            );
        }
    };

    // 🔍 Lọc danh sách ngành theo tên ngành hoặc tên khoa
    const filteredNganhs = nganhs.filter((n) => {
        const search = searchTerm.toLowerCase();
        return (
            n.TenNganh.toLowerCase().includes(search) ||
            n.khoa?.TenKhoa?.toLowerCase().includes(search)
        );
    });

    // 📄 Tính dữ liệu phân trang
    const totalPages = Math.ceil(filteredNganhs.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredNganhs.slice(
        startIndex,
        startIndex + itemsPerPage
    );

    // ⚙️ Đổi trang
    const handlePageChange = (page) => {
        if (page >= 1 && page <= totalPages) {
            setCurrentPage(page);
        }
    };

    if (loading)
        return (
            <div className="text-center mt-5">
                <Spinner animation="border" variant="primary" />
                <p className="mt-2 text-secondary">Đang tải dữ liệu...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-4">🎓 Quản lý Ngành</h4>

            {error && <Alert variant="danger">{error}</Alert>}

            {/* Thanh tìm kiếm và nút thêm */}
            <div className="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <InputGroup style={{ maxWidth: 300 }}>
                    <Form.Control
                        type="text"
                        placeholder="🔍 Tìm theo tên ngành hoặc khoa..."
                        value={searchTerm}
                        onChange={(e) => {
                            setSearchTerm(e.target.value);
                            setCurrentPage(1); // reset về trang đầu
                        }}
                    />
                </InputGroup>

                <Button variant="primary" onClick={handleShowAdd}>
                    ➕ Thêm ngành
                </Button>
            </div>

            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th style={{ width: "60px" }}>#</th>
                        <th>Tên ngành</th>
                        <th>Thuộc khoa</th>
                        <th className="text-center" style={{ width: "180px" }}>
                            Hành động
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {Array.isArray(paginatedData) &&
                    paginatedData.length > 0 ? (
                        paginatedData.map((n, idx) => (
                            <tr key={n.MaNganh}>
                                <td>{startIndex + idx + 1}</td>
                                <td>{n.TenNganh}</td>
                                <td>{n.khoa?.TenKhoa || "—"}</td>
                                <td className="text-center">
                                    <Button
                                        variant="warning"
                                        size="sm"
                                        className="me-2"
                                        onClick={() => handleShowEdit(n)}
                                    >
                                        ✏️ Sửa
                                    </Button>
                                    <Button
                                        variant="danger"
                                        size="sm"
                                        onClick={() => handleDelete(n.MaNganh)}
                                    >
                                        🗑️ Xóa
                                    </Button>
                                </td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td
                                colSpan="4"
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
                                ? "✏️ Cập nhật Ngành"
                                : "➕ Thêm Ngành mới"}
                        </Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Tên ngành</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.TenNganh}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        TenNganh: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Thuộc Khoa</Form.Label>
                            <Form.Select
                                value={formData.MaKhoa}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        MaKhoa: e.target.value,
                                    })
                                }
                                required
                            >
                                <option value="">-- Chọn khoa --</option>
                                {Array.isArray(khoas) &&
                                    khoas.map((k) => (
                                        <option key={k.MaKhoa} value={k.MaKhoa}>
                                            {k.TenKhoa}
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
