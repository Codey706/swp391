package utils;

import jakarta.activation.DataHandler;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;
import jakarta.mail.util.ByteArrayDataSource;
import java.io.IOException;
import java.io.InputStream;
import java.security.SecureRandom;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Gửi email qua SMTP. Cấu hình lấy theo thứ tự: biến môi trường LTM_SMTP_* rồi
 * src/main/resources/mail.properties. Nếu chưa cấu hình tài khoản SMTP, email KHÔNG
 * được gửi mà nội dung được ghi ra log server (chế độ dev) để nhóm vẫn chạy local được,
 * ví dụ đọc mã OTP trong log Tomcat.
 */
public class EmailService {

    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final Properties FILE_CONFIG = loadFileConfig();

    private static final String SMTP_HOST = config("LTM_SMTP_HOST", "mail.smtp.host", "smtp.gmail.com");
    private static final String SMTP_PORT = config("LTM_SMTP_PORT", "mail.smtp.port", "587");
    private static final String SMTP_USER = config("LTM_SMTP_USER", "mail.username", null);
    private static final String SMTP_PASSWORD = config("LTM_SMTP_PASSWORD", "mail.password", null);
    private static final String FROM_NAME = config("LTM_MAIL_FROM_NAME", "mail.from.name", "Light Ticket");

    // Gửi nền để không làm chậm request (IPN VNPay, duyệt sự kiện...). Tắt trong AppLifecycleListener.
    private static final ExecutorService MAIL_EXECUTOR = Executors.newSingleThreadExecutor(r -> {
        Thread thread = new Thread(r, "ltm-mail");
        thread.setDaemon(true);
        return thread;
    });

    private EmailService() {
    }

    public static String createOtp() {
        return String.format("%06d", RANDOM.nextInt(1000000));
    }

    public static boolean isConfigured() {
        return SMTP_USER != null && SMTP_PASSWORD != null;
    }

    public static boolean sendOtp(String toEmail, String otp) {
        String subject = "Mã xác thực OTP - Light Ticket";
        if (!isConfigured()) {
            return sendText(toEmail, subject, "Mã xác thực OTP của bạn là: " + otp
                    + "\nCó hiệu lực trong vòng 3 phút.");
        }
        return sendHtml(toEmail, subject, otpHtml(otp), null);
    }

    /** Email OTP dạng HTML (bảng + style inline để hiển thị đúng trên Gmail/Outlook). */
    private static String otpHtml(String otp) {
        return "<!DOCTYPE html><html lang=\"vi\"><head><meta charset=\"UTF-8\">"
            + "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"></head>"
            + "<body style=\"margin:0;padding:0;background:#f6f5f2;font-family:'Be Vietnam Pro',Arial,Helvetica,sans-serif;color:#1d1c1a;\">"
            // preheader: dòng xem trước trong hộp thư
            + "<div style=\"display:none;max-height:0;overflow:hidden;\">Mã OTP của bạn là " + otp + " - có hiệu lực trong 3 phút.</div>"
            + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:#f6f5f2;padding:32px 12px;\"><tr><td align=\"center\">"
            + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"max-width:480px;background:#ffffff;border:1px solid #e4e1da;border-radius:14px;overflow:hidden;\">"
            + "<tr><td style=\"background:#c8442b;padding:18px 28px;color:#ffffff;font-size:18px;font-weight:700;\">&#127915; Light Ticket</td></tr>"
            + "<tr><td style=\"padding:30px 28px 8px;\">"
            + "<h1 style=\"margin:0 0 10px;font-size:21px;line-height:1.35;\">Mã xác thực của bạn</h1>"
            + "<p style=\"margin:0;font-size:14px;line-height:1.6;color:#6f6a62;\">Nhập mã dưới đây để tiếp tục. Mã có hiệu lực trong <b style=\"color:#1d1c1a;\">3 phút</b>.</p>"
            + "</td></tr>"
            + "<tr><td align=\"center\" style=\"padding:22px 28px;\">"
            + "<div style=\"display:inline-block;padding:16px 26px;background:#fcf3f0;border:1px dashed #e8a48f;border-radius:12px;"
            + "font-family:'Courier New',Consolas,monospace;font-size:32px;font-weight:700;letter-spacing:6px;color:#c8442b;\">"
            + otp + "</div></td></tr>"
            + "<tr><td style=\"padding:0 28px 28px;\">"
            + "<p style=\"margin:0 0 10px;font-size:13px;line-height:1.6;color:#6f6a62;\">Không chia sẻ mã này với bất kỳ ai, kể cả nhân viên Light Ticket.</p>"
            + "<p style=\"margin:0;font-size:13px;line-height:1.6;color:#6f6a62;\">Nếu bạn không yêu cầu mã này, hãy bỏ qua email - tài khoản của bạn vẫn an toàn.</p>"
            + "</td></tr>"
            + "<tr><td style=\"padding:16px 28px;border-top:1px solid #e4e1da;font-size:12px;color:#9a948a;text-align:center;\">"
            + "Email tự động từ Light Ticket, vui lòng không trả lời.</td></tr>"
            + "</table></td></tr></table></body></html>";
    }

