package utils;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;

public class GoogleUtils {

    
    public static final String GOOGLE_CLIENT_ID = "605419551555-3epj9er66p13sl614tn96ii9jhf8g720.apps.googleusercontent.com";

    public static GoogleProfile verifyToken(String credential) {
        try {
            String urlString = "https://oauth2.googleapis.com/tokeninfo?id_token=" + credential;
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);

            int status = conn.getResponseCode();
            System.out.println("[GoogleUtils] tokeninfo HTTP status: " + status);

           
            BufferedReader reader;
            if (status == 200) {
                reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
            } else {
                reader = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
            }
            String body = reader.lines().collect(Collectors.joining());
            reader.close();
            System.out.println("[GoogleUtils] tokeninfo response: " + body);

            if (status == 200) {
                JsonObject json = new Gson().fromJson(body, JsonObject.class);

               
                String aud = json.has("aud") ? json.get("aud").getAsString() : "";
                System.out.println("[GoogleUtils] aud from token: " + aud);
                System.out.println("[GoogleUtils] expected client_id: " + GOOGLE_CLIENT_ID);

               
                if (aud.equals(GOOGLE_CLIENT_ID)) {
                    GoogleProfile profile = new GoogleProfile();
                    profile.setEmail(json.has("email") ? json.get("email").getAsString() : null);
                    profile.setName(json.has("name") ? json.get("name").getAsString() : "Google User");
                    System.out.println("[GoogleUtils] Verified OK - email: " + profile.getEmail());
                    return profile;
                } else {
                    System.out.println("[GoogleUtils] aud MISMATCH - token rejected");
                }
            }
        } catch (Exception e) {
            System.out.println("[GoogleUtils] Exception: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public static class GoogleProfile {
        private String email;
        private String name;

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
    }
}
