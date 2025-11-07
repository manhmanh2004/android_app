import { createContext, useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";

export const AuthContext = createContext();

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    const [roles, setRoles] = useState([]);
    const navigate = useNavigate();

    // 🧠 Khi đăng nhập
    const login = (userData, rolesData, token) => {
        localStorage.setItem("user", JSON.stringify(userData));
        localStorage.setItem("roles", JSON.stringify(rolesData));
        localStorage.setItem("token", token);

        setUser(userData);
        setRoles(rolesData);
    };

    // 🚪 Khi đăng xuất
    const logout = () => {
        localStorage.clear();
        setUser(null);
        setRoles([]);
        navigate("/"); // ✅ quay về trang đăng nhập
    };

    // ♻️ Giữ trạng thái khi F5
    useEffect(() => {
        try {
            const storedUser = localStorage.getItem("user");
            const storedRoles = localStorage.getItem("roles");

            if (storedUser) setUser(JSON.parse(storedUser));
            if (storedRoles) setRoles(JSON.parse(storedRoles));
        } catch (err) {
            console.error("⚠️ Lỗi khi đọc dữ liệu đăng nhập:", err);
            localStorage.clear();
            setUser(null);
            setRoles([]);
        }
    }, []);

    return (
        <AuthContext.Provider value={{ user, roles, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
}
