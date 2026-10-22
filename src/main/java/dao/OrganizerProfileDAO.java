package dao;

import model.OrganizerDocument;
import model.OrganizerProfile;
import model.User;
import utils.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Hồ sơ mở rộng của Organizer: Organizer_Profiles, Organizer_Categories,
 * Organizer_Documents. Tên, email, điện thoại, địa chỉ vẫn nằm ở Users.
 */
public class OrganizerProfileDAO {

    private static final String SELECT_PROFILE
            = "SELECT user_id, summary, logo_url, cover_url, cover_scale, logo_scale, tax_code, legal_representative, "
            + "website_url, facebook_url, youtube_url, spotify_url, bank_name, bank_account_number, "
            + "bank_account_holder, kyc_level, verification_status, partner_tier, withdrawal_limit "
            + "FROM Organizer_Profiles WHERE user_id = ?";

    private static final String UPDATE_USER
            = "UPDATE Users SET full_name = ?, email = ?, phone = ?, address = ?, updated_at = GETDATE() "
            + "WHERE user_id = ? AND UPPER(role) = 'ORGANIZER' AND UPPER(status) = 'ACTIVE'";

    // Ảnh không đổi (tham số NULL) thì giữ ảnh cũ; MST đã VERIFIED thì không cho đổi.
    // Các cột website/facebook/youtube/spotify không còn nhập trên form: nhánh UPDATE không đụng tới
    // để giữ nguyên dữ liệu đã lưu (nhánh INSERT để NULL).
    private static final String MERGE_PROFILE
            = "MERGE Organizer_Profiles AS t USING (SELECT ? AS user_id) AS s ON t.user_id = s.user_id "
            + "WHEN MATCHED THEN UPDATE SET summary = ?, legal_representative = ?, "
            + "tax_code = CASE WHEN t.verification_status = 'VERIFIED' THEN t.tax_code ELSE ? END, "
            + "logo_url = COALESCE(?, t.logo_url), cover_url = COALESCE(?, t.cover_url), "
            + "cover_scale = ?, logo_scale = ?, "
            + "bank_name = ?, bank_account_number = ?, bank_account_holder = ?, updated_at = GETDATE() "
            + "WHEN NOT MATCHED THEN INSERT (user_id, summary, legal_representative, tax_code, logo_url, "
            + "cover_url, cover_scale, logo_scale, bank_name, bank_account_number, bank_account_holder) "
            + "VALUES (s.user_id, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";

