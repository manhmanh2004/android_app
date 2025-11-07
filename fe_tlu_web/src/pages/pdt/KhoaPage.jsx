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
import { khoaService } from "../../api/services/pdt/khoaService";

export default function KhoaPage() {
    const [khoas, setKhoas] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    const [showModal, setShowModal] = useState(false);
    const [selected, setSelected] = useState(null);
    const [formData, setFormData] = useState({ TenKhoa: "" });

    // 🔍 Bộ lọc & phân trang
    const [searchTerm, setSearchTerm] = useState("");
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // 📦 Lấy dữ liệu khoa
    const fetchData = async () => {
        try {
            setLoading(true);
            const res = await khoaService.getAll();
            const data = Array.isArray(res?.data)
                ? res.data
                : res?.data?.data || [];
            setKhoas(Array.isArray(data) ? data : []);
        } catch (err) {
            console.error("❌ Lỗi tải danh sách khoa:", err);
            setError("Không thể tải danh sách khoa.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    // 💾 Thêm hoặc cập nhật khoa
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (selected) {
                await khoaService.update(selected.MaKhoa, formData);
            } else {
                await khoaService.create(formData);
            }
            await fetchData();
            handleClose();
        } catch (err) {
            alert("❌ Lỗi khi lưu khoa!");
            console.error(err);
        }
    };

    // 🗑️ Xóa khoa
    const handleDelete = async (id) => {
        if (window.confirm("Bạn có chắc muốn xóa khoa này?")) {
            try {
                await khoaService.delete(id);
                await fetchData();
            } catch (err) {
                alert("❌ Lỗi khi xóa khoa!");
                console.error(err);
            }
        }
    };

    // 🧹 Reset modal
    const handleClose = () => {
        setShowModal(false);
        setFormData({ TenKhoa: "" });
        setSelected(null);
    };

    // 🔎 Lọc và phân trang
    const filteredKhoas = khoas.filter((k) =>
        k.TenKhoa.toLowerCase().includes(searchTerm.toLowerCase())
    );
    const totalPages = Math.ceil(filteredKhoas.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredKhoas.slice(
        startIndex,
        startIndex + itemsPerPage
    );

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
                <p className="text-muted mt-2">Đang tải dữ liệu...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-4">🏫 Quản lý Khoa</h4>

            {error && <Alert variant="danger">{error}</Alert>}

            <div className="d-flex justify-content-between align-items-center mb-3">
                <div className="d-flex align-items-center gap-2">
                    <span>Tổng số khoa: {khoas.length}</span>
                    <InputGroup style={{ width: "250px" }}>
                        <Form.Control
                            placeholder="🔍 Tìm theo tên khoa..."
                            value={searchTerm}
                            onChange={(e) => {
                                setSearchTerm(e.target.value);
                                setCurrentPage(1); // reset về trang đầu
                            }}
                        />
                    </InputGroup>
                </div>

                <Button
                    variant="primary"
                    onClick={() => {
                        setSelected(null);
                        setFormData({ TenKhoa: "" });
                        setShowModal(true);
                    }}
                >
                    ➕ Thêm Khoa
                </Button>
            </div>

            {/* 📋 Bảng danh sách khoa */}
            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th style={{ width: "60px" }}>#</th>
                        <th>Tên Khoa</th>
                        <th style={{ width: "180px" }} className="text-center">
                            Hành động
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {paginatedData.length > 0 ? (
                        paginatedData.map((k, idx) => (
                            <tr key={k.MaKhoa}>
                                <td>{startIndex + idx + 1}</td>
                                <td>{k.TenKhoa}</td>
                                <td className="text-center">
                                    <Button
                                        size="sm"
                                        variant="warning"
                                        className="me-2"
                                        onClick={() => {
                                            setSelected(k);
                                            setFormData({ TenKhoa: k.TenKhoa });
                                            setShowModal(true);
                                        }}
                                    >
                                        ✏️ Sửa
                                    </Button>
                                    <Button
                                        size="sm"
                                        variant="danger"
                                        onClick={() => handleDelete(k.MaKhoa)}
                                    >
                                        🗑️ Xóa
                                    </Button>
                                </td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td colSpan="3" className="text-center text-muted">
                                Không có khoa nào.
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

            {/* 🪄 Modal thêm / sửa khoa */}
            <Modal show={showModal} onHide={handleClose} centered>
                <Form onSubmit={handleSubmit}>
                    <Modal.Header closeButton>
                        <Modal.Title>
                            {selected ? "✏️ Cập nhật Khoa" : "➕ Thêm Khoa"}
                        </Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Tên Khoa</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.TenKhoa}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        TenKhoa: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={handleClose}>
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
