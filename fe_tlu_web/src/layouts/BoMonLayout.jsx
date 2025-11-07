import { Outlet, Link, useLocation } from "react-router-dom";
import { useAuth } from "../auth/useAuth";
import { Card } from "react-bootstrap";

export default function BoMonLayout() {
    const { user } = useAuth(); // ❌ Không cần logout ở đây
    const location = useLocation();

    const isRootDashboard =
        location.pathname === "/bomon" || location.pathname === "/bomon/";

    return (
        <div className="d-flex min-vh-100">
            {/* Sidebar */}
            <div
                className="bg-primary text-white p-3"
                style={{ width: "240px" }}
            >
                <h4 className="mb-4 text-center">🏫 Bộ Môn</h4>
                <ul className="nav flex-column">
                    <li className="nav-item mb-2">
                        <Link to="/bomon" className="nav-link text-white">
                            Dashboard
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/bomon/giang-vien"
                            className="nav-link text-white"
                        >
                            👨‍🏫 Giảng viên
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/bomon/lich-day"
                            className="nav-link text-white"
                        >
                            📅 Lịch dạy
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/bomon/tien-trinh"
                            className="nav-link text-white"
                        >
                            📘 Tiến trình
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/bomon/bao-cao"
                            className="nav-link text-white"
                        >
                            📊 Báo cáo
                        </Link>
                    </li>
                </ul>
            </div>

            {/* Nội dung chính */}
            <div className="flex-grow-1 bg-light p-4">
                <div className="d-flex justify-content-between align-items-center mb-3">
                    <h5 className="fw-bold mb-0">
                        Xin chào, {user?.HoTen || "Trưởng bộ môn"} 👋
                    </h5>
                    <div className="text-end">
                        <div className="fw-semibold">{user?.HoTen}</div>
                        <div className="text-muted small">{user?.Email}</div>
                    </div>
                </div>

                {/* Nếu đang ở /bomon thì hiển thị dashboard mặc định */}
                {isRootDashboard ? (
                    <>
                        <h4 className="fw-bold text-primary mb-4">
                            📋 Bảng điều khiển Bộ Môn
                        </h4>

                        <div className="row g-3">
                            <div className="col-md-4">
                                <Card className="border-primary shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-primary">12</h5>
                                        <small>Giảng viên trong bộ môn</small>
                                    </Card.Body>
                                </Card>
                            </div>
                            <div className="col-md-4">
                                <Card className="border-success shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-success">8</h5>
                                        <small>Lớp học phần đang dạy</small>
                                    </Card.Body>
                                </Card>
                            </div>
                            <div className="col-md-4">
                                <Card className="border-warning shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-warning">92%</h5>
                                        <small>Tỷ lệ tiến độ trung bình</small>
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
