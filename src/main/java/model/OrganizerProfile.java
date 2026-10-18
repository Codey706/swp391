package model;

import java.math.BigDecimal;

/**
 * Khớp bảng Organizer_Profiles (thông tin mở rộng của Organizer, 1-1 với
 * Users). Các cột kycLevel, verificationStatus, partnerTier, withdrawalLimit do
 * Admin quản lý; Organizer chỉ xem.
 */
public class OrganizerProfile {

    private int userId;
    private String summary;
    private String logoUrl;
    private String coverUrl;
    private String taxCode;
    private String legalRepresentative;
    private String websiteUrl;
    private String facebookUrl;
    private String youtubeUrl;
    private String spotifyUrl;
    private String bankName;
    private String bankAccountNumber;
    private String bankAccountHolder;
    private int kycLevel;
    private String verificationStatus = "PENDING";
    private String partnerTier;
    private BigDecimal withdrawalLimit;

    public OrganizerProfile() {
    }

    public boolean isVerified() {
        return "VERIFIED".equalsIgnoreCase(verificationStatus);
    }

    public boolean isBankComplete() {
        return notBlank(bankName) && notBlank(bankAccountNumber) && notBlank(bankAccountHolder);
    }

    public boolean isSocialFilled() {
        return notBlank(websiteUrl) || notBlank(facebookUrl) || notBlank(youtubeUrl) || notBlank(spotifyUrl);
    }

    /**
     * Số tài khoản nhóm 4 số cho dễ đọc: 0071 0008 8268
     */
    public String getBankAccountDisplay() {
        if (!notBlank(bankAccountNumber)) {
            return "";
        }
        return bankAccountNumber.replaceAll("(.{4})(?=.)", "$1 ");
    }

    private static boolean notBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public String getTaxCode() {
        return taxCode;
    }

    public void setTaxCode(String taxCode) {
        this.taxCode = taxCode;
    }

    public String getLegalRepresentative() {
        return legalRepresentative;
    }

    public void setLegalRepresentative(String legalRepresentative) {
        this.legalRepresentative = legalRepresentative;
    }

    public String getWebsiteUrl() {
        return websiteUrl;
    }

    public void setWebsiteUrl(String websiteUrl) {
        this.websiteUrl = websiteUrl;
    }

    public String getFacebookUrl() {
        return facebookUrl;
    }

    public void setFacebookUrl(String facebookUrl) {
        this.facebookUrl = facebookUrl;
    }

    public String getYoutubeUrl() {
        return youtubeUrl;
    }

    public void setYoutubeUrl(String youtubeUrl) {
        this.youtubeUrl = youtubeUrl;
    }

    public String getSpotifyUrl() {
        return spotifyUrl;
    }

    public void setSpotifyUrl(String spotifyUrl) {
        this.spotifyUrl = spotifyUrl;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getBankAccountNumber() {
        return bankAccountNumber;
    }

    public void setBankAccountNumber(String bankAccountNumber) {
        this.bankAccountNumber = bankAccountNumber;
    }

    public String getBankAccountHolder() {
        return bankAccountHolder;
    }

    public void setBankAccountHolder(String bankAccountHolder) {
        this.bankAccountHolder = bankAccountHolder;
    }

    public int getKycLevel() {
        return kycLevel;
    }

    public void setKycLevel(int kycLevel) {
        this.kycLevel = kycLevel;
    }

    public String getVerificationStatus() {
        return verificationStatus;
    }

    public void setVerificationStatus(String verificationStatus) {
        this.verificationStatus = verificationStatus;
    }

    public String getPartnerTier() {
        return partnerTier;
    }

    public void setPartnerTier(String partnerTier) {
        this.partnerTier = partnerTier;
    }

    public BigDecimal getWithdrawalLimit() {
        return withdrawalLimit;
    }

    public void setWithdrawalLimit(BigDecimal withdrawalLimit) {
        this.withdrawalLimit = withdrawalLimit;
    }
}