    public static boolean sendText(String toEmail, String subject, String text) {
        if (!isConfigured()) {
            LOGGER.warning("[DEV MAIL - SMTP chưa cấu hình] To: " + toEmail + " | " + subject + "\n" + text);
            return true;
        }
        try {
            Message message = newMessage(toEmail, subject);
            // Phải chỉ rõ UTF-8: mặc định dùng charset của hệ điều hành (cp1252 trên Windows) làm hỏng tiếng Việt
            ((MimeMessage) message).setText(text, "UTF-8");
            Transport.send(message);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Cannot send email to " + toEmail, e);
            return false;
        }
    }

    /**
     * Email HTML kèm ảnh nhúng: mỗi entry cid -> PNG được tham chiếu trong HTML bằng src="cid:...".
     */
    public static boolean sendHtml(String toEmail, String subject, String html, Map<String, byte[]> inlinePngs) {
        if (!isConfigured()) {
            LOGGER.warning("[DEV MAIL - SMTP chưa cấu hình] To: " + toEmail + " | " + subject
                    + " (HTML, " + (inlinePngs == null ? 0 : inlinePngs.size()) + " ảnh)");
            return true;
        }
        try {
            Message message = newMessage(toEmail, subject);
            MimeMultipart related = new MimeMultipart("related");
            MimeBodyPart htmlPart = new MimeBodyPart();
            htmlPart.setContent(html, "text/html; charset=UTF-8");
            related.addBodyPart(htmlPart);
            if (inlinePngs != null) {
                for (Map.Entry<String, byte[]> image : inlinePngs.entrySet()) {
                    MimeBodyPart imagePart = new MimeBodyPart();
                    imagePart.setDataHandler(new DataHandler(new ByteArrayDataSource(image.getValue(), "image/png")));
                    imagePart.setContentID("<" + image.getKey() + ">");
                    imagePart.setDisposition(MimeBodyPart.INLINE);
                    imagePart.setFileName(image.getKey() + ".png");
                    related.addBodyPart(imagePart);
                }
            }
            message.setContent(related);
            Transport.send(message);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Cannot send email to " + toEmail, e);
            return false;
        }
    }

    /** Chạy một tác vụ gửi email ở luồng nền. */
    public static void sendAsync(Runnable task) {
        MAIL_EXECUTOR.execute(() -> {
            try {
                task.run();
            } catch (RuntimeException e) {
                LOGGER.log(Level.SEVERE, "Background email task failed", e);
            }
        });
    }

    public static void shutdown() {
        MAIL_EXECUTOR.shutdown();
        try {
            MAIL_EXECUTOR.awaitTermination(10, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private static Message newMessage(String toEmail, String subject) throws Exception {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");
        props.put("mail.smtp.writetimeout", "5000");
        props.put("mail.smtp.quitwait", "false");
        props.put("mail.smtp.localhost", "localhost");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASSWORD);
            }
        });
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SMTP_USER, FROM_NAME, "UTF-8"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject, "UTF-8");
        return message;
    }

    private static Properties loadFileConfig() {
        Properties props = new Properties();
        try (InputStream in = EmailService.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (in != null) {
                props.load(new java.io.InputStreamReader(in, java.nio.charset.StandardCharsets.UTF_8));
            }
        } catch (IOException e) {
            LOGGER.log(Level.WARNING, "Cannot read mail.properties", e);
        }
        return props;
    }

    /** Biến môi trường > mail.properties (bỏ qua giá trị mẫu "YOUR_...") > mặc định. */
    private static String config(String envName, String fileKey, String defaultValue) {
        String value = System.getenv(envName);
        if (value == null || value.isBlank()) {
            value = FILE_CONFIG.getProperty(fileKey);
        }
        if (value == null || value.isBlank() || value.trim().startsWith("YOUR_")) {
            return defaultValue;
        }
        return value.trim();
    }
}
