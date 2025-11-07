import { Outlet, Link, useLocation } from "react-router-dom";
import { useAuth } from "../auth/useAuth";
import { Card } from "react-bootstrap";

export default function PDTLayout() {
    const { user, logout } = useAuth();
    const location = useLocation();

    const isRootDashboard =
        location.pathname === "/pdt" || location.pathname === "/pdt/";

    return (
        <div className="d-flex min-vh-100">
            {/* Sidebar */}
            <div
                className="bg-primary text-white p-3"
                style={{ width: "240px" }}
            >
                <h4 className="mb-4 text-center">🎓 PĐT</h4>
                <ul className="nav flex-column">
                    <li className="nav-item mb-2">
                        <Link to="/pdt" className="nav-link text-white">
                            Dashboard
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link to="/pdt/khoa" className="nav-link text-white">
                            Quản lý Khoa
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link to="/pdt/nganh" className="nav-link text-white">
                            Quản lý Ngành
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link to="/pdt/monhoc" className="nav-link text-white">
                            Quản lý Môn học
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/pdt/phonghoc"
                            className="nav-link text-white"
                        >
                            Quản lý phòng học
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link to="/pdt/hocky" className="nav-link text-white">
                            Quản lý học kỳ
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link to="/pdt/bomon" className="nav-link text-white">
                            Bộ môn
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/pdt/lop-hoc-phan"
                            className="nav-link text-white"
                        >
                            Lớp học phần
                        </Link>
                    </li>

                    <li className="nav-item mb-2">
                        <Link
                            to="/pdt/phancong"
                            className="nav-link text-white"
                        >
                            Phân công
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/pdt/sinh-lich"
                            className="nav-link text-white"
                        >
                            Sinh lịch
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link to="/pdt/yeucau" className="nav-link text-white">
                            Duyệt yêu cầu
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/pdt/thongbao"
                            className="nav-link text-white"
                        >
                            Thông báo
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link to="/pdt/thongke" className="nav-link text-white">
                            Thống kê
                        </Link>
                    </li>
                </ul>

                <button className="btn btn-danger w-100 mt-4" onClick={logout}>
                    Đăng xuất
                </button>
            </div>

            {/* Nội dung chính */}
            <div className="flex-grow-1 bg-light p-4">
                <div className="d-flex justify-content-between align-items-center mb-3">
                    <h5 className="fw-bold mb-0">
                        Xin chào, {user?.HoTen || "Cán bộ phòng đào tạo"} 👋
                    </h5>
                    <div className="text-end">
                        <div className="fw-semibold">{user?.HoTen}</div>
                        <div className="text-muted small">{user?.Email}</div>
                    </div>
                </div>

                {/* Nếu đang ở /pdt thì hiển thị dashboard mặc định */}
                {isRootDashboard ? (
                    <>
                        <h4 className="fw-bold text-primary mb-4">
                            📊 Hệ thống Quản lý Lịch giảng dạy
                        </h4>

                        <div className="row g-3">
                            <div className="col-md-3">
                                <Card className="border-primary shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-primary">50</h5>
                                        <small>Giảng viên</small>
                                    </Card.Body>
                                </Card>
                            </div>
                            <div className="col-md-3">
                                <Card className="border-success shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-success">18</h5>
                                        <small>Môn học</small>
                                    </Card.Body>
                                </Card>
                            </div>
                            <div className="col-md-3">
                                <Card className="border-warning shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-warning">60%</h5>
                                        <small>Tiến độ</small>
                                    </Card.Body>
                                </Card>
                            </div>
                            <div className="col-md-3">
                                <Card className="border-danger shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-danger">5</h5>
                                        <small>Yêu cầu chờ duyệt</small>
                                    </Card.Body>
                                </Card>
                            </div>
                        </div>
                    </>
                ) : (
                    <Outlet />
                )}
            </div>
        </div>
    );
}
