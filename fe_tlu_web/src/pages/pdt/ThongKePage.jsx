import { useEffect, useState } from "react";
import {
    Table,
    Form,
    Button,
    Row,
    Col,
    InputGroup,
    Modal,
    ProgressBar,
} from "react-bootstrap";
import { thongKeService } from "../../api/services/pdt/thongKeService";
import { hocKyService } from "../../api/services/pdt/hocKyService";
import { khoaService } from "../../api/services/pdt/khoaService";
import { nganhService } from "../../api/services/pdt/nganhService";
import { apiClient } from "../../api/apiClient";

export default function ThongKePage() {
    const [thongKes, setThongKes] = useState([]);
    const [hocKys, setHocKys] = useState([]);
    const [khoas, setKhoas] = useState([]);
    const [nganhs, setNganhs] = useState([]);

    const [hocKy, setHocKy] = useState(0);
    const [khoa, setKhoa] = useState(0);
    const [nganh, setNganh] = useState(0);
    const [giangVien, setGiangVien] = useState("");
    const [tenMH, setTenMH] = useState("");

    const [loading, setLoading] = useState(true);

    // Modal chi tiết
    const [showDetail, setShowDetail] = useState(false);
    const [loadingDetail, setLoadingDetail] = useState(false);
    const [chiTietInfo, setChiTietInfo] = useState(null);
    const [chiTietBuoiHoc, setChiTietBuoiHoc] = useState([]);

    // 🚀 Load danh mục học kỳ / khoa / ngành
    const loadDanhMuc = async () => {
        try {
            const [hkRes, khoaRes, nganhRes] = await Promise.all([
                hocKyService.getAll(),
                khoaService.getAll(),
                nganhService.getAll(),
            ]);
            setHocKys(hkRes?.data?.data || hkRes?.data || []);
            setKhoas(khoaRes?.data?.data || khoaRes?.data || []);
            setNganhs(nganhRes?.data?.data || nganhRes?.data || []);
        } catch (err) {
            console.error("❌ Lỗi tải danh mục:", err);
        }
    };

    // 📊 Load thống kê
    const loadThongKe = async (filters = {}) => {
        setLoading(true);
        try {
            const res = await thongKeService.getTienDoHocPhan(filters);
            setThongKes(res?.data?.data || []);
        } catch (err) {
            console.error("❌ Lỗi tải thống kê:", err);
            setThongKes([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadDanhMuc();
        loadThongKe();
    }, []);

    // 🔄 Khi chọn học kỳ, khoa, ngành, giảng viên, môn học thì load lại
    useEffect(() => {
        loadThongKe({
            hocKy,
            khoa,
            nganh,
            giangVien,
            tenMH,
        });
    }, [hocKy, khoa, nganh, giangVien, tenMH]);

    // 🧹 Reset bộ lọc
    const handleReset = () => {
        setHocKy(0);
        setKhoa(0);
        setNganh(0);
        setGiangVien("");
        setTenMH("");
    };

    const onChangeKhoa = (e) => {
        const val = Number(e.target.value || 0);
        setKhoa(val);
        setNganh(0); // reset ngành khi đổi khoa
    };

    // 👁 Xem chi tiết tiến độ lớp học phần
    const handleViewDetail = async (maLHP) => {
        setShowDetail(true);
        setLoadingDetail(true);
        setChiTietInfo(null);
        setChiTietBuoiHoc([]);

        try {
            const res = await apiClient.get(`/pdt/tien-do/lhp/${maLHP}`);
            setChiTietInfo(res.data?.ThongTin || null);
            setChiTietBuoiHoc(res.data?.BuoiHoc || []);
        } catch (err) {
            console.error("❌ Lỗi tải chi tiết lớp học phần:", err);
        } finally {
            setLoadingDetail(false);
        }
    };

    const getProgressVariant = (percent) => {
        if (percent >= 100) return "success";
        if (percent >= 50) return "info";
        if (percent > 0) return "warning";
        return "secondary";
    };

    return (
        <div className="container mt-3">
            <h4 className="mb-3">📊 Thống kê tiến độ giảng dạy</h4>

            {/* 🎯 Bộ lọc */}
            <Row className="g-2 mb-3">
                <Col md={3}>
                    <Form.Select
                        value={hocKy}
                        onChange={(e) => setHocKy(Number(e.target.value || 0))}
                    >
                        <option value={0}>📅 Chọn học kỳ</option>
                        {hocKys.map((hk) => (
                            <option key={hk.MaHK} value={hk.MaHK}>
                                {hk.TenHK}
                            </option>
                        ))}
                    </Form.Select>
                </Col>

                <Col md={3}>
                    <Form.Select value={khoa} onChange={onChangeKhoa}>
                        <option value={0}>🏫 Chọn khoa</option>
                        {khoas.map((k) => (
                            <option key={k.MaKhoa} value={k.MaKhoa}>
                                {k.TenKhoa}
                            </option>
                        ))}
                    </Form.Select>
                </Col>

                <Col md={3}>
                    <Form.Select
                        value={nganh}
                        onChange={(e) => setNganh(Number(e.target.value || 0))}
                        disabled={!khoa}
                    >
                        <option value={0}>📘 Chọn ngành</option>
                        {nganhs
                            .filter((n) => !khoa || n.MaKhoa === khoa)
                            .map((n) => (
                                <option key={n.MaNganh} value={n.MaNganh}>
                                    {n.TenNganh}
                                </option>
                            ))}
                    </Form.Select>
                </Col>

                <Col md={3}>
                    <InputGroup>
                        <Form.Control
                            placeholder="👨‍🏫 Tìm theo giảng viên..."
                            value={giangVien}
                            onChange={(e) => setGiangVien(e.target.value)}
                        />
                    </InputGroup>
                </Col>

                <Col md={3}>
                    <InputGroup>
                        <Form.Control
                            placeholder="📖 Tìm theo tên học phần..."
                            value={tenMH}
                            onChange={(e) => setTenMH(e.target.value)}
                        />
                    </InputGroup>
                </Col>

                <Col md="auto">
                    <Button variant="secondary" onClick={handleReset}>
                        🔄 Làm mới
                    </Button>
                </Col>
            </Row>

            {/* 📋 Bảng thống kê */}
            {loading ? (
                <p>⏳ Đang tải dữ liệu...</p>
            ) : (
                <Table bordered hover responsive>
                    <thead className="table-primary">
                        <tr>
                            <th>#</th>
                            <th>Tên học phần</th>
                            <th>Môn học</th>
                            <th>Học kỳ</th>
                            <th>Giảng viên</th>
                            <th>Tổng buổi</th>
                            <th>Đã dạy</th>
                            <th>Tỷ lệ hoàn thành</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        {thongKes.length > 0 ? (
                            thongKes.map((item, idx) => (
                                <tr key={item.MaLHP}>
                                    <td>{idx + 1}</td>
                                    <td>{item.TenLHP}</td>
                                    <td>{item.TenMH}</td>
                                    <td>{item.TenHK}</td>
                                    <td>{item.GiangVien}</td>
                                    <td>{item.TongBuoi}</td>
                                    <td>{item.DaDay}</td>
                                    <td style={{ minWidth: "150px" }}>
                                        <ProgressBar
                                            now={item.TiLeHoanThanh}
                                            label={`${item.TiLeHoanThanh}%`}
                                            variant={getProgressVariant(
                                                item.TiLeHoanThanh
                                            )}
                                        />
                                    </td>
                                    <td>{item.TrangThai}</td>
                                    <td className="text-center">
                                        <Button
                                            size="sm"
                                            variant="outline-primary"
                                            onClick={() =>
                                                handleViewDetail(item.MaLHP)
                                            }
                                        >
                                            👁 Xem
                                        </Button>
                                    </td>
                                </tr>
                            ))
                        ) : (
                            <tr>
                                <td
                                    colSpan="10"
                                    className="text-center text-muted py-3"
                                >
                                    Không có dữ liệu thống kê
                                </td>
                            </tr>
                        )}
                    </tbody>
                </Table>
            )}

            {/* 🪄 Modal xem chi tiết */}
            <Modal
                show={showDetail}
                onHide={() => setShowDetail(false)}
                size="lg"
            >
                <Modal.Header closeButton>
                    <Modal.Title>📘 Chi tiết tiến độ lớp học phần</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    {loadingDetail ? (
                        <p>⏳ Đang tải chi tiết...</p>
                    ) : chiTietInfo ? (
                        <>
                            <div className="mb-3 border-bottom pb-2">
                                <h5 className="text-primary fw-bold mb-2">
                                    {chiTietInfo.TenLHP}
                                </h5>
                                <p>
                                    <strong>Môn học:</strong>{" "}
                                    {chiTietInfo.TenMonHoc}
                                </p>
                                <p>
                                    <strong>Học kỳ:</strong> {chiTietInfo.HocKy}
                                </p>
                                <p>
                                    <strong>Giảng viên:</strong>{" "}
                                    {chiTietInfo.GiangVien}
                                </p>
                                <ProgressBar
                                    now={chiTietInfo.TiLeHoanThanh}
                                    variant={getProgressVariant(
                                        chiTietInfo.TiLeHoanThanh
                                    )}
                                    label={`${chiTietInfo.TiLeHoanThanh}%`}
                                    className="mt-2"
                                />
                            </div>

                            <Table bordered hover responsive>
                                <thead className="table-light">
                                    <tr>
                                        <th>#</th>
                                        <th>Ngày học</th>
                                        <th>Ca học</th>
                                        <th>Phòng</th>
                                        <th>Trạng thái</th>
                                        <th>Nội dung giảng dạy</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {chiTietBuoiHoc.length > 0 ? (
                                        chiTietBuoiHoc.map((b, idx) => (
                                            <tr key={b.MaBuoiHoc}>
                                                <td>{idx + 1}</td>
                                                <td>
                                                    {new Date(
                                                        b.NgayHoc
                                                    ).toLocaleDateString(
                                                        "vi-VN"
                                                    )}
                                                </td>
                                                <td>{b.CaHoc}</td>
                                                <td>{b.Phong || "—"}</td>
                                                <td>{b.TrangThaiHienThi}</td>
                                                <td>
                                                    {b.NoiDungGiangDay || "—"}
                                                </td>
                                            </tr>
                                        ))
                                    ) : (
                                        <tr>
                                            <td
                                                colSpan="6"
                                                className="text-center text-muted py-3"
                                            >
                                                Không có buổi học nào.
                                            </td>
                                        </tr>
                                    )}
                                </tbody>
                            </Table>
                        </>
                    ) : (
                        <p className="text-muted text-center py-3">
                            Không tìm thấy dữ liệu chi tiết
                        </p>
                    )}
                </Modal.Body>
                <Modal.Footer>
                    <Button
                        variant="secondary"
                        onClick={() => setShowDetail(false)}
                    >
                        Đóng
                    </Button>
                </Modal.Footer>
            </Modal>
        </div>
    );
}
