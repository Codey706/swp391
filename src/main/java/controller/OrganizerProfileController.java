package controller;

import dao.CategoryDAO;
import dao.EventDAO;
import dao.OrganizerProfileDAO;
import dao.UserDAO;
import model.Auth;
import model.Category;
import model.OrganizerDocument;
import model.OrganizerProfile;
import model.User;
import utils.Constants;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * UC-20: Manage My Organizer Profile. GET /organizer/profile : xem hồ sơ của
 * chính Organizer đang đăng nhập. POST /organizer/profile : cập nhật hồ sơ
 * (multipart: có ảnh logo/ảnh bìa/tài liệu pháp lý). GET
 * /organizer/profile/document : xem tài liệu pháp lý của chính mình (?id=).
 *
 * Organizer ID luôn lấy từ session, không nhận từ browser. Không cho sửa role,
 * status, password và các cột do Admin quản lý (KYC, trạng thái xác minh, hạn
 * mức).
 */
@WebServlet(name = "OrganizerProfileController", urlPatterns = {"/organizer/profile", "/organizer/profile/document"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 16 * 1024 * 1024)
public class OrganizerProfileController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrganizerProfileController.class.getName());

    private static final String PROFILE_VIEW = "/WEB-INF/views/organizer/profile.jsp";
    private static final String PATH_PROFILE = "/organizer/profile";
    private static final String PATH_LOGIN = "/Auth?action=login";

    // Mã lỗi SQL Server khi vi phạm UNIQUE constraint / unique index
    private static final int SQL_ERROR_UNIQUE_CONSTRAINT = 2627;
    private static final int SQL_ERROR_UNIQUE_INDEX = 2601;

    private static final String ERROR_GENERIC = "Hệ thống đang gặp sự cố. Vui lòng thử lại sau.";
    private static final String ERROR_CHECK_FIELDS = "Vui lòng kiểm tra lại các thông tin được đánh dấu.";

    private static final List<String> IMAGE_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "webp");
    private static final List<String> DOCUMENT_EXTENSIONS = Arrays.asList("pdf", "jpg", "jpeg", "png");
    private static final List<String> DOCUMENT_TYPES
            = Arrays.asList("BUSINESS_LICENSE", "PERFORMANCE_PERMIT", "COPYRIGHT_CONTRACT", "OTHER");
    private static final List<String> REQUIRED_DOCUMENT_TYPES
            = Arrays.asList("BUSINESS_LICENSE", "PERFORMANCE_PERMIT", "COPYRIGHT_CONTRACT");

    private final UserDAO userDAO = new UserDAO();
    private final EventDAO eventDAO = new EventDAO();
    private final OrganizerProfileDAO profileDAO = new OrganizerProfileDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final SecureRandom secureRandom = new SecureRandom();

    // ------------------------------------------------------------------ GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User organizer = loadAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }

        if (request.getServletPath().endsWith("/document")) {
            serveDocument(request, response, organizer);
            return;
        }

        moveFlashMessage(request);
        try {
            OrganizerProfile saved = profileDAO.getProfile(organizer.getUserId());
            Set<Integer> selected = profileDAO.getCategoryIds(organizer.getUserId());
            showProfile(request, response, organizer, organizer, saved, saved, selected, new LinkedHashMap<>());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load organizer profile, userId=" + organizer.getUserId(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
        }
    }

    // ------------------------------------------------------------------ POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User organizer = loadAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }

        OrganizerProfile saved;
        Set<Integer> savedCategoryIds;
        List<Category> activeCategories;
        try {
            saved = profileDAO.getProfile(organizer.getUserId());
            savedCategoryIds = profileDAO.getCategoryIds(organizer.getUserId());
            activeCategories = loadActiveCategories();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load organizer profile, userId=" + organizer.getUserId(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
            return;
        }

        // Đọc form multipart; vượt giới hạn dung lượng thì container ném IllegalStateException
        String csrf;
        try {
            csrf = request.getParameter("csrfToken");
        } catch (IllegalStateException e) {
            request.setAttribute("errorMessage", "Tổng dung lượng tệp tải lên vượt quá giới hạn (mỗi tệp tối đa 5MB).");
            showProfile(request, response, organizer, organizer, saved, saved, savedCategoryIds, new LinkedHashMap<>());
            return;
        }
        if (!isValidCsrfToken(request, csrf)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        User submitted = buildSubmittedUser(request, organizer.getUserId());
        OrganizerProfile submittedProfile = buildSubmittedProfile(request, organizer.getUserId(), saved);
        Set<Integer> submittedCategoryIds = readCategoryIds(request);
        String docType = trimToEmpty(request.getParameter("docType"));

        Part logoPart = getPartSafely(request, "logo");
        Part coverPart = getPartSafely(request, "cover");
        Part documentPart = getPartSafely(request, "document");

        Map<String, String> errors = validate(submitted, submittedProfile, submittedCategoryIds,
                activeCategories, logoPart, coverPart, documentPart, docType, saved);

        if (!errors.isEmpty()) {
            request.setAttribute("errorMessage", errors.containsKey("system") ? ERROR_GENERIC : ERROR_CHECK_FIELDS);
            showProfile(request, response, organizer, submitted, saved, submittedProfile, submittedCategoryIds, errors);
            return;
        }

        // Lưu tệp trước khi ghi database; lỗi ở bước sau thì xóa các tệp vừa lưu
        String newLogo = null;
        String newCover = null;
        String newDocumentFile = null;
        try {
            if (hasFile(logoPart)) {
                newLogo = saveImage(logoPart, organizer.getUserId(), "logo");
                submittedProfile.setLogoUrl(newLogo);
            } else {
                submittedProfile.setLogoUrl(null);   // null = giữ ảnh cũ
            }
            if (hasFile(coverPart)) {
                newCover = saveImage(coverPart, organizer.getUserId(), "cover");
                submittedProfile.setCoverUrl(newCover);
            } else {
                submittedProfile.setCoverUrl(null);
            }
            if (hasFile(documentPart)) {
                newDocumentFile = saveDocument(documentPart, organizer.getUserId());
            }
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Cannot store uploaded files, userId=" + organizer.getUserId(), e);
            deleteQuietly(newLogo, newCover, newDocumentFile);
            restoreForm(submittedProfile, saved);
            request.setAttribute("errorMessage", "Không thể lưu tệp tải lên. Vui lòng thử lại sau.");
            showProfile(request, response, organizer, submitted, saved, submittedProfile, submittedCategoryIds, errors);
            return;
        }

        try {
            if (!profileDAO.saveProfile(submitted, submittedProfile, submittedCategoryIds)) {
                deleteQuietly(newLogo, newCover, newDocumentFile);
                restoreForm(submittedProfile, saved);
                request.setAttribute("errorMessage", "Không thể cập nhật hồ sơ. Tài khoản của bạn có thể không còn hoạt động.");
                showProfile(request, response, organizer, submitted, saved, submittedProfile, submittedCategoryIds, errors);
                return;
            }
        } catch (SQLException e) {
            deleteQuietly(newLogo, newCover, newDocumentFile);
            restoreForm(submittedProfile, saved);
            if (isDuplicateKeyError(e)) {
                // Có người khác vừa dùng giá trị này giữa lúc kiểm tra và lúc lưu
                if (e.getMessage() != null && e.getMessage().contains("tax_code")) {
                    errors.put("taxCode", "Mã số thuế đã được sử dụng bởi tổ chức khác.");
                } else {
                    errors.put("email", "Email hoặc số điện thoại đã được sử dụng bởi tài khoản khác.");
                }
                request.setAttribute("errorMessage", ERROR_CHECK_FIELDS);
            } else {
                LOGGER.log(Level.SEVERE, "Cannot update organizer profile, userId=" + organizer.getUserId(), e);
                request.setAttribute("errorMessage", ERROR_GENERIC);
            }
            showProfile(request, response, organizer, submitted, saved, submittedProfile, submittedCategoryIds, errors);
            return;
        }

        String successMessage = "Cập nhật hồ sơ thành công.";
        if (newDocumentFile != null) {
            OrganizerDocument document = new OrganizerDocument();
            document.setUserId(organizer.getUserId());
            document.setDocType(DOCUMENT_TYPES.contains(docType) ? docType : "OTHER");
            document.setDocName(truncate(safeFileName(documentPart.getSubmittedFileName()),
                    Constants.PROFILE_DOC_NAME_MAX_LENGTH));
            document.setFileName(newDocumentFile);
            try {
                profileDAO.insertDocument(document);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Cannot save organizer document, userId=" + organizer.getUserId(), e);
                deleteQuietly(null, null, newDocumentFile);
                successMessage = "Hồ sơ đã được lưu, nhưng không thể lưu tài liệu pháp lý. Vui lòng tải lên lại.";
            }
        }

        // Dọn ảnh cũ chỉ khi đã thay ảnh mới thành công
        if (newLogo != null) {
            deleteOldImage(saved.getLogoUrl(), organizer.getUserId());
        }
        if (newCover != null) {
            deleteOldImage(saved.getCoverUrl(), organizer.getUserId());
        }

        refreshSessionUser(request, submitted);

        // Post/Redirect/Get: tránh gửi lại form khi người dùng F5
        request.getSession().setAttribute(Constants.SESSION_ORGANIZER_PROFILE_SUCCESS, successMessage);
        response.sendRedirect(request.getContextPath() + PATH_PROFILE);
    }

    // ------------------------------------------------------------------ Xác thực / phân quyền
    /**
     * Yêu cầu đã đăng nhập, đúng role Organizer và tài khoản còn ACTIVE. Dữ
     * liệu luôn được đọc lại từ database bằng userId trong session.
     *
     * @return hồ sơ Organizer từ database, hoặc null nếu đã redirect/gửi lỗi.
     */
    private User loadAuthenticatedOrganizer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(Constants.SESSION_USER);

        if (!(sessionUser instanceof Auth)) {
            response.sendRedirect(request.getContextPath() + PATH_LOGIN);
            return null;
        }

        Auth authUser = (Auth) sessionUser;
        if (!Constants.ROLE_ORGANIZER.equalsIgnoreCase(authUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        try {
            User organizer = userDAO.getUserById(authUser.getUserId());
            if (organizer == null
                    || !Constants.ROLE_ORGANIZER.equalsIgnoreCase(organizer.getRole())
                    || !Constants.STATUS_ACTIVE.equalsIgnoreCase(organizer.getStatus())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return null;
            }
            return organizer;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load organizer profile, userId=" + authUser.getUserId(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
            return null;
        }
    }

    // ------------------------------------------------------------------ CSRF
    private String getOrCreateCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object token = session.getAttribute(Constants.SESSION_ORGANIZER_PROFILE_CSRF);
        if (token instanceof String) {
            return (String) token;
        }
        byte[] randomBytes = new byte[32];
        secureRandom.nextBytes(randomBytes);
        String newToken = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
        session.setAttribute(Constants.SESSION_ORGANIZER_PROFILE_CSRF, newToken);
        return newToken;
    }

    private boolean isValidCsrfToken(HttpServletRequest request, String actual) {
        HttpSession session = request.getSession(false);
        Object expected = session == null ? null : session.getAttribute(Constants.SESSION_ORGANIZER_PROFILE_CSRF);
        if (!(expected instanceof String) || actual == null) {
            return false;
        }
        return MessageDigest.isEqual(
                ((String) expected).getBytes(StandardCharsets.UTF_8),
                actual.getBytes(StandardCharsets.UTF_8));
    }

    // ------------------------------------------------------------------ Đọc form
    /**
     * Đọc các trường của bảng Users được phép sửa. userId lấy từ session (qua
     * hồ sơ đã nạp), không nhận từ browser; role/status/password không được đọc
     * từ form.
     */
    private User buildSubmittedUser(HttpServletRequest request, int organizerId) {
        User submitted = new User();
        submitted.setUserId(organizerId);
        submitted.setFullName(trimToEmpty(request.getParameter("fullName")));
        submitted.setEmail(trimToEmpty(request.getParameter("email")));
        // Chấp nhận "0909 123 456", "0909.123.456", "0909-123-456" -> lưu dạng chỉ có số
        submitted.setPhone(trimToEmpty(request.getParameter("phone")).replaceAll("[\\s.\\-]", ""));
        String address = trimToEmpty(request.getParameter("address"));
        submitted.setAddress(address.isEmpty() ? null : address);
        return submitted;
    }

    /**
     * Chỉ đọc các cột Organizer được sửa. KYC, verification_status,
     * partner_tier, withdrawal_limit không bao giờ đọc từ form: giữ nguyên giá
     * trị đã lưu.
     */
    private OrganizerProfile buildSubmittedProfile(HttpServletRequest request, int organizerId, OrganizerProfile saved) {
        OrganizerProfile p = new OrganizerProfile();
        p.setUserId(organizerId);
        p.setSummary(emptyToNull(request.getParameter("summary")));
        p.setLegalRepresentative(emptyToNull(request.getParameter("legalRepresentative")));
        // MST đã được xác minh thì không cho đổi
        p.setTaxCode(saved.isVerified() ? saved.getTaxCode()
                : emptyToNull(trimToEmpty(request.getParameter("taxCode")).replaceAll("\\s", "")));
        p.setBankName(emptyToNull(request.getParameter("bankName")));
        p.setBankAccountNumber(emptyToNull(trimToEmpty(request.getParameter("bankAccountNumber")).replaceAll("[\\s.\\-]", "")));
        p.setBankAccountHolder(emptyToNull(request.getParameter("bankAccountHolder")));
        // Giữ nguyên các cột do Admin quản lý và ảnh hiện có (để hiển thị lại khi lỗi)
        p.setLogoUrl(saved.getLogoUrl());
        p.setCoverUrl(saved.getCoverUrl());
        // Kích thước hiển thị: thiếu/sai giá trị thì giữ giá trị đã lưu; ngoài khoảng cho phép thì kẹp về biên
        p.setCoverScale(readScale(request.getParameter("coverScale"), saved.getCoverScale(),
                Constants.PROFILE_COVER_SCALE_MIN, Constants.PROFILE_COVER_SCALE_MAX));
        p.setLogoScale(readScale(request.getParameter("logoScale"), saved.getLogoScale(),
                Constants.PROFILE_LOGO_SCALE_MIN, Constants.PROFILE_LOGO_SCALE_MAX));
        p.setKycLevel(saved.getKycLevel());
        p.setVerificationStatus(saved.getVerificationStatus());
        p.setPartnerTier(saved.getPartnerTier());
        p.setWithdrawalLimit(saved.getWithdrawalLimit());
        return p;
    }

    private static int readScale(String raw, int fallback, int min, int max) {
        int value = ValidationUtils.parseIntOrDefault(raw, fallback);
        return Math.max(min, Math.min(max, value));
    }

    private Set<Integer> readCategoryIds(HttpServletRequest request) {
        Set<Integer> ids = new LinkedHashSet<>();
        String[] values = request.getParameterValues("categoryIds");
        if (values != null) {
            for (String value : values) {
                int id = ValidationUtils.parseIntOrDefault(value, -1);
                if (id > 0) {
                    ids.add(id);
                }
            }
        }
        return ids;
    }

    private Part getPartSafely(HttpServletRequest request, String name) {
        try {
            return request.getPart(name);
        } catch (IOException | ServletException | IllegalStateException e) {
            return null;
        }
    }

    // ------------------------------------------------------------------ Kiểm tra form
    /**
     * @return map field -> thông báo lỗi; rỗng nếu hợp lệ.
     */
    private Map<String, String> validate(User user, OrganizerProfile p, Set<Integer> categoryIds,
            List<Category> activeCategories, Part logo, Part cover, Part document, String docType,
            OrganizerProfile saved) {
        Map<String, String> errors = new LinkedHashMap<>();

        // Tên tổ chức / thương hiệu (Users.full_name)
        if (ValidationUtils.isNullOrBlank(user.getFullName())) {
            errors.put("fullName", "Tên tổ chức không được để trống.");
        } else if (!ValidationUtils.isLengthBetween(user.getFullName(),
                Constants.PROFILE_FULL_NAME_MIN_LENGTH, Constants.PROFILE_FULL_NAME_MAX_LENGTH)) {
            errors.put("fullName", "Tên tổ chức phải từ " + Constants.PROFILE_FULL_NAME_MIN_LENGTH
                    + " đến " + Constants.PROFILE_FULL_NAME_MAX_LENGTH + " ký tự.");
        }

        // Email
        if (ValidationUtils.isNullOrBlank(user.getEmail())) {
            errors.put("email", "Email không được để trống.");
        } else if (user.getEmail().length() > Constants.PROFILE_EMAIL_MAX_LENGTH) {
            errors.put("email", "Email tối đa " + Constants.PROFILE_EMAIL_MAX_LENGTH + " ký tự.");
        } else if (!ValidationUtils.isEmail(user.getEmail())) {
            errors.put("email", "Email không đúng định dạng.");
        }

        // Số điện thoại
        if (ValidationUtils.isNullOrBlank(user.getPhone())) {
            errors.put("phone", "Số điện thoại không được để trống.");
        } else if (!ValidationUtils.isPhone(user.getPhone())) {
            errors.put("phone", "Số điện thoại không hợp lệ (bắt đầu bằng 0, gồm 10-11 chữ số).");
        }

        // Địa chỉ trụ sở
        if (user.getAddress() == null) {
            errors.put("address", "Địa chỉ trụ sở không được để trống.");
        } else if (user.getAddress().length() > Constants.PROFILE_ADDRESS_MAX_LENGTH) {
            errors.put("address", "Địa chỉ tối đa " + Constants.PROFILE_ADDRESS_MAX_LENGTH + " ký tự.");
        }

        // Thể loại chuyên trách: ít nhất 1, đều phải là thể loại đang hoạt động
        Set<Integer> activeIds = new LinkedHashSet<>();
        for (Category category : activeCategories) {
            activeIds.add(category.getCategoryId());
        }
        if (categoryIds.isEmpty()) {
            errors.put("categories", "Vui lòng chọn ít nhất một thể loại sự kiện chuyên trách.");
        } else if (!activeIds.containsAll(categoryIds)) {
            errors.put("categories", "Thể loại sự kiện không hợp lệ.");
        }

        // Mô tả ngắn
        if (p.getSummary() != null && p.getSummary().length() > Constants.PROFILE_SUMMARY_MAX_LENGTH) {
            errors.put("summary", "Mô tả tối đa " + Constants.PROFILE_SUMMARY_MAX_LENGTH + " ký tự.");
        }

        // Người đại diện pháp luật
        if (p.getLegalRepresentative() == null) {
            errors.put("legalRepresentative", "Người đại diện pháp luật không được để trống.");
        } else if (!ValidationUtils.isLengthBetween(p.getLegalRepresentative(),
                Constants.PROFILE_LEGAL_REP_MIN_LENGTH, Constants.PROFILE_LEGAL_REP_MAX_LENGTH)) {
            errors.put("legalRepresentative", "Người đại diện phải từ " + Constants.PROFILE_LEGAL_REP_MIN_LENGTH
                    + " đến " + Constants.PROFILE_LEGAL_REP_MAX_LENGTH + " ký tự.");
        }

        // Mã số thuế: 10 số, hoặc 13 số (10 số + 3 số chi nhánh, có thể có dấu gạch ngang)
        if (!saved.isVerified()) {
            if (p.getTaxCode() == null) {
                errors.put("taxCode", "Mã số thuế không được để trống.");
            } else if (!p.getTaxCode().matches("^\\d{10}(-?\\d{3})?$")) {
                errors.put("taxCode", "Mã số thuế gồm 10 chữ số (hoặc 13 chữ số cho chi nhánh).");
            }
        }

        // Tài khoản ngân hàng: không bắt buộc, nhưng đã nhập thì phải đủ 3 trường
        boolean anyBank = p.getBankName() != null || p.getBankAccountNumber() != null || p.getBankAccountHolder() != null;
        if (anyBank) {
            if (p.getBankName() == null) {
                errors.put("bankName", "Vui lòng nhập tên ngân hàng.");
            } else if (p.getBankName().length() > Constants.PROFILE_BANK_NAME_MAX_LENGTH) {
                errors.put("bankName", "Tên ngân hàng tối đa " + Constants.PROFILE_BANK_NAME_MAX_LENGTH + " ký tự.");
            }
            if (p.getBankAccountNumber() == null) {
                errors.put("bankAccountNumber", "Vui lòng nhập số tài khoản.");
            } else if (!p.getBankAccountNumber().matches("^\\d{6,20}$")) {
                errors.put("bankAccountNumber", "Số tài khoản gồm 6-20 chữ số.");
            }
            if (p.getBankAccountHolder() == null) {
                errors.put("bankAccountHolder", "Vui lòng nhập tên chủ tài khoản.");
            } else if (p.getBankAccountHolder().length() > Constants.PROFILE_BANK_HOLDER_MAX_LENGTH) {
                errors.put("bankAccountHolder", "Tên chủ tài khoản tối đa " + Constants.PROFILE_BANK_HOLDER_MAX_LENGTH + " ký tự.");
            }
        }

        // Tệp tải lên
        putIfNotNull(errors, "logo", validateUpload(logo, IMAGE_EXTENSIONS, "image/",
                Constants.PROFILE_IMAGE_MAX_SIZE, "Logo", "JPG, PNG hoặc WEBP"));
        putIfNotNull(errors, "cover", validateUpload(cover, IMAGE_EXTENSIONS, "image/",
                Constants.PROFILE_IMAGE_MAX_SIZE, "Ảnh bìa", "JPG, PNG hoặc WEBP"));
        if (hasFile(document)) {
            putIfNotNull(errors, "document", validateUpload(document, DOCUMENT_EXTENSIONS, null,
                    Constants.PROFILE_DOCUMENT_MAX_SIZE, "Tài liệu", "PDF, JPG hoặc PNG"));
            if (!DOCUMENT_TYPES.contains(docType)) {
                errors.put("document", "Vui lòng chọn loại tài liệu pháp lý.");
            }
        }

        // Trùng email / số điện thoại / MST với tài khoản khác - chỉ kiểm tra khi định dạng đã hợp lệ
        try {
            if (!errors.containsKey("email") && userDAO.existsEmailOfOtherUser(user.getEmail(), user.getUserId())) {
                errors.put("email", "Email đã được sử dụng bởi tài khoản khác.");
            }
            if (!errors.containsKey("phone") && userDAO.existsPhoneOfOtherUser(user.getPhone(), user.getUserId())) {
                errors.put("phone", "Số điện thoại đã được sử dụng bởi tài khoản khác.");
            }
            if (!saved.isVerified() && !errors.containsKey("taxCode") && p.getTaxCode() != null
                    && profileDAO.existsTaxCodeOfOther(p.getTaxCode(), user.getUserId())) {
                errors.put("taxCode", "Mã số thuế đã được sử dụng bởi tổ chức khác.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot check duplicate profile data, userId=" + user.getUserId(), e);
            errors.put("system", ERROR_GENERIC);
        }

        return errors;
    }

    private String validateUpload(Part part, List<String> extensions, String contentTypePrefix,
            long maxSize, String label, String formats) {
        if (!hasFile(part)) {
            return null;
        }
        if (part.getSize() > maxSize) {
            return label + " vượt quá dung lượng tối đa 5MB.";
        }
        String extension = getExtension(part.getSubmittedFileName());
        String contentType = part.getContentType();
        if (!extensions.contains(extension)
                || (contentTypePrefix != null && (contentType == null || !contentType.startsWith(contentTypePrefix)))) {
            return label + " chỉ chấp nhận định dạng " + formats + ".";
        }
        return null;
    }

    private static void putIfNotNull(Map<String, String> errors, String key, String message) {
        if (message != null) {
            errors.put(key, message);
        }
    }

    private boolean isDuplicateKeyError(SQLException e) {
        return e.getErrorCode() == SQL_ERROR_UNIQUE_CONSTRAINT || e.getErrorCode() == SQL_ERROR_UNIQUE_INDEX;
    }

    // ------------------------------------------------------------------ Hiển thị
    /**
     * @param organizer hồ sơ Users đã lưu trong database
     * @param form giá trị Users hiển thị trong form (bằng organizer khi mở
     * trang)
     * @param saved Organizer_Profiles đã lưu (nguồn của huy hiệu, checklist,
     * modal)
     * @param profileForm giá trị Organizer_Profiles hiển thị trong form
     * @param selectedCategoryIds thể loại đang được chọn trong form
     */
    private void showProfile(HttpServletRequest request, HttpServletResponse response,
            User organizer, User form, OrganizerProfile saved, OrganizerProfile profileForm,
            Set<Integer> selectedCategoryIds, Map<String, String> errors) throws ServletException, IOException {
        try {
            List<OrganizerDocument> documents = profileDAO.getDocuments(organizer.getUserId());
            Set<Integer> savedCategoryIds = profileDAO.getCategoryIds(organizer.getUserId());
            Map<String, BigDecimal> revenue = profileDAO.getRevenueBreakdown(organizer.getUserId());
            double[] rating = profileDAO.getRatingSummary(organizer.getUserId());

            request.setAttribute("organizer", organizer);
            request.setAttribute("form", form);
            request.setAttribute("errors", errors);
            request.setAttribute("profile", saved);
            request.setAttribute("profileForm", profileForm);
            request.setAttribute("categories", loadActiveCategories());
            request.setAttribute("selectedCategoryIds", selectedCategoryIds);
            request.setAttribute("documents", documents);
            request.setAttribute("approvedDocTypes", countApprovedRequiredDocTypes(documents));
            request.setAttribute("revenueSettled", revenue.get("settled"));
            request.setAttribute("revenueEscrow", revenue.get("escrow"));
            request.setAttribute("ratingAvg", rating[0]);
            request.setAttribute("ratingCount", (int) rating[1]);
            request.setAttribute("csrfToken", getOrCreateCsrfToken(request));
            applyChecklist(request, organizer, saved, savedCategoryIds, documents);
            loadEventStatistics(request, organizer.getUserId());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load profile page data, userId=" + organizer.getUserId(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
            return;
        }
        request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
    }

    private List<Category> loadActiveCategories() throws SQLException {
        List<Category> active = new ArrayList<>();
        for (Category category : categoryDAO.getAllCategories()) {
            if (Constants.STATUS_ACTIVE.equalsIgnoreCase(category.getStatus())) {
                active.add(category);
            }
        }
        return active;
    }

    private int countApprovedRequiredDocTypes(List<OrganizerDocument> documents) {
        Set<String> approved = new LinkedHashSet<>();
        for (OrganizerDocument document : documents) {
            if (Constants.DOC_APPROVED.equals(document.getStatus())
                    && REQUIRED_DOCUMENT_TYPES.contains(document.getDocType())) {
                approved.add(document.getDocType());
            }
        }
        return approved.size();
    }

    /**
     * Độ hoàn thiện hồ sơ theo 4 nhóm, mỗi nhóm 25%: thương hiệu + thể loại,
     * logo + ảnh bìa, MST + người đại diện + tài liệu, tài khoản ngân hàng.
     */
    private void applyChecklist(HttpServletRequest request, User organizer, OrganizerProfile saved,
            Set<Integer> savedCategoryIds, List<OrganizerDocument> documents) {
        boolean brand = !ValidationUtils.isNullOrBlank(organizer.getFullName()) && !savedCategoryIds.isEmpty();
        boolean media = !ValidationUtils.isNullOrBlank(saved.getLogoUrl()) && !ValidationUtils.isNullOrBlank(saved.getCoverUrl());
        // Quy tắc nghiệp vụ: phải có Giấy phép kinh doanh (đang chờ duyệt hoặc đã duyệt) mới đủ điều kiện xác minh
        String licenseState = getBusinessLicenseState(documents);
        boolean legal = !ValidationUtils.isNullOrBlank(saved.getTaxCode())
                && !ValidationUtils.isNullOrBlank(saved.getLegalRepresentative())
                && ("APPROVED".equals(licenseState) || "PENDING".equals(licenseState));
        boolean bank = saved.isBankComplete();
        int done = (brand ? 1 : 0) + (media ? 1 : 0) + (legal ? 1 : 0) + (bank ? 1 : 0);

        request.setAttribute("ckBrand", brand);
        request.setAttribute("ckMedia", media);
        request.setAttribute("ckLegal", legal);
        request.setAttribute("licenseState", licenseState);
        request.setAttribute("ckBank", bank);
        request.setAttribute("profileCompletion", done * 25);
    }

    /**
     * Trạng thái Giấy phép kinh doanh: APPROVED > PENDING > REJECTED > MISSING.
     * Chỉ giấy phép APPROVED mới cho phép Admin xác minh tổ chức.
     */
    private String getBusinessLicenseState(List<OrganizerDocument> documents) {
        String state = "MISSING";
        for (OrganizerDocument document : documents) {
            if (!"BUSINESS_LICENSE".equals(document.getDocType())) {
                continue;
            }
            if (Constants.DOC_APPROVED.equals(document.getStatus())) {
                return "APPROVED";
            }
            if (Constants.DOC_PENDING.equals(document.getStatus())) {
                state = "PENDING";
            } else if ("MISSING".equals(state)) {
                state = "REJECTED";
            }
        }
        return state;
    }

    /**
     * Số liệu thật của Organizer, dùng lại các hàm có sẵn trong EventDAO.
     */
    private void loadEventStatistics(HttpServletRequest request, int organizerId) {
        Map<String, Integer> statusCounts = eventDAO.countEventsByStatus(organizerId);
        int totalEvents = 0;
        for (Integer count : statusCounts.values()) {
            totalEvents += count;
        }
        Integer activeEvents = statusCounts.get(Constants.EVENT_ACTIVE);

        Map<String, Number> sales = eventDAO.getOrganizerSalesSummary(organizerId);
        int ticketSold = sales.getOrDefault("ticketSold", 0).intValue();
        int ticketTotal = sales.getOrDefault("ticketTotal", 0).intValue();

        request.setAttribute("totalEvents", totalEvents);
        request.setAttribute("activeEvents", activeEvents == null ? 0 : activeEvents);
        request.setAttribute("ticketSold", ticketSold);
        request.setAttribute("ticketTotal", ticketTotal);
    }

    // ------------------------------------------------------------------ Tệp tải lên
    private static boolean hasFile(Part part) {
        return part != null && part.getSize() > 0 && !ValidationUtils.isNullOrBlank(part.getSubmittedFileName());
    }

    private static String getExtension(String submittedFileName) {
        if (submittedFileName == null) {
            return "";
        }
        String fileName = Paths.get(submittedFileName).getFileName().toString();
        int dotIndex = fileName.lastIndexOf('.');
        return dotIndex < 0 ? "" : fileName.substring(dotIndex + 1).toLowerCase(Locale.ROOT);
    }

    private static String safeFileName(String submittedFileName) {
        if (submittedFileName == null) {
            return "tai-lieu";
        }
        return Paths.get(submittedFileName).getFileName().toString();
    }

    /**
     * Lưu logo/ảnh bìa công khai vào assets/uploads (cùng nơi với ảnh sự kiện).
     * Tên có mốc thời gian để trình duyệt không dùng lại ảnh cũ trong cache.
     *
     * @return đường dẫn tương đối lưu trong Organizer_Profiles
     */
    private String saveImage(Part part, int userId, String kind) throws IOException {
        String uploadDir = getServletContext().getRealPath(Constants.UPLOAD_DIR);
        if (uploadDir == null) {
            throw new IOException("Upload directory is not writable (WAR not exploded)");
        }
        File directory = new File(uploadDir);
        if (!directory.exists() && !directory.mkdirs()) {
            throw new IOException("Cannot create upload directory");
        }
        String fileName = "organizer-" + userId + "-" + kind + "-" + System.currentTimeMillis()
                + "." + getExtension(part.getSubmittedFileName());
        part.write(new File(directory, fileName).getAbsolutePath());
        return "assets/uploads/" + fileName;
    }

    /**
     * Lưu tài liệu pháp lý ngoài thư mục web (không truy cập trực tiếp bằng
     * URL).
     *
     * @return tên tệp đã lưu (không phải đường dẫn)
     */
    private String saveDocument(Part part, int userId) throws IOException {
        Path directory = getPrivateDocumentDir();
        Files.createDirectories(directory);
        String fileName = "doc-" + userId + "-" + System.currentTimeMillis() + "-"
                + Long.toHexString(secureRandom.nextLong()) + "." + getExtension(part.getSubmittedFileName());
        part.write(directory.resolve(fileName).toString());
        return fileName;
    }

    private Path getPrivateDocumentDir() {
        return Paths.get(System.getProperty("user.home"), Constants.PRIVATE_DOC_DIR_NAME.split("/")).toAbsolutePath().normalize();
    }

    /**
     * Xóa tệp vừa lưu khi bước sau thất bại (bỏ qua tham số null).
     */
    private void deleteQuietly(String logoUrl, String coverUrl, String documentFile) {
        try {
            if (logoUrl != null) {
                deletePublicImage(logoUrl);
            }
            if (coverUrl != null) {
                deletePublicImage(coverUrl);
            }
            if (documentFile != null) {
                Path directory = getPrivateDocumentDir();
                Path file = directory.resolve(Paths.get(documentFile).getFileName().toString()).normalize();
                if (file.startsWith(directory)) {
                    Files.deleteIfExists(file);
                }
            }
        } catch (IOException e) {
            LOGGER.log(Level.WARNING, "Cannot clean up uploaded file", e);
        }
    }

    /**
     * Chỉ xóa ảnh cũ của chính organizer này, nằm trong thư mục upload.
     */
    private void deleteOldImage(String relativePath, int userId) {
        if (relativePath != null && relativePath.startsWith("assets/uploads/organizer-" + userId + "-")) {
            try {
                deletePublicImage(relativePath);
            } catch (IOException e) {
                LOGGER.log(Level.WARNING, "Cannot delete old image", e);
            }
        }
    }

    private void deletePublicImage(String relativePath) throws IOException {
        String uploadDir = getServletContext().getRealPath(Constants.UPLOAD_DIR);
        if (uploadDir == null || !relativePath.startsWith("assets/uploads/")) {
            return;
        }
        Path directory = Paths.get(uploadDir).toAbsolutePath().normalize();
        Path file = directory.resolve(Paths.get(relativePath).getFileName().toString()).normalize();
        if (file.startsWith(directory)) {
            Files.deleteIfExists(file);
        }
    }

    // Khi lưu lỗi: trả ảnh trong form về ảnh đã lưu để trang hiển thị đúng
    private void restoreForm(OrganizerProfile submitted, OrganizerProfile saved) {
        submitted.setLogoUrl(saved.getLogoUrl());
        submitted.setCoverUrl(saved.getCoverUrl());
    }

    /**
     * GET /organizer/profile/document?id= : chỉ chủ sở hữu mới xem được tài
     * liệu.
     */
    private void serveDocument(HttpServletRequest request, HttpServletResponse response, User organizer)
            throws IOException {
        int documentId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), -1);
        try {
            OrganizerDocument document = documentId > 0 ? profileDAO.getDocument(documentId, organizer.getUserId()) : null;
            if (document == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            Path directory = getPrivateDocumentDir();
            Path file = directory.resolve(Paths.get(document.getFileName()).getFileName().toString()).normalize();
            if (!file.startsWith(directory) || !Files.isRegularFile(file)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            String extension = getExtension(file.getFileName().toString());
            String contentType = "application/octet-stream";
            if ("pdf".equals(extension)) {
                contentType = "application/pdf";
            } else if ("png".equals(extension)) {
                contentType = "image/png";
            } else if ("jpg".equals(extension) || "jpeg".equals(extension)) {
                contentType = "image/jpeg";
            }
            response.setContentType(contentType);
            response.setContentLengthLong(Files.size(file));
            response.setHeader("Content-Disposition", "inline; filename=\"organizer-document." + extension + "\"");
            response.setHeader("X-Content-Type-Options", "nosniff");
            response.setHeader("Cache-Control", "private, no-store");
            Files.copy(file, response.getOutputStream());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load organizer document, userId=" + organizer.getUserId(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
        }
    }

    // ------------------------------------------------------------------ Tiện ích
    /**
     * Đồng bộ tên/email/điện thoại/địa chỉ trong session để sidebar hiển thị
     * đúng ngay sau khi lưu. Không đụng tới role, status, password.
     */
    private void refreshSessionUser(HttpServletRequest request, User updated) {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(Constants.SESSION_USER);
        if (sessionUser instanceof Auth) {
            Auth authUser = (Auth) sessionUser;
            authUser.setFullName(updated.getFullName());
            authUser.setEmail(updated.getEmail());
            authUser.setPhone(updated.getPhone());
            authUser.setAddress(updated.getAddress());
        }
    }

    // Chuyển thông báo flash trong session sang request để JSP hiển thị một lần
    private void moveFlashMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object message = session.getAttribute(Constants.SESSION_ORGANIZER_PROFILE_SUCCESS);
        if (message != null) {
            request.setAttribute("successMessage", message);
            session.removeAttribute(Constants.SESSION_ORGANIZER_PROFILE_SUCCESS);
        }
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private static String emptyToNull(String value) {
        String trimmed = trimToEmpty(value);
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static String truncate(String value, int maxLength) {
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
