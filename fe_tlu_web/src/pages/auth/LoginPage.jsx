import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { AuthService } from "../../api/services/authService";
import "../../styles/App.css"; // ✅ import CSS chung

export default function LoginPage() {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        setError("");

        try {
            const { roles } = await AuthService.login(username, password);
            const role = roles[0]; // => "PhongDaoTao"

            console.log("🧩 Vai trò:", role);

            // Chuẩn hóa để điều hướng đúng trang
            if (role === "PhongDaoTao" || role === "PDT") navigate("/pdt");
            else if (role === "Admin") navigate("/admin");
            else if (role === "BoMon") navigate("/bomon");
            else if (role === "GiangVien") navigate("/giangvien");
            else if (role === "SinhVien") navigate("/sinhvien");
            else setError("Không xác định được vai trò người dùng!");
        } catch (err) {
            setError(err.response?.data?.message || "Đăng nhập thất bại");
        }
    };

    return (
        <div className="login-wrapper">
            <div className="login-card">
                <div className="text-center mb-3">
                    <div
                        className="rounded-circle d-inline-flex justify-content-center align-items-center bg-primary text-white"
                        style={{
                            width: 60,
                            height: 60,
                            fontSize: 26,
                            fontWeight: "600",
                        }}
                    >
                        QL
                    </div>
                    <h4 className="mt-3 mb-1 fw-bold">Đăng nhập hệ thống</h4>
                    <p className="text-muted mb-4">Quản lý Lịch giảng dạy</p>
                </div>

                {error && <div className="alert alert-danger">{error}</div>}

                <form onSubmit={handleLogin}>
                    <div className="mb-3">
                        <input
                            type="text"
                            placeholder="Tên đăng nhập hoặc Email"
                            className="form-control"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <input
                            type="password"
                            placeholder="Mật khẩu"
                            className="form-control"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                        />
                    </div>

                    <div className="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <input
                                type="checkbox"
                                id="remember"
                                className="me-1"
                            />
                            <label
                                htmlFor="remember"
                                className="text-secondary small"
                            >
                                Ghi nhớ
                            </label>
                        </div>
                        <a href="#" className="text-primary small">
                            Quên mật khẩu?
                        </a>
                    </div>

                    <button className="btn btn-primary w-100" type="submit">
                        Đăng nhập
                    </button>
                </form>

                <p className="text-center text-muted mt-4 mb-0 small">
                    © 2025 Lịch giảng TLU
                </p>
            </div>
        </div>
    );
}
