import { useEffect, useState } from "react";
import { lopHocPhanService } from "../../api/services/pdt/lopHocPhanService";
import { giangVienService } from "../../api/services/pdt/giangVienService";
import { phanCongService } from "../../api/services/pdt/phanCongService";
import { hocKyService } from "../../api/services/pdt/hocKyService";
import { Form, Button, InputGroup, Spinner } from "react-bootstrap";

export default function PhanCongPage() {
    const [lhps, setLhps] = useState([]);
    const [gvs, setGvs] = useState([]);
    const [hocKys, setHocKys] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [selectedLHP, setSelectedLHP] = useState(null);
    const [selectedGV, setSelectedGV] = useState("");

    // 🔍 Tìm kiếm & lọc
    const [searchKeyword, setSearchKeyword] = useState("");
    const [selectedHK, setSelectedHK] = useState("");

    // 📄 Phân trang
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    // Chuẩn hóa dữ liệu lớp học phần
    const mapLHP = (item) => {
        const list = Array.isArray(item.giang_viens) ? item.giang_viens : [];
        const first = list[0] || null;
        const gvId = first?.MaGV || null;
        const gvName = first?.nguoi_dung?.HoTen || first?.HoTen || null;
        return {
            ...item,
            _assignedGVId: gvId,
            _assignedGVName: gvName,
            _hasAssigned: !!gvId,
        };
    };

    useEffect(() => {
        const fetchData = async () => {
            try {
                setLoading(true);
                const [lhpRes, gvRes, hkRes] = await Promise.all([
                    lopHocPhanService.getAllWithGiangVien(),
                    giangVienService.getAll(),
                    hocKyService.getAll(),
                ]);

                const lhpData = lhpRes?.data?.data || [];
                const gvData = gvRes?.data || [];
                const hkData = hkRes?.data?.data || hkRes?.data || [];

                setLhps(lhpData.map(mapLHP));
                setGvs(Array.isArray(gvData) ? gvData : []);
                setHocKys(Array.isArray(hkData) ? hkData : []);
            } catch (err) {
                console.error(err);
                setError(
                    "Không thể tải dữ liệu lớp học phần, giảng viên hoặc học kỳ"
                );
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    const handleOpenModal = (lhp) => {
        setSelectedLHP(lhp);
        setSelectedGV(lhp._assignedGVId || "");
        setShowModal(true);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            await phanCongService.assign({
                MaLHP: selectedLHP.MaLHP,
                MaGV: Number(selectedGV),
            });
            setShowModal(false);

            const lhpRes = await lopHocPhanService.getAllWithGiangVien();
            const lhpData = lhpRes?.data?.data || [];
            setLhps(lhpData.map(mapLHP));
        } catch (err) {
            console.error(err);
            alert(
                "❌ Lỗi khi phân công: " +
                    (err.response?.data?.message || err.message)
            );
        }
    };

    // 🔍 Lọc theo từ khóa + học kỳ
    const filteredLhps = lhps.filter((l) => {
        const keyword = searchKeyword.toLowerCase();
        const matchKeyword =
            l.TenLHP?.toLowerCase().includes(keyword) ||
            l.mon_hoc?.TenMonHoc?.toLowerCase().includes(keyword);
        const matchHK = selectedHK
            ? l.hoc_ky?.MaHK === Number(selectedHK)
            : true;
        return matchKeyword && matchHK;
    });

    // 📄 Phân trang
    const totalPages = Math.ceil(filteredLhps.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedData = filteredLhps.slice(
        startIndex,
        startIndex + itemsPerPage
    );

    const handlePageChange = (page) => {
        if (page >= 1 && page <= totalPages) setCurrentPage(page);
    };

    if (loading)
        return (
            <div className="p-4 text-center">
                <Spinner animation="border" />
                <p className="text-muted mt-2">Đang tải dữ liệu...</p>
            </div>
        );

    if (error)
        return (
            <div className="alert alert-danger m-3 text-center">{error}</div>
        );

    return (
        <div className="container py-4">
            <h4 className="fw-bold text-primary mb-4">
                📘 Quản lý Phân công Giảng viên
            </h4>

            {/* Bộ lọc tìm kiếm */}
            <div className="d-flex flex-wrap gap-2 mb-3 align-items-center">
                <InputGroup style={{ width: "300px" }}>
                    <Form.Control
                        placeholder="🔍 Tìm theo tên lớp hoặc môn học..."
                        value={searchKeyword}
                        onChange={(e) => {
                            setSearchKeyword(e.target.value);
                            setCurrentPage(1);
                        }}
                    />
                </InputGroup>

                <Form.Select
                    style={{ width: "220px" }}
                    value={selectedHK}
                    onChange={(e) => {
                        setSelectedHK(e.target.value);
                        setCurrentPage(1);
                    }}
                >
                    <option value="">-- Tất cả học kỳ --</option>
                    {hocKys.map((hk) => (
                        <option key={hk.MaHK} value={hk.MaHK}>
                            {hk.TenHK}
                        </option>
                    ))}
                </Form.Select>
            </div>

            {/* Bảng danh sách */}
            <table className="table table-bordered align-middle bg-white shadow-sm">
                <thead className="table-primary">
                    <tr>
                        <th>Mã LHP</th>
                        <th>Tên lớp học phần</th>
                        <th>Môn học</th>
                        <th>Học kỳ</th>
                        <th>Trạng thái phân công</th>
                        <th className="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    {paginatedData.length > 0 ? (
                        paginatedData.map((lhp) => (
                            <tr key={lhp.MaLHP}>
                                <td>{lhp.MaLHP}</td>
                                <td>{lhp.TenLHP}</td>
                                <td>{lhp.mon_hoc?.TenMonHoc || "—"}</td>
                                <td>{lhp.hoc_ky?.TenHK || "—"}</td>
                                <td>
                                    {lhp._hasAssigned ? (
                                        <span className="badge bg-success">
                                            {lhp._assignedGVName ||
                                                "Đã phân công"}
                                        </span>
                                    ) : (
                                        <span className="badge bg-secondary">
                                            Chưa phân công
                                        </span>
                                    )}
                                </td>
                                <td className="text-center">
                                    <button
                                        className="btn btn-sm btn-primary"
                                        onClick={() => handleOpenModal(lhp)}
                                    >
                                        {lhp._hasAssigned
                                            ? "Đổi giảng viên"
                                            : "Phân công"}
                                    </button>
                                </td>
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td
                                colSpan="6"
                                className="text-center text-muted py-3"
                            >
                                Không có lớp học phần nào.
                            </td>
                        </tr>
                    )}
                </tbody>
            </table>

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

            {/* 🪟 Modal chọn giảng viên */}
            {showModal && (
                <div
                    className="modal fade show"
                    style={{ display: "block", backgroundColor: "#00000080" }}
                >
                    <div className="modal-dialog">
                        <div className="modal-content">
                            <div className="modal-header">
                                <h5 className="modal-title">
                                    Phân công giảng viên
                                </h5>
                                <button
                                    className="btn-close"
                                    onClick={() => setShowModal(false)}
                                ></button>
                            </div>
                            <form onSubmit={handleSubmit}>
                                <div className="modal-body">
                                    <p>
                                        <b>Lớp học phần:</b>{" "}
                                        {selectedLHP?.TenLHP}
                                    </p>
                                    <div className="mb-3">
                                        <label className="form-label">
                                            Chọn giảng viên
                                        </label>
                                        <select
                                            className="form-select"
                                            value={selectedGV}
                                            onChange={(e) =>
                                                setSelectedGV(e.target.value)
                                            }
                                            required
                                        >
                                            <option value="">
                                                -- Chọn giảng viên --
                                            </option>
                                            {gvs.map((gv) => (
                                                <option
                                                    key={gv.MaGV}
                                                    value={gv.MaGV}
                                                >
                                                    {gv.nguoi_dung?.HoTen ||
                                                        gv.HoTen ||
                                                        `GV #${gv.MaGV}`}
                                                </option>
                                            ))}
                                        </select>
                                    </div>
                                </div>
                                <div className="modal-footer">
                                    <button
                                        type="button"
                                        className="btn btn-secondary"
                                        onClick={() => setShowModal(false)}
                                    >
                                        Hủy
                                    </button>
                                    <button
                                        type="submit"
                                        className="btn btn-primary"
                                    >
                                        Lưu phân công
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
