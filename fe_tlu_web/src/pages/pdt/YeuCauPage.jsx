import { useState, useEffect } from "react";
import { Button, Table, Modal } from "react-bootstrap";
import { yeuCauService } from "../../api/services/pdt/yeuCauService";

export default function YeuCauPage() {
    const [yeuCaus, setYeuCaus] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selected, setSelected] = useState(null);
    const [showDetail, setShowDetail] = useState(false);

    // 📦 Load danh sách yêu cầu
    const loadData = async () => {
        setLoading(true);
        try {
            const res = await yeuCauService.getAll();
            setYeuCaus(res.data?.data || []);
        } catch (err) {
            console.error("❌ Lỗi tải danh sách yêu cầu:", err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadData();
    }, []);

    // ✅ Duyệt hoặc từ chối yêu cầu
    const handleUpdate = async (maYeuCau, trangThai) => {
        if (
            !window.confirm(
                `Bạn có chắc muốn ${
                    trangThai === "Duyet" ? "duyệt" : "từ chối"
                } yêu cầu này?`
            )
        )
            return;
        try {
            await yeuCauService.update(maYeuCau, { TrangThai: trangThai });
            await loadData();
            setShowDetail(false);
        } catch (err) {
            alert("❌ Lỗi khi cập nhật trạng thái!");
            console.error(err);
        }
    };

    const openDetail = (item) => {
        setSelected(item);
        setShowDetail(true);
    };

    const closeDetail = () => {
        setSelected(null);
        setShowDetail(false);
    };

    return (
        <div className="container mt-3">
            <div className="d-flex justify-content-between align-items-center mb-3">
                <h4>📋 Danh sách yêu cầu thay đổi lịch</h4>
            </div>

            {loading ? (
                <p>Đang tải dữ liệu...</p>
            ) : (
                <Table bordered hover responsive>
                    <thead>
                        <tr className="table-primary text-center">
                            <th>#</th>
                            <th>Giảng viên</th>
                            <th>Môn học</th>
                            <th>Lớp HP</th>
                            <th>Ngày học gốc</th>
                            <th>Ca học</th>
                            <th>Loại yêu cầu</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        {yeuCaus.length > 0 ? (
                            yeuCaus.map((item, idx) => (
                                <tr key={item.MaYeuCau}>
                                    <td className="text-center">{idx + 1}</td>
                                    <td>{item.TenGiangVien}</td>
                                    <td>{item.TenMonHoc}</td>
                                    <td>{item.TenLHP}</td>
                                    <td className="text-center">
                                        {item.NgayHocGoc}
                                    </td>
                                    <td className="text-center">
                                        {item.CaHocGoc}
                                    </td>
                                    <td className="text-center">
                                        {item.LoaiYeuCau === "Nghi"
                                            ? "⛔ Nghỉ dạy"
                                            : "📘 Dạy bù"}
                                    </td>
                                    <td className="text-center">
                                        {item.TrangThai === "ChoDuyet" ? (
                                            <span className="badge bg-warning text-dark">
                                                Chờ duyệt
                                            </span>
                                        ) : item.TrangThai === "Duyet" ? (
                                            <span className="badge bg-success">
                                                Đã duyệt
                                            </span>
                                        ) : (
                                            <span className="badge bg-danger">
                                                Từ chối
                                            </span>
                                        )}
                                    </td>
                                    <td className="text-center">
                                        <Button
                                            size="sm"
                                            variant="info"
                                            className="me-2"
                                            onClick={() => openDetail(item)}
                                        >
                                            👁️ Chi tiết
                                        </Button>

                                        {item.TrangThai === "ChoDuyet" && (
                                            <>
                                                <Button
                                                    size="sm"
                                                    variant="success"
                                                    className="me-2"
                                                    onClick={() =>
                                                        handleUpdate(
                                                            item.MaYeuCau,
                                                            "Duyet"
                                                        )
                                                    }
                                                >
                                                    ✅
                                                </Button>
                                                <Button
                                                    size="sm"
                                                    variant="danger"
                                                    onClick={() =>
                                                        handleUpdate(
                                                            item.MaYeuCau,
                                                            "TuChoi"
                                                        )
                                                    }
                                                >
                                                    ❌
                                                </Button>
                                            </>
                                        )}
                                    </td>
                                </tr>
                            ))
                        ) : (
                            <tr>
                                <td
                                    colSpan="9"
                                    className="text-center text-muted py-3"
                                >
                                    Không có yêu cầu nào
                                </td>
                            </tr>
                        )}
                    </tbody>
                </Table>
            )}

            {/* 🔍 Modal Chi tiết */}
            <Modal show={showDetail} onHide={closeDetail} centered>
                <Modal.Header closeButton>
                    <Modal.Title>📝 Chi tiết yêu cầu</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    {selected && (
                        <div>
                            <p>
                                <strong>👨‍🏫 Giảng viên:</strong>{" "}
                                {selected.TenGiangVien}
                            </p>
                            <p>
                                <strong>📚 Môn học:</strong>{" "}
                                {selected.TenMonHoc}
                            </p>
                            <p>
                                <strong>🏷️ Lớp học phần:</strong>{" "}
                                {selected.TenLHP}
                            </p>
                            <hr />
                            <p>
                                <strong>🗓️ Ngày học gốc:</strong>{" "}
                                {selected.NgayHocGoc}
                            </p>
                            <p>
                                <strong>🕐 Ca học gốc:</strong>{" "}
                                {selected.CaHocGoc}
                            </p>
                            <p>
                                <strong>📖 Nội dung giảng dạy:</strong>{" "}
                                {selected.NoiDungGiangDay}
                            </p>
                            <hr />
                            <p>
                                <strong>🧾 Loại yêu cầu:</strong>{" "}
                                {selected.LoaiYeuCau === "Nghi"
                                    ? "⛔ Nghỉ dạy"
                                    : "📘 Dạy bù"}
                            </p>
                            {selected.LoaiYeuCau === "DayBu" && (
                                <>
                                    <p>
                                        <strong>📅 Ngày đề nghị bù:</strong>{" "}
                                        {selected.NgayDeNghiBu}
                                    </p>
                                    <p>
                                        <strong>🕘 Ca đề nghị bù:</strong>{" "}
                                        {selected.CaDeNghiBu}
                                    </p>
                                    <p>
                                        <strong>🏫 Phòng đề nghị:</strong>{" "}
                                        {selected.PhongDeNghi || "—"}
                                    </p>
                                </>
                            )}
                            <p>
                                <strong>🗒️ Lý do:</strong> {selected.LyDo}
                            </p>
                            <p>
                                <strong>📌 Trạng thái:</strong>{" "}
                                {selected.TrangThai}
                            </p>
                        </div>
                    )}
                </Modal.Body>
                <Modal.Footer>
                    {selected?.TrangThai === "ChoDuyet" ? (
                        <>
                            <Button
                                variant="success"
                                onClick={() =>
                                    handleUpdate(selected.MaYeuCau, "Duyet")
                                }
                            >
                                ✅ Duyệt
                            </Button>
                            <Button
                                variant="danger"
                                onClick={() =>
                                    handleUpdate(selected.MaYeuCau, "TuChoi")
                                }
                            >
                                ❌ Từ chối
                            </Button>
                        </>
                    ) : (
                        <Button variant="secondary" onClick={closeDetail}>
                            Đóng
                        </Button>
                    )}
                </Modal.Footer>
            </Modal>
        </div>
    );
}
