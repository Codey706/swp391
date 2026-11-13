package utils;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class GoogleUtils {

    private static final Logger LOGGER = Logger.getLogger(GoogleUtils.class.getName());

    /** Ghi đè bằng biến môi trường LTM_GOOGLE_CLIENT_ID; mặc định là Client ID dùng chung của nhóm. */
    public static final String GOOGLE_CLIENT_ID = clientId();

    private GoogleUtils() {
    }

    private static String clientId() {
        String value = System.getenv("LTM_GOOGLE_CLIENT_ID");
        return value == null || value.isBlank()
                ? "605419551555-3epj9er66p13sl614tn96ii9jhf8g720.apps.googleusercontent.com"
                : value.trim();
    }

    /** Xác minh ID token với Google; null nếu token sai, hết hạn hoặc không cấp cho ứng dụng này. */
    public static GoogleProfile verifyToken(String credential) {
        try {
            URL url = new URL("https://oauth2.googleapis.com/tokeninfo?id_token="
                    + URLEncoder.encode(credential, StandardCharsets.UTF_8));
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
                LOGGER.warning("Google tokeninfo rejected token, HTTP " + conn.getResponseCode());
                return null;
            }
            JsonObject json;
            try (InputStream in = conn.getInputStream()) {
                json = JsonParser.parseString(new String(in.readAllBytes(), StandardCharsets.UTF_8)).getAsJsonObject();
            }
            if (!json.has("aud") || !GOOGLE_CLIENT_ID.equals(json.get("aud").getAsString())) {
                LOGGER.warning("Google token audience mismatch");
                return null;
            }
            GoogleProfile profile = new GoogleProfile();
            profile.setEmail(json.has("email") ? json.get("email").getAsString() : null);
            profile.setName(json.has("name") ? json.get("name").getAsString() : "Google User");
            return profile;
        } catch (IOException | RuntimeException e) {
            LOGGER.log(Level.WARNING, "Cannot verify Google token", e);
            return null;
        }
    }

    public static class GoogleProfile {

        private String email;
        private String name;

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }
}
