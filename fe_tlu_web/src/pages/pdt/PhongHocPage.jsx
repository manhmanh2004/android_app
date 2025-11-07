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
import { phongHocService } from "../../api/services/pdt/phongHocService";

export default function PhongHocPage() {
    const [phongs, setPhongs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [editData, setEditData] = useState(null);
    const [formData, setFormData] = useState({
        TenPhong: "",
        SucChua: "",
        LoaiPhong: "",
    });

    // 🔍 Bộ lọc tìm kiếm + phân trang
    const [searchTerm, setSearchTerm] = useState("");
    const [filterLoai, setFilterLoai] = useState(""); // "", "LT", "TH"
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // 🧩 Lấy danh sách phòng học
    const fetchData = async () => {
        try {
            setLoading(true);
            const res = await phongHocService.getAll();
            const data = Array.isArray(res?.data)
                ? res.data
                : res.data?.data || [];
            setPhongs(Array.isArray(data) ? data : []);
        } catch (err) {
            console.error(err);
            setError("Không thể tải dữ liệu phòng học");
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
        setFormData({ TenPhong: "", SucChua: "", LoaiPhong: "" });
        setShowModal(true);
    };

    // 🟡 Sửa
    const handleShowEdit = (item) => {
        setEditData(item);
        setFormData({
            TenPhong: item.TenPhong,
            SucChua: item.SucChua,
            LoaiPhong: item.LoaiPhong,
        });
        setShowModal(true);
    };

    // 🔴 Xóa
    const handleDelete = async (id) => {
        if (!window.confirm("Bạn có chắc muốn xóa phòng học này?")) return;
        try {
            await phongHocService.delete(id);
            await fetchData();
        } catch (err) {
            alert(
                "Lỗi khi xóa: " + (err.response?.data?.message || err.message)
            );
        }
    };

    // 💾 Lưu (Thêm / Cập nhật)
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editData) {
                await phongHocService.update(editData.MaPhong, formData);
            } else {
                await phongHocService.create(formData);
            }
            await fetchData();
            setShowModal(false);
        } catch (err) {
            alert(
                "Lỗi khi lưu: " + (err.response?.data?.message || err.message)
            );
        }
    };

    // 🔍 Lọc danh sách theo từ khóa + loại phòng
    const filteredPhongs = phongs.filter((p) => {
        const search = searchTerm.toLowerCase();
        const matchText =
            p.TenPhong.toLowerCase().includes(search) ||
            p.SucChua.toString().includes(search);
        const matchLoai = filterLoai ? p.LoaiPhong === filterLoai : true;
        return matchText && matchLoai;
    });

    // 📄 Phân trang dữ liệu
    const totalPages = Math.ceil(filteredPhongs.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredPhongs.slice(
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
            <h4 className="fw-bold text-primary mb-4">🏫 Quản lý Phòng học</h4>
            {error && <Alert variant="danger">{error}</Alert>}

            {/* Thanh tìm kiếm + dropdown + nút thêm */}
            <div className="d-flex flex-wrap gap-2 justify-content-between align-items-center mb-3">
                <div className="d-flex flex-wrap gap-2">
                    <InputGroup style={{ maxWidth: 300 }}>
                        <Form.Control
                            type="text"
                            placeholder="🔍 Tìm theo tên hoặc sức chứa..."
                            value={searchTerm}
                            onChange={(e) => {
                                setSearchTerm(e.target.value);
                                setCurrentPage(1);
                            }}
                        />
                    </InputGroup>

                    <Form.Select
                        style={{ width: 180 }}
                        value={filterLoai}
                        onChange={(e) => {
                            setFilterLoai(e.target.value);
                            setCurrentPage(1);
                        }}
                    >
                        <option value="">📚 Tất cả loại phòng</option>
                        <option value="LT">LT - Lý thuyết</option>
                        <option value="TH">TH - Thực hành</option>
                    </Form.Select>
                </div>

                <Button variant="primary" onClick={handleShowAdd}>
                    ➕ Thêm phòng học
                </Button>
            </div>

            {/* Bảng dữ liệu */}
            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th style={{ width: "60px" }}>#</th>
                        <th>Tên phòng</th>
                        <th>Sức chứa</th>
                        <th>Loại phòng</th>
                        <th className="text-center" style={{ width: "150px" }}>
                            Hành động
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {paginatedData.length > 0 ? (
                        paginatedData.map((p, idx) => (
                            <tr key={p.MaPhong}>
                                <td>{startIndex + idx + 1}</td>
                                <td>{p.TenPhong}</td>
                                <td>{p.SucChua}</td>
                                <td>
                                    {p.LoaiPhong === "LT"
                                        ? "LT - Lý thuyết"
                                        : "TH - Thực hành"}
                                </td>
                                <td className="text-center">
                                    <Button
                                        size="sm"
                                        variant="warning"
                                        className="me-2"
                                        onClick={() => handleShowEdit(p)}
                                    >
                                        ✏️
                                    </Button>
                                    <Button
                                        size="sm"
                                        variant="danger"
                                        onClick={() => handleDelete(p.MaPhong)}
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
                            {editData
                                ? "✏️ Cập nhật phòng học"
                                : "➕ Thêm phòng học"}
                        </Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Tên phòng</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.TenPhong}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        TenPhong: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Sức chứa</Form.Label>
                            <Form.Control
                                type="number"
                                min="10"
                                value={formData.SucChua}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        SucChua: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Loại phòng</Form.Label>
                            <Form.Select
                                value={formData.LoaiPhong}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        LoaiPhong: e.target.value,
                                    })
                                }
                                required
                            >
                                <option value="">-- Chọn loại phòng --</option>
                                <option value="LT">LT - Lý thuyết</option>
                                <option value="TH">TH - Thực hành</option>
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
