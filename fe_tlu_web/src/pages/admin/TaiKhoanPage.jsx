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
import { taiKhoanService } from "../../api/services/admin/taiKhoanService";
import { boMonService } from "../../api/services/admin/boMonService";

export default function TaiKhoanPage() {
    const [users, setUsers] = useState([]);
    const [roles, setRoles] = useState([]);
    const [boMons, setBoMons] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [editData, setEditData] = useState(null);
    const [formData, setFormData] = useState({
        HoTen: "",
        Email: "",
        TenDangNhap: "",
        MatKhau: "",
        VaiTro: "",
        MaBoMon: "",
        MaLopHanhChinh: "",
        NamNhapHoc: "",
    });

    // Bộ lọc & tìm kiếm
    const [searchTerm, setSearchTerm] = useState("");
    const [roleFilter, setRoleFilter] = useState("");
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // 🧠 Lấy dữ liệu từ API
    const fetchData = async () => {
        try {
            setLoading(true);
            const [userRes, roleRes, boMonRes] = await Promise.all([
                taiKhoanService.getAll(),
                taiKhoanService.getRoles(),
                boMonService.getAll(),
            ]);
            console.log(boMonRes);
            setUsers(userRes.data?.data || []);
            setRoles(roleRes.data?.data || []);
            setBoMons(boMonRes.data || []);
        } catch (err) {
            console.error("❌ Lỗi tải dữ liệu:", err);
            setError("Không thể tải danh sách tài khoản");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    // ➕ Hiển thị modal thêm
    const handleShowAdd = () => {
        setEditData(null);
        setFormData({
            HoTen: "",
            Email: "",
            TenDangNhap: "",
            MatKhau: "",
            VaiTro: "",
            MaBoMon: "",
            MaLopHanhChinh: "",
            NamNhapHoc: "",
        });
        setShowModal(true);
    };

    // ✏️ Hiển thị modal sửa
    const handleShowEdit = (item) => {
        setEditData(item);
        setFormData({
            HoTen: item.HoTen,
            Email: item.Email,
            TenDangNhap: item.TenDangNhap,
            MatKhau: "",
            VaiTro: item.vai_tros?.[0]?.TenVaiTro || "",
            MaBoMon: item.MaBoMon || "",
            MaLopHanhChinh: item.MaLopHanhChinh || "",
            NamNhapHoc: item.NamNhapHoc || "",
        });
        setShowModal(true);
    };

    // 🗑️ Xóa tài khoản
    const handleDelete = async (id) => {
        if (!window.confirm("Bạn có chắc muốn xóa tài khoản này?")) return;
        try {
            await taiKhoanService.delete(id);
            await fetchData();
        } catch (err) {
            alert(
                "Lỗi khi xóa: " + (err.response?.data?.message || err.message)
            );
        }
    };

    // 💾 Lưu tài khoản
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editData) {
                await taiKhoanService.update(editData.MaND, formData);
            } else {
                await taiKhoanService.create(formData);
            }
            setShowModal(false);
            await fetchData();
        } catch (err) {
            alert(
                "Lỗi khi lưu: " + (err.response?.data?.message || err.message)
            );
        }
    };

    // 🔍 Tìm kiếm + lọc vai trò
    const filteredUsers = users.filter((u) => {
        const matchSearch =
            u.HoTen?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            u.Email?.toLowerCase().includes(searchTerm.toLowerCase());
        const matchRole =
            !roleFilter || u.vai_tros?.some((v) => v.TenVaiTro === roleFilter);
        return matchSearch && matchRole;
    });

    // 📄 Phân trang
    const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredUsers.slice(
        startIndex,
        startIndex + itemsPerPage
    );

    if (loading)
        return (
            <div className="text-center mt-5">
                <Spinner animation="border" variant="primary" />
                <p className="text-secondary mt-2">Đang tải dữ liệu...</p>
            </div>
        );

    return (
        <div>
            <h4 className="fw-bold text-primary mb-4">👤 Quản lý tài khoản</h4>
            {error && <Alert variant="danger">{error}</Alert>}

            {/* Bộ lọc & tìm kiếm */}
            <div className="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
                <InputGroup style={{ maxWidth: 250 }}>
                    <Form.Control
                        type="text"
                        placeholder="🔍 Tìm theo tên hoặc email"
                        value={searchTerm}
                        onChange={(e) => {
                            setSearchTerm(e.target.value);
                            setCurrentPage(1);
                        }}
                    />
                </InputGroup>

                <Form.Select
                    style={{ maxWidth: 200 }}
                    value={roleFilter}
                    onChange={(e) => {
                        setRoleFilter(e.target.value);
                        setCurrentPage(1);
                    }}
                >
                    <option value="">-- Lọc theo vai trò --</option>
                    {roles.map((r) => (
                        <option key={r.MaVaiTro} value={r.TenVaiTro}>
                            {r.TenVaiTro}
                        </option>
                    ))}
                </Form.Select>

                <Button variant="primary" onClick={handleShowAdd}>
                    ➕ Thêm tài khoản
                </Button>
            </div>

            {/* Bảng tài khoản */}
            <Table bordered hover responsive className="bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th>#</th>
                        <th>Họ tên</th>
                        <th>Email</th>
                        <th>Tên đăng nhập</th>
                        <th>Vai trò</th>
                        <th className="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    {paginatedData.length > 0 ? (
                        paginatedData.map((u, i) => (
                            <tr key={u.MaND}>
                                <td>{startIndex + i + 1}</td>
                                <td>{u.HoTen}</td>
                                <td>{u.Email}</td>
                                <td>{u.TenDangNhap}</td>
                                <td>
                                    {u.vai_tros
                                        ?.map((v) => v.TenVaiTro)
                                        .join(", ") || "—"}
                                </td>
                                <td className="text-center">
                                    <Button
                                        size="sm"
                                        variant="warning"
                                        className="me-2"
                                        onClick={() => handleShowEdit(u)}
                                    >
                                        ✏️
                                    </Button>
                                    <Button
                                        size="sm"
                                        variant="danger"
                                        onClick={() => handleDelete(u.MaND)}
                                    >
                                        🗑️
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
                                Không có tài khoản phù hợp
                            </td>
                        </tr>
                    )}
                </tbody>
            </Table>

            {/* Phân trang */}
            {totalPages > 1 && (
                <div className="d-flex justify-content-center align-items-center gap-2 mt-3">
                    <Button
                        size="sm"
                        variant="outline-primary"
                        disabled={currentPage === 1}
                        onClick={() => setCurrentPage(currentPage - 1)}
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
                        onClick={() => setCurrentPage(currentPage + 1)}
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
                                ? "✏️ Cập nhật tài khoản"
                                : "➕ Thêm tài khoản"}
                        </Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3">
                            <Form.Label>Họ tên</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.HoTen}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        HoTen: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Email</Form.Label>
                            <Form.Control
                                type="email"
                                value={formData.Email}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        Email: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Tên đăng nhập</Form.Label>
                            <Form.Control
                                type="text"
                                value={formData.TenDangNhap}
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        TenDangNhap: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        {!editData && (
                            <Form.Group className="mb-3">
                                <Form.Label>Mật khẩu</Form.Label>
                                <Form.Control
                                    type="password"
                                    value={formData.MatKhau}
                                    onChange={(e) =>
                                        setFormData({
                                            ...formData,
                                            MatKhau: e.target.value,
                                        })
                                    }
                                    required
                                />
                            </Form.Group>
                        )}

                        <Form.Group className="mb-3">
                            <Form.Label>Vai trò</Form.Label>
                            <Form.Select
                                value={formData.VaiTro}
                                onChange={(e) => {
                                    const value = e.target.value;
                                    setFormData({
                                        ...formData,
                                        VaiTro: value,
                                        MaBoMon: "",
                                        MaLopHanhChinh: "",
                                        NamNhapHoc: "",
                                    });
                                }}
                                required
                            >
                                <option value="">-- Chọn vai trò --</option>
                                {roles.map((r) => (
                                    <option
                                        key={r.MaVaiTro}
                                        value={r.TenVaiTro}
                                    >
                                        {r.TenVaiTro}
                                    </option>
                                ))}
                            </Form.Select>
                        </Form.Group>

                        {/* Nếu là Giảng viên */}
                        {/* Nếu là Giảng viên */}
                        {formData.VaiTro === "GiangVien" && (
                            <Form.Group className="mb-3" key={formData.VaiTro}>
                                <Form.Label>Bộ môn</Form.Label>
                                <Form.Select
                                    value={formData.MaBoMon}
                                    onChange={(e) =>
                                        setFormData({
                                            ...formData,
                                            MaBoMon: e.target.value,
                                        })
                                    }
                                    required
                                >
                                    <option value="">-- Chọn bộ môn --</option>
                                    {Array.isArray(boMons) &&
                                        boMons.map((bm) => (
                                            <option
                                                key={bm.MaBoMon}
                                                value={bm.MaBoMon}
                                            >
                                                {bm.TenBoMon}
                                            </option>
                                        ))}
                                </Form.Select>
                            </Form.Group>
                        )}

                        {/* Nếu là Sinh viên */}
                        {formData.VaiTro === "SinhVien" && (
                            <>
                                <Form.Group className="mb-3">
                                    <Form.Label>Lớp hành chính</Form.Label>
                                    <Form.Control
                                        type="text"
                                        value={formData.MaLopHanhChinh}
                                        onChange={(e) =>
                                            setFormData({
                                                ...formData,
                                                MaLopHanhChinh: e.target.value,
                                            })
                                        }
                                        required
                                    />
                                </Form.Group>

                                <Form.Group className="mb-3">
                                    <Form.Label>Năm nhập học</Form.Label>
                                    <Form.Control
                                        type="number"
                                        value={formData.NamNhapHoc}
                                        onChange={(e) =>
                                            setFormData({
                                                ...formData,
                                                NamNhapHoc: e.target.value,
                                            })
                                        }
                                        required
                                    />
                                </Form.Group>
                            </>
                        )}
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
