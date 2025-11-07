import { Navigate } from "react-router-dom";
import { useAuth } from "./useAuth";

export const RoleGuard = ({ allowedRoles, children }) => {
    const { roles } = useAuth();

    const hasAccess = roles?.some((r) => allowedRoles.includes(r));
    if (!hasAccess) {
        alert("❌ Bạn không có quyền truy cập vào khu vực này!");
        return <Navigate to="/" replace />;
    }

    return children;
};
