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
import { boMonService } from "../../api/services/pdt/boMonService";
import { khoaService } from "../../api/services/pdt/khoaService";

export default function BoMonPage() {
    const [boMons, setBoMons] = useState([]);
    const [khoas, setKhoas] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [editData, setEditData] = useState(null);
    const [formData, setFormData] = useState({
        TenBoMon: "",
        MaKhoa: "",
    });

    // 🔍 Tìm kiếm + phân trang
    const [searchTerm, setSearchTerm] = useState("");
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // 🧩 Lấy dữ liệu bộ môn + khoa
    const fetchData = async () => {
        try {
            setLoading(true);
            const [bmRes, kRes] = await Promise.all([
                boMonService.getAll(),
                khoaService.getAll(),
            ]);
            const bmData = Array.isArray(bmRes?.data)
                ? bmRes.data
                : bmRes?.data?.data || bmRes || [];
            const khoaData = Array.isArray(kRes?.data)
                ? kRes.data
                : kRes?.data?.data || [];
            setBoMons(Array.isArray(bmData) ? bmData : []);
            setKhoas(Array.isArray(khoaData) ? khoaData : []);
        } catch (err) {
            console.error(err);
            setError("Không thể tải dữ liệu bộ môn / khoa");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    // 🟢 Thêm mới
    const handleShowAdd = () => {
        setEditData(null);
        setFormData({ TenBoMon: "", MaKhoa: "" });
        setShowModal(true);
    };

    // 🟡 Sửa
    const handleShowEdit = (bm) => {
        setEditData(bm);
        setFormData({
            TenBoMon: bm.TenBoMon,
            MaKhoa: bm.MaKhoa,
        });
        setShowModal(true);
    };

    // 🔴 Xóa
    const handleDelete = async (id) => {
        if (!window.confirm("Bạn có chắc muốn xóa bộ môn này?")) return;
        try {
            await boMonService.delete(id);
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
                await boMonService.update(editData.MaBoMon, formData);
            } else {
                await boMonService.create(formData);
            }
            await fetchData();
            setShowModal(false);
        } catch (err) {
            alert(
                "Lỗi khi lưu: " + (err.response?.data?.message || err.message)
            );
        }
    };

    // 🔍 Lọc theo tên bộ môn hoặc khoa
    const filteredBoMons = boMons.filter((bm) => {
        const s = searchTerm.toLowerCase();
        return (
            bm.TenBoMon?.toLowerCase().includes(s) ||
            bm.khoa?.TenKhoa?.toLowerCase().includes(s)
        );
    });

    // 📄 Phân trang
    const totalPages = Math.ceil(filteredBoMons.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredBoMons.slice(
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
                <p className="text-secondary mt-2">Đang tải dữ liệu...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-4">🏛️ Quản lý Bộ môn</h4>
            {error && <Alert variant="danger">{error}</Alert>}

            {/* Thanh tìm kiếm + nút thêm */}
            <div className="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <InputGroup style={{ maxWidth: 300 }}>
                    <Form.Control
                        type="text"
                        placeholder="🔍 Tìm theo tên bộ môn hoặc khoa..."
                        value={searchTerm}
                        onChange={(e) => {
                            setSearchTerm(e.target.value);
                            setCurrentPage(1);
                        }}
                    />
                </InputGroup>

                <Button variant="primary" onClick={handleShowAdd}>
                    ➕ Thêm Bộ môn
                </Button>
            </div>

            {/* Bảng dữ liệu */}
            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th style={{ width: "60px" }}>#</th>
                        <th>Tên Bộ môn</th>
                        <th>Thuộc Khoa</th>
                        <th className="text-center" style={{ width: "160px" }}>
                            Hành động
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {paginatedData.length > 0 ? (
                        paginatedData.map((bm, idx) => (
                            <tr key={bm.MaBoMon}>
                                <td>{startIndex + idx + 1}</td>
                                <td>{bm.TenBoMon}</td>
                                <td>{bm.khoa?.TenKhoa || "—"}</td>
                                <td className="text-center">
                                    <Button
                                        size="sm"
                                        variant="warning"
                                        className="me-2"
                                        onClick={() => handleShowEdit(bm)}
                                    >
                                        ✏️
                                    </Button>
                                    <Button
                                        size="sm"
                                        variant="danger"
                                        onClick={() => handleDelete(bm.MaBoMon)}
                                    >
                                        🗑️
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
                            {editData ? "✏️ Cập nhật Bộ môn" : "➕ Thêm Bộ môn"}
                        </Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Tên Bộ môn</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.TenBoMon}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        TenBoMon: e.target.value,
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
                                <option value="">-- Chọn Khoa --</option>
                                {khoas.map((k) => (
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
