import { useEffect, useState } from "react";
import {
    Button,
    Table,
    Modal,
    Form,
    InputGroup,
    Row,
    Col,
} from "react-bootstrap";
import { thongBaoService } from "../../api/services/pdt/thongBaoService";

export default function ThongBaoPage() {
    const [thongBaos, setThongBaos] = useState([]);
    const [filtered, setFiltered] = useState([]);
    const [loading, setLoading] = useState(true);

    const [search, setSearch] = useState("");
    const [filterDoiTuong, setFilterDoiTuong] = useState("TatCa");
    const [dateFrom, setDateFrom] = useState("");

    const [showForm, setShowForm] = useState(false);
    const [showDetail, setShowDetail] = useState(false);
    const [showRecipients, setShowRecipients] = useState(false);

    const [selected, setSelected] = useState(null);
    const [filteredRecipients, setFilteredRecipients] = useState([]);

    const [recipientSearch, setRecipientSearch] = useState("");
    const [recipientRole, setRecipientRole] = useState("TatCa");
    const [recipientStatus, setRecipientStatus] = useState("TatCa");

    const [form, setForm] = useState({
        TieuDe: "",
        NoiDung: "",
        DoiTuong: "TatCa",
    });

    // 📦 Load danh sách thông báo
    const loadData = async () => {
        setLoading(true);
        try {
            const res = await thongBaoService.getAll();
            const data = res?.data?.data || [];
            setThongBaos(data);
            setFiltered(data);
        } catch (err) {
            console.error("❌ Lỗi tải danh sách thông báo:", err);
            setThongBaos([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadData();
    }, []);

    // 🔍 Lọc danh sách thông báo
    useEffect(() => {
        let result = thongBaos;

        const keyword = search.trim().toLowerCase();
        if (keyword) {
            result = result.filter(
                (tb) =>
                    tb.TieuDe.toLowerCase().includes(keyword) ||
                    tb.NoiDung.toLowerCase().includes(keyword)
            );
        }

        if (filterDoiTuong !== "TatCa") {
            result = result.filter((tb) => tb.DoiTuong === filterDoiTuong);
        }

        if (dateFrom) {
            const chosenDate = new Date(dateFrom);
            result = result.filter((tb) => {
                const date = new Date(tb.ThoiGianGui);
                return (
                    date.getFullYear() === chosenDate.getFullYear() &&
                    date.getMonth() === chosenDate.getMonth() &&
                    date.getDate() === chosenDate.getDate()
                );
            });
        }

        setFiltered(result);
    }, [search, filterDoiTuong, dateFrom, thongBaos]);

    // ➕ Thêm / ✏️ Sửa
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (selected) {
                await thongBaoService.update(selected.MaThongBao, {
                    TieuDe: form.TieuDe,
                    NoiDung: form.NoiDung,
                });
            } else {
                await thongBaoService.create(form);
            }

            await loadData();
            handleCloseForm();
        } catch (err) {
            alert("❌ Lỗi khi lưu thông báo!");
            console.error(err);
        }
    };

    // ❌ Xóa
    const handleDelete = async (id) => {
        if (window.confirm("Bạn có chắc muốn xóa thông báo này?")) {
            try {
                await thongBaoService.delete(id);
                await loadData();
            } catch (err) {
                alert("❌ Lỗi khi xóa!");
                console.error(err);
            }
        }
    };

    // 👁 Xem chi tiết
    const handleViewDetail = async (id) => {
        try {
            setSelected(null);
            const res = await thongBaoService.getById(id);
            setSelected(res.data);
            setShowDetail(true);
        } catch (err) {
            console.error("❌ Lỗi khi tải chi tiết:", err);
            alert("Không tải được chi tiết thông báo!");
        }
    };

    // 🧭 Danh sách người nhận
    const handleViewRecipients = () => {
        setShowRecipients(true);
        setShowDetail(false);
        setFilteredRecipients(selected?.NguoiNhans || []);
    };

    const handleBackToDetail = () => {
        setShowRecipients(false);
        setShowDetail(true);
    };

    // 🔍 Lọc người nhận
    useEffect(() => {
        let result = selected?.NguoiNhans || [];

        if (recipientSearch.trim()) {
            const keyword = recipientSearch.trim().toLowerCase();
            result = result.filter(
                (r) =>
                    r.HoTen.toLowerCase().includes(keyword) ||
                    r.Email.toLowerCase().includes(keyword)
            );
        }

        if (recipientRole !== "TatCa") {
            result = result.filter((r) => r.VaiTros.includes(recipientRole));
        }

        if (recipientStatus === "DaDoc") {
            result = result.filter((r) => r.TrangThaiDoc === 1);
        } else if (recipientStatus === "ChuaDoc") {
            result = result.filter((r) => r.TrangThaiDoc === 0);
        }

        setFilteredRecipients(result);
    }, [recipientSearch, recipientRole, recipientStatus, selected]);

    // Đóng form
    const handleCloseForm = () => {
        setShowForm(false);
        setForm({ TieuDe: "", NoiDung: "", DoiTuong: "TatCa" });
        setSelected(null);
    };

    const handleCloseDetail = () => {
        setShowDetail(false);
        setSelected(null);
    };

    return (
        <div className="container mt-3">
            <div className="d-flex justify-content-between align-items-center mb-3">
                <h4>📢 Quản lý Thông báo</h4>
                <Button onClick={() => setShowForm(true)}>
                    + Tạo thông báo
                </Button>
            </div>

            {/* 🔍 Thanh tìm kiếm */}
            <Row className="mb-3 g-2">
                <Col md={6}>
                    <InputGroup>
                        <Form.Control
                            placeholder="🔍 Tìm theo tiêu đề hoặc nội dung..."
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                        />
                    </InputGroup>
                </Col>

                <Col md={3}>
                    <Form.Select
                        value={filterDoiTuong}
                        onChange={(e) => setFilterDoiTuong(e.target.value)}
                    >
                        <option value="TatCa">🎯 Tất cả đối tượng</option>
                        <option value="GiangVien">Giảng viên</option>
                        <option value="SinhVien">Sinh viên</option>
                        <option value="BoMon">Bộ môn</option>
                    </Form.Select>
                </Col>

                <Col md={3}>
                    <InputGroup>
                        <InputGroup.Text>📅</InputGroup.Text>
                        <Form.Control
                            type="date"
                            value={dateFrom}
                            onChange={(e) => setDateFrom(e.target.value)}
                            title="Tìm theo ngày gửi"
                        />
                    </InputGroup>
                </Col>
            </Row>

            {/* 📋 Danh sách thông báo */}
            {loading ? (
                <p>Đang tải dữ liệu...</p>
            ) : (
                <Table bordered hover responsive>
                    <thead>
                        <tr className="table-primary">
                            <th>#</th>
                            <th>Tiêu đề</th>
                            <th>Đối tượng</th>
                            <th>Thời gian gửi</th>
                            <th className="text-center">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        {filtered.length > 0 ? (
                            filtered.map((item, idx) => (
                                <tr key={item.MaThongBao}>
                                    <td>{idx + 1}</td>
                                    <td>{item.TieuDe}</td>
                                    <td>{item.DoiTuong}</td>
                                    <td>
                                        {new Date(
                                            item.ThoiGianGui
                                        ).toLocaleString()}
                                    </td>
                                    <td className="text-center">
                                        <Button
                                            size="sm"
                                            variant="info"
                                            className="me-2"
                                            onClick={() =>
                                                handleViewDetail(
                                                    item.MaThongBao
                                                )
                                            }
                                        >
                                            👁 Xem
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="warning"
                                            className="me-2"
                                            onClick={() => {
                                                setSelected(item);
                                                setForm({
                                                    TieuDe: item.TieuDe,
                                                    NoiDung: item.NoiDung,
                                                    DoiTuong:
                                                        item.DoiTuong ||
                                                        "TatCa",
                                                });
                                                setShowForm(true);
                                            }}
                                        >
                                            ✏️ Sửa
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="danger"
                                            onClick={() =>
                                                handleDelete(item.MaThongBao)
                                            }
                                        >
                                            🗑️ Xóa
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
                                    Không có thông báo nào
                                </td>
                            </tr>
                        )}
                    </tbody>
                </Table>
            )}

            {/* 🪄 Modal thêm / sửa */}
            <Modal show={showForm} onHide={handleCloseForm}>
                <Modal.Header closeButton>
                    <Modal.Title>
                        {selected ? "✏️ Cập nhật" : "➕ Tạo mới"} Thông báo
                    </Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Form onSubmit={handleSubmit}>
                        <Form.Group className="mb-3">
                            <Form.Label>Tiêu đề</Form.Label>
                            <Form.Control
                                type="text"
                                value={form.TieuDe}
                                onChange={(e) =>
                                    setForm({ ...form, TieuDe: e.target.value })
                                }
                                required
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Nội dung</Form.Label>
                            <Form.Control
                                as="textarea"
                                rows={4}
                                value={form.NoiDung}
                                onChange={(e) =>
                                    setForm({
                                        ...form,
                                        NoiDung: e.target.value,
                                    })
                                }
                                required
                            />
                        </Form.Group>

                        {!selected && (
                            <Form.Group className="mb-3">
                                <Form.Label>Gửi đến</Form.Label>
                                <Form.Select
                                    value={form.DoiTuong}
                                    onChange={(e) =>
                                        setForm({
                                            ...form,
                                            DoiTuong: e.target.value,
                                        })
                                    }
                                >
                                    <option value="TatCa">Tất cả</option>
                                    <option value="GiangVien">
                                        Giảng viên
                                    </option>
                                    <option value="SinhVien">Sinh viên</option>
                                    <option value="BoMon">Bộ môn</option>
                                </Form.Select>
                            </Form.Group>
                        )}

                        <div className="text-end">
                            <Button
                                variant="secondary"
                                onClick={handleCloseForm}
                            >
                                Hủy
                            </Button>
                            <Button
                                variant="primary"
                                type="submit"
                                className="ms-2"
                            >
                                Lưu
                            </Button>
                        </div>
                    </Form>
                </Modal.Body>
            </Modal>

            {/* 👁 Modal xem chi tiết */}
            <Modal show={showDetail} onHide={handleCloseDetail} size="lg">
                <Modal.Header closeButton>
                    <Modal.Title>📜 Chi tiết Thông báo</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    {selected?.ThongBao ? (
                        <>
                            <p>
                                <strong>Tiêu đề:</strong>{" "}
                                {selected.ThongBao.TieuDe}
                            </p>
                            <p>
                                <strong>Đối tượng:</strong>{" "}
                                {selected.ThongBao.DoiTuong}
                            </p>
                            <p>
                                <strong>Người gửi:</strong>{" "}
                                {selected.ThongBao.NguoiGui}
                            </p>
                            <p>
                                <strong>Thời gian gửi:</strong>{" "}
                                {new Date(
                                    selected.ThongBao.ThoiGianGui
                                ).toLocaleString()}
                            </p>
                            <p>
                                <strong>Nội dung:</strong>
                            </p>
                            <div className="border rounded p-2 bg-light mb-3">
                                {selected.ThongBao.NoiDung}
                            </div>

                            <div className="d-flex justify-content-between align-items-center">
                                <h6>
                                    📨 Thống kê người nhận{" "}
                                    <span className="text-muted ms-2">
                                        (Đã đọc: {selected.ThongKe.DaDoc}/
                                        {selected.ThongKe.Tong})
                                    </span>
                                </h6>
                                <Button
                                    size="sm"
                                    variant="outline-primary"
                                    onClick={handleViewRecipients}
                                >
                                    👥 Xem danh sách người nhận
                                </Button>
                            </div>
                        </>
                    ) : (
                        <p className="text-center text-muted py-3">
                            ⏳ Đang tải dữ liệu...
                        </p>
                    )}
                </Modal.Body>
                <Modal.Footer>
                    <Button variant="secondary" onClick={handleCloseDetail}>
                        Đóng
                    </Button>
                </Modal.Footer>
            </Modal>

            {/* 👥 Modal danh sách người nhận */}
            <Modal show={showRecipients} onHide={handleBackToDetail} size="lg">
                <Modal.Header closeButton>
                    <Modal.Title>👥 Danh sách người nhận</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Row className="mb-3 g-2">
                        <Col md={4}>
                            <InputGroup>
                                <Form.Control
                                    placeholder="🔍 Tìm theo tên hoặc email..."
                                    value={recipientSearch}
                                    onChange={(e) =>
                                        setRecipientSearch(e.target.value)
                                    }
                                />
                            </InputGroup>
                        </Col>
                        <Col md={4}>
                            <Form.Select
                                value={recipientRole}
                                onChange={(e) =>
                                    setRecipientRole(e.target.value)
                                }
                            >
                                <option value="TatCa">🎯 Tất cả vai trò</option>
                                <option value="Giảng viên">Giảng viên</option>
                                <option value="Sinh viên">Sinh viên</option>
                                <option value="Bộ môn">Bộ môn</option>
                            </Form.Select>
                        </Col>
                        <Col md={4}>
                            <Form.Select
                                value={recipientStatus}
                                onChange={(e) =>
                                    setRecipientStatus(e.target.value)
                                }
                            >
                                <option value="TatCa">
                                    📋 Tất cả trạng thái
                                </option>
                                <option value="DaDoc">✅ Đã đọc</option>
                                <option value="ChuaDoc">📩 Chưa đọc</option>
                            </Form.Select>
                        </Col>
                    </Row>

                    <Table bordered hover responsive size="sm">
                        <thead className="table-light">
                            <tr>
                                <th>#</th>
                                <th>Họ tên</th>
                                <th>Email</th>
                                <th>Vai trò</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filteredRecipients.length > 0 ? (
                                filteredRecipients.map((r, i) => (
                                    <tr key={r.MaND}>
                                        <td>{i + 1}</td>
                                        <td>{r.HoTen}</td>
                                        <td>{r.Email}</td>
                                        <td>{r.VaiTros}</td>
                                        <td>{r.TrangThaiDocLabel}</td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td
                                        colSpan="5"
                                        className="text-center text-muted py-3"
                                    >
                                        Không có người nhận nào phù hợp
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </Table>
                </Modal.Body>
                <Modal.Footer>
                    <Button variant="secondary" onClick={handleBackToDetail}>
                        ⬅️ Quay lại chi tiết
                    </Button>
                </Modal.Footer>
            </Modal>
        </div>
    );
}
