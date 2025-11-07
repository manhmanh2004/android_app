import { Outlet, Link, useLocation } from "react-router-dom";
import { useAuth } from "../auth/useAuth";
import { Card } from "react-bootstrap";

export default function AdminLayout() {
    const { user, logout } = useAuth();
    const location = useLocation();

    const isRootDashboard =
        location.pathname === "/admin" || location.pathname === "/admin/";

    return (
        <div className="d-flex min-vh-100">
            {/* Sidebar */}
            <div className="bg-dark text-white p-3" style={{ width: "240px" }}>
                <h4 className="mb-4 text-center">🛠️ Quản trị viên</h4>
                <ul className="nav flex-column">
                    <li className="nav-item mb-2">
                        <Link to="/admin" className="nav-link text-white">
                            Dashboard
                        </Link>
                    </li>
                    <li className="nav-item mb-2">
                        <Link
                            to="/admin/tai-khoan"
                            className="nav-link text-white"
                        >
                            👤 Quản lý tài khoản
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
                        Xin chào, {user?.HoTen || "Quản trị viên"} 👋
                    </h5>
                    <div className="text-end">
                        <div className="fw-semibold">{user?.HoTen}</div>
                        <div className="text-muted small">{user?.Email}</div>
                    </div>
                </div>

                {/* Nếu đang ở /admin thì hiển thị dashboard mặc định */}
                {isRootDashboard ? (
                    <>
                        <h4 className="fw-bold text-primary mb-4">
                            📊 Bảng điều khiển quản trị
                        </h4>

                        <div className="row g-3">
                            <div className="col-md-4">
                                <Card className="border-primary shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-primary">128</h5>
                                        <small>Tài khoản người dùng</small>
                                    </Card.Body>
                                </Card>
                            </div>
                            <div className="col-md-4">
                                <Card className="border-success shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-success">4</h5>
                                        <small>Vai trò hệ thống</small>
                                    </Card.Body>
                                </Card>
                            </div>
                            <div className="col-md-4">
                                <Card className="border-warning shadow-sm">
                                    <Card.Body className="text-center">
                                        <h5 className="text-warning">12</h5>
                                        <small>Phân quyền tùy chỉnh</small>
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
