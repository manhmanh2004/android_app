import { Navigate } from "react-router-dom";
import { useAuth } from "./useAuth";

export const ProtectedRoute = ({ children }) => {
    const { user } = useAuth();

    if (!user) {
        console.warn("🔒 Chưa đăng nhập, chuyển hướng về login...");
        return <Navigate to="/" replace />;
    }

    return children;
};
