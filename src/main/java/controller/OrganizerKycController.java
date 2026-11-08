package controller;

import dao.OrganizerProfileDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.OrganizerDocument;
import model.User;
import utils.Constants;
import utils.CsrfUtils;
import utils.PrivateDocuments;
import utils.ValidationUtils;

/**
 * UC-34 (KYC): Admin xem hồ sơ & tài liệu pháp lý của Organizer, duyệt/từ chối từng tài liệu
 * và chuyển Organizer_Profiles.verification_status sang VERIFIED / REJECTED.
 *
 * GET  /admin/organizer-kyc?userId=              : trang hồ sơ KYC
 * GET  /admin/organizer-kyc/document?userId=&id= : xem file tài liệu
 * POST /admin/organizer-kyc                      : action=approveDoc|rejectDoc (documentId) | verify | reject
 */
@WebServlet(urlPatterns = {"/admin/organizer-kyc", "/admin/organizer-kyc/document"})
public class OrganizerKycController extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/organizer-kyc.jsp";

    private final OrganizerProfileDAO profileDAO = new OrganizerProfileDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User organizer = loadOrganizer(request);
            if (organizer == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Organizer not found");
                return;
            }
            if (request.getServletPath().endsWith("/document")) {
                int documentId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), -1);
                OrganizerDocument document = documentId > 0
                        ? profileDAO.getDocument(documentId, organizer.getUserId()) : null;
                if (document == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                PrivateDocuments.serve(response, document.getFileName());
                return;
            }
            Object flash = request.getSession().getAttribute("kycMessage");
            if (flash != null) {
                request.getSession().removeAttribute("kycMessage");
                request.setAttribute("message", flash);
            }
            request.setAttribute("organizer", organizer);
            request.setAttribute("hasProfile", profileDAO.hasProfileRow(organizer.getUserId()));
            request.setAttribute("profile", profileDAO.getProfile(organizer.getUserId()));
            request.setAttribute("documents", profileDAO.getDocuments(organizer.getUserId()));
            request.setAttribute("hasApprovedLicense", profileDAO.hasApprovedBusinessLicense(organizer.getUserId()));
            CsrfUtils.expose(request);
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Cannot load organizer KYC", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            User organizer = loadOrganizer(request);
            if (organizer == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Organizer not found");
                return;
            }
            int userId = organizer.getUserId();
            String action = request.getParameter("action");
            String message;
            switch (action == null ? "" : action) {
                case "approveDoc", "rejectDoc" -> {
                    int documentId = ValidationUtils.parseIntOrDefault(request.getParameter("documentId"), -1);
                    boolean ok = documentId > 0 && profileDAO.setDocumentStatus(documentId, userId,
                            "approveDoc".equals(action) ? Constants.DOC_APPROVED : "REJECTED");
                    message = ok ? "Đã cập nhật trạng thái tài liệu." : "Không tìm thấy tài liệu.";
                }
                case "verify" -> {
                    if (!profileDAO.hasProfileRow(userId)) {
                        message = "Organizer chưa tạo hồ sơ tổ chức nên chưa thể xác minh.";
                    } else if (!profileDAO.hasApprovedBusinessLicense(userId)) {
                        message = "Phải duyệt Giấy phép kinh doanh trước khi xác minh tổ chức.";
                    } else {
                        profileDAO.setVerificationStatus(userId, Constants.PROFILE_VERIFIED);
                        message = "Đã xác minh tổ chức (VERIFIED).";
                    }
                }
                case "reject" -> {
                    message = profileDAO.setVerificationStatus(userId, "REJECTED")
                            ? "Đã từ chối xác minh tổ chức (REJECTED)."
                            : "Organizer chưa tạo hồ sơ tổ chức.";
                }
                default -> {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }
            request.getSession().setAttribute("kycMessage", message);
            response.sendRedirect(request.getContextPath() + "/admin/organizer-kyc?userId=" + userId);
        } catch (SQLException e) {
            throw new ServletException("Cannot update organizer KYC", e);
        }
    }

    private User loadOrganizer(HttpServletRequest request) throws SQLException {
        int userId = ValidationUtils.parseIntOrDefault(request.getParameter("userId"), -1);
        User user = userId > 0 ? userDAO.getUserById(userId) : null;
        return user != null && Constants.ROLE_ORGANIZER.equalsIgnoreCase(user.getRole()) ? user : null;
    }
}
