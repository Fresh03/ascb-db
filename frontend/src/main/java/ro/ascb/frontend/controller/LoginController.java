package ro.ascb.frontend.controller;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

public class LoginController {

    @FXML
    private TextField emailField;

    @FXML
    private PasswordField passwordField;

    @FXML
    private Button loginButton;

    @FXML
    private Label messageLabel;

    @FXML
    private void handleLogin() {
        try {
            String email = emailField.getText();
            String password = passwordField.getText();

            if (email.isEmpty() || password.isEmpty()) {
                messageLabel.setText("Completează toate câmpurile!");
                return;
            }

            // Backend URL is configurable via system property 'backend.url' or environment var 'BACKEND_URL'
            String backendUrl = System.getProperty("backend.url");
            if (backendUrl == null || backendUrl.isBlank()) {
                backendUrl = System.getenv("BACKEND_URL");
            }
            if (backendUrl == null || backendUrl.isBlank()) {
                backendUrl = "http://localhost:8080";
            }

            // Construim POST request
            URL url = new URL(backendUrl + "/auth/login"); // URL-ul API-ului
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            String data = "email=" + email + "&password=" + password;
            try (OutputStream os = conn.getOutputStream()) {
                os.write(data.getBytes(StandardCharsets.UTF_8));
            }

            // Citim răspunsul (handle error stream when response code != 200)
            int code = conn.getResponseCode();
            java.io.InputStream responseStream = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
            Scanner scanner = new Scanner(responseStream, StandardCharsets.UTF_8);
            String response = scanner.useDelimiter("\\A").hasNext() ? scanner.next() : "";
            scanner.close();

            if (code >= 200 && code < 300 && response.equals("Login reușit!")) {
                // Deschide fereastra principală Main.fxml
                FXMLLoader fxmlLoader = new FXMLLoader(getClass().getResource("/fxml/Main.fxml"));
                Parent root = fxmlLoader.load();
                Stage stage = (Stage) loginButton.getScene().getWindow(); // preia fereastra curentă
                stage.setScene(new Scene(root));
                stage.setTitle("ASCb App");
                stage.show();
            } else {
                messageLabel.setText(response.isEmpty() ? ("Eroare: HTTP " + code) : response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            messageLabel.setText("Eroare la conectare: " + e.getMessage());
        }
    }
}