    /**
     * @return hồ sơ mở rộng; đối tượng rỗng (userId đã gán) nếu chưa có dòng
     * nào.
     */
    public OrganizerProfile getProfile(int userId) throws SQLException {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(SELECT_PROFILE)) {
            statement.setInt(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                OrganizerProfile profile = new OrganizerProfile();
                profile.setUserId(userId);
                if (rs.next()) {
                    profile.setSummary(rs.getString("summary"));
                    profile.setLogoUrl(rs.getString("logo_url"));
                    profile.setCoverUrl(rs.getString("cover_url"));
                    profile.setCoverScale(rs.getInt("cover_scale"));
                    profile.setLogoScale(rs.getInt("logo_scale"));
                    profile.setTaxCode(rs.getString("tax_code"));
                    profile.setLegalRepresentative(rs.getString("legal_representative"));
                    profile.setWebsiteUrl(rs.getString("website_url"));
                    profile.setFacebookUrl(rs.getString("facebook_url"));
                    profile.setYoutubeUrl(rs.getString("youtube_url"));
                    profile.setSpotifyUrl(rs.getString("spotify_url"));
                    profile.setBankName(rs.getString("bank_name"));
                    profile.setBankAccountNumber(rs.getString("bank_account_number"));
                    profile.setBankAccountHolder(rs.getString("bank_account_holder"));
                    profile.setKycLevel(rs.getInt("kyc_level"));
                    profile.setVerificationStatus(rs.getString("verification_status"));
                    profile.setPartnerTier(rs.getString("partner_tier"));
                    profile.setWithdrawalLimit(rs.getBigDecimal("withdrawal_limit"));
                }
                return profile;
            }
        }
    }

    public Set<Integer> getCategoryIds(int userId) throws SQLException {
        Set<Integer> ids = new LinkedHashSet<>();
        String sql = "SELECT category_id FROM Organizer_Categories WHERE user_id = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt(1));
                }
            }
        }
        return ids;
    }

    public boolean existsTaxCodeOfOther(String taxCode, int userId) throws SQLException {
        String sql = "SELECT 1 FROM Organizer_Profiles WHERE tax_code = ? AND user_id <> ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, taxCode);
            statement.setInt(2, userId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Lưu Users (tên, email, điện thoại, địa chỉ), Organizer_Profiles và thể
     * loại chuyên trách trong cùng một transaction.
     *
     * @param logoUrl / coverUrl: null nếu không đổi ảnh
     * @return false nếu tài khoản không còn là Organizer ACTIVE (đã rollback)
     */
    public boolean saveProfile(User core, OrganizerProfile p, Collection<Integer> categoryIds) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement statement = connection.prepareStatement(UPDATE_USER)) {
                    statement.setString(1, core.getFullName());
                    statement.setString(2, core.getEmail());
                    statement.setString(3, core.getPhone());
                    setNullable(statement, 4, core.getAddress());
                    statement.setInt(5, core.getUserId());
                    if (statement.executeUpdate() == 0) {
                        connection.rollback();
                        return false;
                    }
                }

                try (PreparedStatement statement = connection.prepareStatement(MERGE_PROFILE)) {
                    statement.setInt(1, core.getUserId());
                    int base = 1; // 10 giá trị cho nhánh UPDATE, rồi 10 giá trị cho nhánh INSERT
                    for (int pass = 0; pass < 2; pass++) {
                        setNullable(statement, ++base, p.getSummary());
                        setNullable(statement, ++base, p.getLegalRepresentative());
                        setNullable(statement, ++base, p.getTaxCode());
                        setNullable(statement, ++base, p.getLogoUrl());
                        setNullable(statement, ++base, p.getCoverUrl());
                        statement.setInt(++base, p.getCoverScale());
                        statement.setInt(++base, p.getLogoScale());
                        setNullable(statement, ++base, p.getBankName());
                        setNullable(statement, ++base, p.getBankAccountNumber());
                        setNullable(statement, ++base, p.getBankAccountHolder());
                    }
                    statement.executeUpdate();
                }

                try (PreparedStatement statement = connection.prepareStatement(
                        "DELETE FROM Organizer_Categories WHERE user_id = ?")) {
                    statement.setInt(1, core.getUserId());
                    statement.executeUpdate();
                }
                try (PreparedStatement statement = connection.prepareStatement(
                        "INSERT INTO Organizer_Categories (user_id, category_id) "
                        + "SELECT ?, category_id FROM Categories WHERE category_id = ? AND UPPER(status) = 'ACTIVE'")) {
                    for (Integer categoryId : categoryIds) {
                        statement.setInt(1, core.getUserId());
                        statement.setInt(2, categoryId);
                        statement.addBatch();
                    }
                    statement.executeBatch();
                }

                connection.commit();
                return true;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    // ------------------------------------------------------------------ Tài liệu pháp lý
    public List<OrganizerDocument> getDocuments(int userId) throws SQLException {
        List<OrganizerDocument> documents = new ArrayList<>();
        String sql = "SELECT document_id, user_id, doc_type, doc_name, file_name, status, uploaded_at "
                + "FROM Organizer_Documents WHERE user_id = ? ORDER BY uploaded_at DESC, document_id DESC";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    documents.add(mapDocument(rs));
                }
            }
        }
        return documents;
    }

    /**
     * Chỉ trả về tài liệu thuộc đúng userId (kiểm tra quyền sở hữu).
     */
    public OrganizerDocument getDocument(int documentId, int userId) throws SQLException {
        String sql = "SELECT document_id, user_id, doc_type, doc_name, file_name, status, uploaded_at "
                + "FROM Organizer_Documents WHERE document_id = ? AND user_id = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, documentId);
            statement.setInt(2, userId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? mapDocument(rs) : null;
            }
        }
    }

    public void insertDocument(OrganizerDocument document) throws SQLException {
        String sql = "INSERT INTO Organizer_Documents (user_id, doc_type, doc_name, file_name) VALUES (?, ?, ?, ?)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, document.getUserId());
            statement.setString(2, document.getDocType());
            statement.setString(3, document.getDocName());
            statement.setString(4, document.getFileName());
            statement.executeUpdate();
        }
    }

    // ------------------------------------------------------------------ Số liệu hiển thị
    /**
     * Doanh thu đơn Paid của sự kiện chưa bị hủy: "settled" = sự kiện đã kết
     * thúc (khả dụng), "escrow" = sự kiện chưa diễn ra (tạm giữ).
     */
    public Map<String, BigDecimal> getRevenueBreakdown(int organizerId) throws SQLException {
        Map<String, BigDecimal> result = new LinkedHashMap<>();
        result.put("settled", BigDecimal.ZERO);
        result.put("escrow", BigDecimal.ZERO);
        String sql = "SELECT ISNULL(SUM(CASE WHEN e.end_time <= GETDATE() THEN od.subtotal END), 0), "
                + "ISNULL(SUM(CASE WHEN e.end_time > GETDATE() THEN od.subtotal END), 0) "
                + "FROM Order_Details od "
                + "JOIN Event_Tickets t ON t.event_ticket_id = od.event_ticket_id "
                + "JOIN Events e ON e.event_id = t.event_id "
                + "JOIN Orders o ON o.order_id = od.order_id "
                + "WHERE e.organizer_id = ? AND o.status = 'Paid' AND UPPER(e.status) <> 'CANCELLED'";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, organizerId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    result.put("settled", rs.getBigDecimal(1));
                    result.put("escrow", rs.getBigDecimal(2));
                }
            }
        }
        return result;
    }

    /**
     * @return {điểm trung bình (0 nếu chưa có), số đánh giá} của các sự kiện
     * thuộc organizer.
     */
    public double[] getRatingSummary(int organizerId) throws SQLException {
        String sql = "SELECT ISNULL(AVG(CAST(r.rating AS FLOAT)), 0), COUNT(*) FROM Reviews r "
                + "JOIN Events e ON e.event_id = r.event_id "
                + "WHERE e.organizer_id = ? AND UPPER(r.status) = 'ACTIVE'";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, organizerId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return new double[]{rs.getDouble(1), rs.getInt(2)};
                }
            }
        }
        return new double[]{0, 0};
    }

    // ------------------------------------------------------------------ Tiện ích
    private OrganizerDocument mapDocument(ResultSet rs) throws SQLException {
        OrganizerDocument document = new OrganizerDocument();
        document.setDocumentId(rs.getInt("document_id"));
        document.setUserId(rs.getInt("user_id"));
        document.setDocType(rs.getString("doc_type"));
        document.setDocName(rs.getString("doc_name"));
        document.setFileName(rs.getString("file_name"));
        document.setStatus(rs.getString("status"));
        Timestamp uploadedAt = rs.getTimestamp("uploaded_at");
        if (uploadedAt != null) {
            document.setUploadedAt(uploadedAt.toLocalDateTime());
        }
        return document;
    }

    private static void setNullable(PreparedStatement statement, int index, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) {
            statement.setNull(index, Types.NVARCHAR);
        } else {
            statement.setString(index, value);
        }
    }
}
