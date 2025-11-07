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
import { hocKyService } from "../../api/services/pdt/hocKyService";

export default function HocKyPage() {
    const [hockys, setHocKys] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [editData, setEditData] = useState(null);
    const [formData, setFormData] = useState({
        TenHK: "",
        NgayBatDau: "",
        NgayKetThuc: "",
    });

    // 🔍 Bộ lọc năm + phân trang
    const [yearFilter, setYearFilter] = useState("");
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // 🧩 Lấy danh sách học kỳ
    const fetchData = async () => {
        try {
            setLoading(true);
            const res = await hocKyService.getAll();
            const data = Array.isArray(res?.data)
                ? res.data
                : res.data?.data || [];
            setHocKys(Array.isArray(data) ? data : []);
        } catch (err) {
            console.error(err);
            setError("Không thể tải dữ liệu học kỳ");
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
        setFormData({ TenHK: "", NgayBatDau: "", NgayKetThuc: "" });
        setShowModal(true);
    };

    // 🟡 Mở modal sửa
    const handleShowEdit = (item) => {
        setEditData(item);
        setFormData({
            TenHK: item.TenHK,
            NgayBatDau: item.NgayBatDau?.slice(0, 10) || "",
            NgayKetThuc: item.NgayKetThuc?.slice(0, 10) || "",
        });
        setShowModal(true);
    };

    // 🔴 Xóa
    const handleDelete = async (id) => {
        if (!window.confirm("Bạn có chắc muốn xóa học kỳ này?")) return;
        try {
            await hocKyService.delete(id);
            await fetchData();
        } catch (err) {
            alert(
                "Lỗi khi xóa: " + (err.response?.data?.message || err.message)
            );
        }
    };

    // 💾 Thêm / Cập nhật
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editData) {
                await hocKyService.update(editData.MaHK, formData);
            } else {
                await hocKyService.create(formData);
            }
            await fetchData();
            setShowModal(false);
        } catch (err) {
            alert(
                "Lỗi khi lưu: " + (err.response?.data?.message || err.message)
            );
        }
    };

    // 🔍 Lọc theo năm
    const filteredHocKys = hockys.filter((h) => {
        if (!yearFilter.trim()) return true;
        const year = yearFilter.trim();
        return (
            h.TenHK?.includes(year) ||
            h.NgayBatDau?.includes(year) ||
            h.NgayKetThuc?.includes(year)
        );
    });

    // 📄 Phân trang
    const totalPages = Math.ceil(filteredHocKys.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredHocKys.slice(
        startIndex,
        startIndex + itemsPerPage
    );

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
            <h4 className="fw-bold text-primary mb-4">📅 Quản lý Học kỳ</h4>
            {error && <Alert variant="danger">{error}</Alert>}

            {/* Bộ lọc năm + nút thêm */}
            <div className="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
                <InputGroup style={{ maxWidth: 250 }}>
                    <Form.Control
                        type="number"
                        placeholder="🔍 Lọc theo năm (VD: 2025)"
                        value={yearFilter}
                        onChange={(e) => {
                            setYearFilter(e.target.value);
                            setCurrentPage(1); // reset trang đầu khi lọc
                        }}
                    />
                </InputGroup>

                <Button variant="primary" onClick={handleShowAdd}>
                    ➕ Thêm học kỳ
                </Button>
            </div>

            {/* Bảng dữ liệu */}
            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th style={{ width: "60px" }}>#</th>
                        <th>Tên học kỳ</th>
                        <th>Ngày bắt đầu</th>
                        <th>Ngày kết thúc</th>
                        <th className="text-center" style={{ width: "160px" }}>
                            Hành động
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {paginatedData.length > 0 ? (
                        paginatedData.map((h, idx) => (
                            <tr key={h.MaHK}>
                                <td>{startIndex + idx + 1}</td>
                                <td>{h.TenHK}</td>
                                <td>{h.NgayBatDau?.slice(0, 10)}</td>
                                <td>{h.NgayKetThuc?.slice(0, 10)}</td>
                                <td className="text-center">
                                    <Button
                                        size="sm"
                                        variant="warning"
                                        className="me-2"
                                        onClick={() => handleShowEdit(h)}
                                    >
                                        ✏️
                                    </Button>
                                    <Button
                                        size="sm"
                                        variant="danger"
                                        onClick={() => handleDelete(h.MaHK)}
                                    >
                                        🗑️
                                    </Button>
                                </td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td
                                colSpan="5"
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
                            {editData ? "✏️ Cập nhật học kỳ" : "➕ Thêm học kỳ"}
                        </Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Tên học kỳ</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.TenHK}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        TenHK: e.target.value,
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
                            <Form.Label>Ngày kết thúc</Form.Label>
                            <Form.Control
                                type="date"
                                value={formData.NgayKetThuc}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        NgayKetThuc: e.target.value,
                                    })
                                }
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
        </div>
    );
}
