package model;

import java.time.LocalDateTime;

/**
 * Khớp bảng Organizer_Documents (tài liệu pháp lý của Organizer, Admin duyệt).
 */
public class OrganizerDocument {

    private int documentId;
    private int userId;
    private String docType;
    private String docName;
    private String fileName;
    private String status;
    private LocalDateTime uploadedAt;

    public OrganizerDocument() {
    }

    /**
     * Tên loại tài liệu hiển thị trên giao diện.
     */
    public String getTypeLabel() {
        if ("BUSINESS_LICENSE".equals(docType)) {
            return "Giấy phép kinh doanh";
        }
        if ("PERFORMANCE_PERMIT".equals(docType)) {
            return "Giấy phép biểu diễn";
        }
        if ("COPYRIGHT_CONTRACT".equals(docType)) {
            return "Hợp đồng tác quyền";
        }
        return "Tài liệu khác";
    }

    /**
     * Biểu tượng Material Symbols theo loại tài liệu.
     */
    public String getIcon() {
        if ("PERFORMANCE_PERMIT".equals(docType)) {
            return "theater_comedy";
        }
        if ("COPYRIGHT_CONTRACT".equals(docType)) {
            return "gavel";
        }
        return "description";
    }

    public String getStatusLabel() {
        if ("APPROVED".equals(status)) {
            return "Đã duyệt";
        }
        if ("REJECTED".equals(status)) {
            return "Bị từ chối";
        }
        return "Chờ duyệt";
    }

    public int getDocumentId() {
        return documentId;
    }

    public void setDocumentId(int documentId) {
        this.documentId = documentId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getDocType() {
        return docType;
    }

    public void setDocType(String docType) {
        this.docType = docType;
    }

    public String getDocName() {
        return docName;
    }

    public void setDocName(String docName) {
        this.docName = docName;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(LocalDateTime uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
}
