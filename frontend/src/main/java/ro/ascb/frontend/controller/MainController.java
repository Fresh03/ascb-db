package ro.ascb.frontend.controller;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.Optional;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.collections.transformation.FilteredList;
import javafx.collections.transformation.SortedList;
import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonBar;
import javafx.scene.control.ButtonType;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;
import ro.ascb.frontend.model.Eveniment;
import ro.ascb.frontend.model.Voluntar;

public class MainController {

    // TableView Evenimente
    @FXML
    private TableView<Eveniment> evenimenteTable;
    @FXML
    private TableColumn<Eveniment, String> colDenumire;
    @FXML
    private TableColumn<Eveniment, LocalDate> colData;
    @FXML
    private TableColumn<Eveniment, String> colDescriere;

    @FXML
    private ComboBox<Eveniment> comboEvenimenteDisponibile;

    // TableView Voluntari
    @FXML
    private TableView<Voluntar> voluntariTable;
    @FXML
    private TableColumn<Voluntar, String> colNume;
    @FXML
    private TableColumn<Voluntar, String> colPrenume;
    @FXML
    private TableColumn<Voluntar, LocalDate> colDataIntrare;
    @FXML
    private TableColumn<Voluntar, String> colStatus;

    @FXML private TableColumn<Voluntar, Integer> colOreVoluntariat;
    @FXML private TableColumn<Voluntar, String> colDescriereVoluntar;

    @FXML private TextField txtOreVoluntariat;
    @FXML private TextArea txtDescriereVoluntar;


    // Panou detalii voluntar
    @FXML
    private AnchorPane detailsPane;
    @FXML
    private TextField txtNume;
    @FXML
    private TextField txtPrenume;
    @FXML
    private DatePicker dataIntrare;
    @FXML
    private ComboBox<String> statusCombo;

    // Search controls
    @FXML
    private TextField txtSearch;
    @FXML
    private Button searchBtn;
    @FXML
    private Button clearSearchBtn;
    @FXML
    private HBox searchBar;

    @FXML
    private Label lblUltimaParticipare;
    @FXML
    private ListView<Eveniment> listEvenimenteVoluntar;
    @FXML
    private Button adaugaEvenimentBtn;

    @FXML
    private Button salveazaBtn;
    @FXML
    private Button stergeBtn;

    // Panou detalii eveniment
    @FXML private AnchorPane eventDetailsPane;
    @FXML private TextField txtDenumireEveniment;
    @FXML private DatePicker dataEvenimentPicker;
    @FXML private TextArea txtDescriereEveniment;
    @FXML private Button salveazaEvenimentBtn;
    @FXML private Button btnStergeEveniment;

    private Eveniment evenimentSelectat = null;
    private boolean adaugareEvenimentNou = false;

    // Buton adăugare voluntar
    @FXML
    private Button adaugaVoluntarBtn;

    private boolean voluntariTableInitializat = false;
    private Voluntar voluntarSelectat = null;
    private boolean adaugareNoua = false;

    // In-memory lists for search/filtering
    private final ObservableList<Voluntar> allVoluntari = FXCollections.observableArrayList();
    private FilteredList<Voluntar> filteredVoluntari;

    // --- Inițializare ---
    @FXML
    private void initialize() {
        // Inițializare coloane evenimente
        colDenumire.setCellValueFactory(new PropertyValueFactory<>("denumire"));
        colData.setCellValueFactory(new PropertyValueFactory<>("data"));
        colDescriere.setCellValueFactory(new PropertyValueFactory<>("descriere"));
            eventDetailsPane.setVisible(false);
            salveazaEvenimentBtn.setVisible(false);
            adaugaEvenimentBtn.setVisible(false);


        // Ascund voluntari și panoul de detalii

        voluntariTable.setVisible(false);
        detailsPane.setVisible(false);
        adaugaVoluntarBtn.setVisible(false);
        salveazaBtn.setVisible(false);

        listEvenimenteVoluntar.setCellFactory(lv -> new javafx.scene.control.ListCell<>() {
        @Override
        protected void updateItem(Eveniment item, boolean empty) {
            super.updateItem(item, empty);
            setText(empty || item == null ? "" : item.getDenumire() + " (" + item.getData() + ")");
        }
    });
        // ensure search bar hidden until Voluntari is pressed
        if (searchBar != null) searchBar.setVisible(false);
        
    }

    // --- Evenimente ---
    @FXML
    private void handleEvenimente() {
        System.out.println("Buton Evenimente apăsat!");
        if (searchBar != null) searchBar.setVisible(false);
        evenimenteTable.setVisible(true);
        voluntariTable.setVisible(false);
        detailsPane.setVisible(false);
        adaugaVoluntarBtn.setVisible(false);

        adaugaEvenimentBtn.setVisible(true);
        eventDetailsPane.setVisible(false);
        salveazaEvenimentBtn.setVisible(false);

        ObservableList<Eveniment> evenimente = FXCollections.observableArrayList();

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ascb_db", "fresh", "fresh");
            PreparedStatement stmt = conn.prepareStatement(
                    "SELECT id, denumire, data_eveniment, descriere FROM evenimente ORDER BY data_eveniment DESC");
            ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                long id = rs.getLong("id");
                String denumire = rs.getString("denumire");
                LocalDate data = rs.getDate("data_eveniment").toLocalDate();
                String descriere = rs.getString("descriere");
                evenimente.add(new Eveniment(id, denumire, data, descriere));
            }

            evenimenteTable.setItems(evenimente);

            // listener pentru detalii
            evenimenteTable.getSelectionModel().selectedItemProperty().addListener(
                (obs, oldSel, newSel) -> {
                    if (newSel != null) {
                        adaugareEvenimentNou = false;
                        evenimentSelectat = newSel;
                        showEvenimentDetails(newSel);
                        btnStergeEveniment.setVisible(true);
                    }
                });

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void showEvenimentDetails(Eveniment eveniment) {
        txtDenumireEveniment.setText(eveniment.getDenumire());
        dataEvenimentPicker.setValue(eveniment.getData());
        txtDescriereEveniment.setText(eveniment.getDescriere());

        eventDetailsPane.setVisible(true);
        salveazaEvenimentBtn.setVisible(true);
    }

    @FXML
    private void handleAdaugaEveniment() {
        evenimentSelectat = null;
        adaugareEvenimentNou = true;

        txtDenumireEveniment.clear();
        dataEvenimentPicker.setValue(null);
        txtDescriereEveniment.clear();

        eventDetailsPane.setVisible(true);
        salveazaEvenimentBtn.setVisible(true);
    }

    @FXML
    private void handleSalveazaEveniment() {
        String denumire = txtDenumireEveniment.getText();
        LocalDate data = dataEvenimentPicker.getValue();
        String descriere = txtDescriereEveniment.getText();

        if (denumire == null || denumire.isEmpty() || data == null || descriere == null || descriere.isEmpty()) {
            System.out.println("Toate câmpurile sunt obligatorii!");
            return;
        }

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ascb_db", "fresh", "fresh")) {

            if (adaugareEvenimentNou) {
                String insertSQL = "INSERT INTO evenimente (denumire, data_eveniment, descriere) VALUES (?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS);
                stmt.setString(1, denumire);
                stmt.setDate(2, java.sql.Date.valueOf(data));
                stmt.setString(3, descriere);
                stmt.executeUpdate();

                ResultSet rsKeys = stmt.getGeneratedKeys();
                if (rsKeys.next()) {
                    long generatedId = rsKeys.getLong(1);
                    evenimentSelectat = new Eveniment(generatedId, denumire, data, descriere); 
                }

                System.out.println("Eveniment adăugat cu succes!");
            } else if (evenimentSelectat != null) {
                String updateSQL = "UPDATE evenimente SET denumire=?, data_eveniment=?, descriere=? WHERE denumire=? AND data_eveniment=?";
                PreparedStatement stmt = conn.prepareStatement(updateSQL);
                stmt.setString(1, denumire);
                stmt.setDate(2, java.sql.Date.valueOf(data));
                stmt.setString(3, descriere);
                stmt.setString(4, evenimentSelectat.getDenumire());
                stmt.setDate(5, java.sql.Date.valueOf(evenimentSelectat.getData()));
                stmt.executeUpdate();
                System.out.println("Eveniment actualizat cu succes!");
            }

            handleEvenimente(); // refresh tabel
            eventDetailsPane.setVisible(false);
            salveazaEvenimentBtn.setVisible(false);

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @FXML
    private void handleStergeEveniment() {
        if (evenimentSelectat == null) {
            Alert warning = new Alert(Alert.AlertType.WARNING);
            warning.setTitle("Atenție");
            warning.setHeaderText("Niciun eveniment selectat");
            warning.setContentText("Selectează un eveniment înainte să îl ștergi.");
            warning.showAndWait();
            return;
        }

        // popup confirmare
        Alert confirm = new Alert(Alert.AlertType.CONFIRMATION);
        confirm.setTitle("Confirmare ștergere");
        confirm.setHeaderText("Ești sigur că vrei să ștergi acest eveniment?");
        confirm.setContentText("Eveniment: " + evenimentSelectat.getDenumire() 
                            + " (" + evenimentSelectat.getData() + ")");
        
        if (confirm.showAndWait().get() == ButtonType.OK) {
            try (Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/ascb_db", "fresh", "fresh")) {

                // Șterge legăturile din voluntar_eveniment
                PreparedStatement stmt1 = conn.prepareStatement(
                    "DELETE FROM voluntar_eveniment WHERE eveniment_id=?");
                stmt1.setLong(1, evenimentSelectat.getId());
                stmt1.executeUpdate();

                // Șterge evenimentul propriu-zis
                PreparedStatement stmt2 = conn.prepareStatement(
                    "DELETE FROM evenimente WHERE id=?");
                stmt2.setLong(1, evenimentSelectat.getId());
                stmt2.executeUpdate();

                System.out.println("Eveniment șters cu succes!");

                // Refresh tabel
                handleEvenimente();
                eventDetailsPane.setVisible(false);
                salveazaEvenimentBtn.setVisible(false);

            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // --- Voluntari ---
    @FXML
private void handleVoluntari() {
    System.out.println("Buton Voluntari apăsat!");
        if (searchBar != null) searchBar.setVisible(true);
    eventDetailsPane.setVisible(false);
    adaugaEvenimentBtn.setVisible(false);
    voluntariTable.setVisible(true);
    evenimenteTable.setVisible(false);
    detailsPane.setVisible(false);
    adaugaVoluntarBtn.setVisible(true);

    if (!voluntariTableInitializat) {
        setupVoluntariTable();
        voluntariTableInitializat = true;
    }

    ObservableList<Voluntar> voluntari = FXCollections.observableArrayList();

    // Fetch volunteers from backend REST API instead of direct JDBC.
    try {
        String backend = getBackendUrl();
        java.net.http.HttpClient client = java.net.http.HttpClient.newHttpClient();
        java.net.http.HttpRequest request = java.net.http.HttpRequest.newBuilder()
                .uri(java.net.URI.create(backend + "/api/voluntari"))
                .GET()
                .build();

        java.net.http.HttpResponse<String> response = client.send(request, java.net.http.HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() == 200) {
            String body = response.body();
            // Very small, tolerant JSON parser for the expected backend shape (array of objects).
            // This avoids adding runtime JSON dependencies which may not resolve in some environments.
            java.util.regex.Pattern objPattern = java.util.regex.Pattern.compile("\\{(.*?)\\}", java.util.regex.Pattern.DOTALL);
            java.util.regex.Matcher m = objPattern.matcher(body);
            while (m.find()) {
                String obj = m.group(1);
                long id = safeParseLong(extractJsonValue(obj, "id"));
                String nume = unquote(extractJsonValue(obj, "nume"));
                String prenume = unquote(extractJsonValue(obj, "prenume"));
                String dataStr = unquote(extractJsonValue(obj, "dataIntrare"));
                java.time.LocalDate data = (dataStr == null || dataStr.isEmpty() || dataStr.equals("null")) ? null : java.time.LocalDate.parse(dataStr);
                String status = unquote(extractJsonValue(obj, "status"));
                int ore = safeParseInt(extractJsonValue(obj, "oreVoluntariat"));
                String descriere = unquote(extractJsonValue(obj, "descriere"));

                voluntari.add(new Voluntar(id, nume, prenume, data, status, ore, descriere));
            }

            // sortare: status + data_intrare desc
            voluntari.sort(Comparator
                    .comparing((Voluntar v) -> getStatusPriority(v.getStatus()))
                    .thenComparing(Voluntar::getDataIntrare, Comparator.reverseOrder()));

            // populate the backing list used by the filtered view
            allVoluntari.setAll(voluntari);
            System.out.println("Total voluntari încărcați (REST): " + voluntari.size());
        } else {
            System.out.println("Backend returned status: " + response.statusCode());
        }
    } catch (Exception e) {
        e.printStackTrace();
        System.out.println("Eroare la încărcarea voluntarilor via REST!");
    }
}

    // Helper to resolve backend base URL (same logic as LoginController)
    private String getBackendUrl() {
        String prop = System.getProperty("backend.url");
        if (prop != null && !prop.isEmpty()) return prop;
        String env = System.getenv("BACKEND_URL");
        if (env != null && !env.isEmpty()) return env;
        return "http://localhost:8080";
    }

    // Lightweight JSON helpers (tolerant) to avoid adding runtime JSON deps.
    private static String extractJsonValue(String obj, String key) {
        java.util.regex.Pattern p = java.util.regex.Pattern.compile("\"" + java.util.regex.Pattern.quote(key) + "\"\\s*:\\s*(\\\".*?\\\"|[^,}]+)", java.util.regex.Pattern.DOTALL);
        java.util.regex.Matcher m = p.matcher(obj);
        if (m.find()) {
            return m.group(1).trim();
        }
        return null;
    }

    private static String unquote(String s) {
        if (s == null) return null;
        s = s.trim();
        if (s.equals("null")) return null;
        if (s.startsWith("\"") && s.endsWith("\"") && s.length() >= 2) {
            String inner = s.substring(1, s.length() - 1);
            // minimal unescape for common sequences
            inner = inner.replaceAll("\\\\\\\"", "\"");
            inner = inner.replaceAll("\\\\", "\\");
            return inner;
        }
        return s;
    }

    private static long safeParseLong(String s) {
        try {
            if (s == null) return 0L;
            s = s.replaceAll("[\\\"\\s]", "");
            return Long.parseLong(s);
        } catch (Exception e) {
            return 0L;
        }
    }

    private static int safeParseInt(String s) {
        try {
            if (s == null) return 0;
            s = s.replaceAll("[\\\"\\s]", "");
            return Integer.parseInt(s);
        } catch (Exception e) {
            return 0;
        }
    }

private void setupVoluntariTable() {
    // Asociază coloanele cu proprietățile din clasa Voluntar
    colNume.setCellValueFactory(new PropertyValueFactory<>("nume"));
    colPrenume.setCellValueFactory(new PropertyValueFactory<>("prenume"));
    colDataIntrare.setCellValueFactory(new PropertyValueFactory<>("dataIntrare"));
    colStatus.setCellValueFactory(new PropertyValueFactory<>("status"));
    colOreVoluntariat.setCellValueFactory(new PropertyValueFactory<>("oreVoluntariat"));
    colDescriereVoluntar.setCellValueFactory(new PropertyValueFactory<>("descriere"));

    // Formatare frumoasă pentru data intrării (opțional)
    colDataIntrare.setCellFactory(column -> new TableCell<Voluntar, LocalDate>() {
        @Override
        protected void updateItem(LocalDate date, boolean empty) {
            super.updateItem(date, empty);
            if (empty || date == null) {
                setText(null);
            } else {
                setText(date.toString());
            }
        }
    });

    // Prepare filtered list backed by allVoluntari and wire sorting
    filteredVoluntari = new FilteredList<>(allVoluntari, p -> true);
    SortedList<Voluntar> sortedList = new SortedList<>(filteredVoluntari);
    sortedList.comparatorProperty().bind(voluntariTable.comparatorProperty());
    voluntariTable.setItems(sortedList);

    // Wire search text field to update the filter (if it exists)
    if (txtSearch != null) {
        txtSearch.textProperty().addListener((obs, oldText, newText) -> updateFilter(newText));
    }

    // Add selection listener so clicking a row shows details
    voluntariTable.getSelectionModel().selectedItemProperty().addListener((obs, oldSel, newSel) -> {
        if (newSel != null) {
            voluntarSelectat = newSel;
            adaugareNoua = false;
            showVoluntarDetails(newSel);
        } else {
            // no selection
            showVoluntarDetails(null);
        }
    });
}

    // Update filtered list predicate according to search text (searches Nume + Prenume)
    private void updateFilter(String text) {
        if (filteredVoluntari == null) return;
        final String q = text == null ? "" : text.trim().toLowerCase();
        if (q.isEmpty()) {
            filteredVoluntari.setPredicate(v -> true);
            return;
        }
        filteredVoluntari.setPredicate(v -> {
            String nume = v.getNume() == null ? "" : v.getNume();
            String prenume = v.getPrenume() == null ? "" : v.getPrenume();
            String combined = (nume + " " + prenume).toLowerCase();
            return combined.contains(q) || nume.toLowerCase().contains(q) || prenume.toLowerCase().contains(q);
        });
    }

    @FXML
    private void applySearch() {
        if (txtSearch != null) updateFilter(txtSearch.getText());
    }

    @FXML
    private void clearSearch() {
        if (txtSearch != null) txtSearch.clear();
    }

    @FXML
    private void handleAdaugaEvenimentVoluntar() {
        Eveniment evSelectat = comboEvenimenteDisponibile.getSelectionModel().getSelectedItem();
        if (evSelectat == null || voluntarSelectat == null) return;

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ascb_db", "fresh", "fresh")) {

            // verifică dacă deja există legătura
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM voluntar_eveniment WHERE voluntar_id=? AND eveniment_id=?"
            );
            checkStmt.setLong(1, voluntarSelectat.getId());
            checkStmt.setLong(2, evSelectat.getId());
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("Evenimentul este deja asociat acestui voluntar!");
                return;
            }

            // inserează legătura
            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO voluntar_eveniment (voluntar_id, eveniment_id) VALUES (?, ?)"
            );
            stmt.setLong(1, voluntarSelectat.getId());
            stmt.setLong(2, evSelectat.getId());
            stmt.executeUpdate();

            // REÎNCARCĂ lista de evenimente din DB
            ObservableList<Eveniment> evenimenteVoluntar = FXCollections.observableArrayList();
            LocalDate ultimaData = null;

            PreparedStatement reloadStmt = conn.prepareStatement(
                "SELECT e.id, e.denumire, e.data_eveniment, e.descriere " +
                "FROM evenimente e " +
                "JOIN voluntar_eveniment ve ON e.id = ve.eveniment_id " +
                "WHERE ve.voluntar_id = ? " +
                "ORDER BY e.data_eveniment DESC"
            );
            reloadStmt.setLong(1, voluntarSelectat.getId());
            ResultSet rsReload = reloadStmt.executeQuery();

            while (rsReload.next()) {
                Eveniment ev = new Eveniment(
                        rsReload.getLong("id"),
                        rsReload.getString("denumire"),
                        rsReload.getDate("data_eveniment").toLocalDate(),
                        rsReload.getString("descriere")
                );
                evenimenteVoluntar.add(ev);

                if (ultimaData == null || ev.getData().isAfter(ultimaData)) {
                    ultimaData = ev.getData();
                }
            }

            listEvenimenteVoluntar.setItems(evenimenteVoluntar);
            lblUltimaParticipare.setText(ultimaData != null ? ultimaData.toString() : "-");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @FXML
    private void handleStergeEvenimentVoluntar() {
        Eveniment evSelectat = listEvenimenteVoluntar.getSelectionModel().getSelectedItem();
        if (voluntarSelectat == null || evSelectat == null) return;

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ascb_db", "fresh", "fresh");
            PreparedStatement stmt = conn.prepareStatement(
                "DELETE FROM voluntar_eveniment WHERE voluntar_id=? AND eveniment_id=?")) {

            stmt.setLong(1, voluntarSelectat.getId());
            stmt.setLong(2, evSelectat.getId());
            stmt.executeUpdate();

            listEvenimenteVoluntar.getItems().remove(evSelectat);

            // recalculare ultima participare
            LocalDate ultima = listEvenimenteVoluntar.getItems().stream()
                    .map(Eveniment::getData)
                    .max(LocalDate::compareTo)
                    .orElse(null);
            lblUltimaParticipare.setText(ultima != null ? ultima.toString() : "-");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void showVoluntarDetails(Voluntar voluntar) {
        if (voluntar == null) {
            // Dacă nu e selectat voluntar, ascunde panoul
            detailsPane.setVisible(false);
            salveazaBtn.setVisible(false);
            stergeBtn.setVisible(false);
            return;
        }

        // Populare câmpuri de bază
        txtNume.setText(voluntar.getNume());
        txtPrenume.setText(voluntar.getPrenume());
        dataIntrare.setValue(voluntar.getDataIntrare());
        statusCombo.setValue(voluntar.getStatus());

        // Populare câmpuri noi
        txtOreVoluntariat.setText(String.valueOf(voluntar.getOreVoluntariat()));
        txtDescriereVoluntar.setText(voluntar.getDescriere() != null ? voluntar.getDescriere() : "");

        ObservableList<Eveniment> evenimenteVoluntar = FXCollections.observableArrayList();
        ObservableList<Eveniment> toateEvenimentele = FXCollections.observableArrayList();
        LocalDate ultimaData = null;

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ascb_db", "fresh", "fresh")) {

            // --- Încarcă evenimentele asociate voluntarului ---
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT e.id, e.denumire, e.data_eveniment, e.descriere " +
                    "FROM evenimente e " +
                    "JOIN voluntar_eveniment ve ON e.id = ve.eveniment_id " +
                    "WHERE ve.voluntar_id = ? " +
                    "ORDER BY e.data_eveniment DESC")) {

                stmt.setLong(1, voluntar.getId());
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Eveniment ev = new Eveniment(
                                rs.getLong("id"),
                                rs.getString("denumire"),
                                rs.getDate("data_eveniment").toLocalDate(),
                                rs.getString("descriere")
                        );
                        evenimenteVoluntar.add(ev);

                        if (ultimaData == null || ev.getData().isAfter(ultimaData)) {
                            ultimaData = ev.getData();
                        }
                    }
                }
            }

            // --- Încarcă toate evenimentele disponibile ---
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT id, denumire, data_eveniment, descriere FROM evenimente");
                ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    Eveniment ev = new Eveniment(
                            rs.getLong("id"),
                            rs.getString("denumire"),
                            rs.getDate("data_eveniment").toLocalDate(),
                            rs.getString("descriere")
                    );
                    toateEvenimentele.add(ev);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Setează listele în UI
        listEvenimenteVoluntar.setItems(evenimenteVoluntar);
        lblUltimaParticipare.setText(ultimaData != null ? ultimaData.toString() : "-");
        comboEvenimenteDisponibile.setItems(toateEvenimentele);

        // Afișează panoul de detalii
        detailsPane.setVisible(true);
        salveazaBtn.setVisible(true);
        stergeBtn.setVisible(true);
    }


    // --- Adăugare voluntar ---
    @FXML
    private void handleAdaugaVoluntar() {
        voluntarSelectat = null;
        adaugareNoua = true;

        txtNume.clear();
        txtPrenume.clear();
        dataIntrare.setValue(null);

        if (statusCombo.getItems().isEmpty()) {
            statusCombo.setItems(FXCollections.observableArrayList("activ", "semi-activ", "inactiv"));
        }
        statusCombo.setValue(null);

        detailsPane.setVisible(true);
        salveazaBtn.setVisible(true);
    }

    // --- Salvare voluntar ---
    @FXML
    private void handleSalveazaVoluntar() {
        String nume = txtNume.getText();
        String prenume = txtPrenume.getText();
        LocalDate dataIntrareVal = dataIntrare.getValue();
        String status = statusCombo.getValue();
        String descriere = txtDescriereVoluntar.getText();
        int oreVoluntariat = 0;

        try {
            if (!txtOreVoluntariat.getText().isEmpty()) {
                oreVoluntariat = Integer.parseInt(txtOreVoluntariat.getText());
            }
        } catch (NumberFormatException e) {
            System.out.println("Numărul de ore trebuie să fie un număr valid!");
            return;
        }

        if (nume == null || nume.isEmpty()
                || prenume == null || prenume.isEmpty()
                || dataIntrareVal == null
                || status == null) {
            System.out.println("Toate câmpurile sunt obligatorii!");
            return;
        }

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ascb_db", "fresh", "fresh")) {

            if (adaugareNoua) {
                String insertSQL = "INSERT INTO voluntari (nume, prenume, data_intrare, status, ore_voluntariat, descriere) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS);
                stmt.setString(1, nume);
                stmt.setString(2, prenume);
                stmt.setDate(3, java.sql.Date.valueOf(dataIntrareVal));
                stmt.setString(4, status);
                stmt.setInt(5, oreVoluntariat);
                stmt.setString(6, descriere);
                stmt.executeUpdate();

                ResultSet rsKeys = stmt.getGeneratedKeys();
                if (rsKeys.next()) {
                    long generatedId = rsKeys.getLong(1);
                    voluntarSelectat = new Voluntar(generatedId, nume, prenume, dataIntrareVal, status, oreVoluntariat, descriere);
                }

                System.out.println("Voluntar adăugat cu succes!");
            } else if (voluntarSelectat != null) {
                String updateSQL = "UPDATE voluntari SET nume=?, prenume=?, data_intrare=?, status=?, ore_voluntariat=?, descriere=? WHERE id=?";
                PreparedStatement stmt = conn.prepareStatement(updateSQL);
                stmt.setString(1, nume);
                stmt.setString(2, prenume);
                stmt.setDate(3, java.sql.Date.valueOf(dataIntrareVal));
                stmt.setString(4, status);
                stmt.setInt(5, oreVoluntariat);
                stmt.setString(6, descriere);
                stmt.setLong(7, voluntarSelectat.getId());
                stmt.executeUpdate();

                System.out.println("Voluntar actualizat cu succes!");
            }

            handleVoluntari(); // refresh tabel
            detailsPane.setVisible(false);
            salveazaBtn.setVisible(false);

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @FXML
    private void handleStergeVoluntar() {
        if (voluntarSelectat == null) {
            System.out.println("Selectează un voluntar înainte de ștergere!");
            return;
        }

        // Popup de confirmare
        Alert alert = new Alert(Alert.AlertType.CONFIRMATION);
        alert.setTitle("Confirmare ștergere");
        alert.setHeaderText("Ești sigur că vrei să ștergi acest voluntar?");
        alert.setContentText("Voluntar: " + voluntarSelectat.getNume() + " " + voluntarSelectat.getPrenume());

        // Butoane personalizate
        ButtonType butonDa = new ButtonType("Da", ButtonBar.ButtonData.OK_DONE);
        ButtonType butonNu = new ButtonType("Nu", ButtonBar.ButtonData.CANCEL_CLOSE);
        alert.getButtonTypes().setAll(butonDa, butonNu);

        // Așteaptă răspuns
        Optional<ButtonType> rezultat = alert.showAndWait();
        if (rezultat.isPresent() && rezultat.get() == butonDa) {
            try (Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/ascb_db", "fresh", "fresh")) {

                // Ștergem întâi legăturile din voluntar_eveniment
                PreparedStatement stmtVE = conn.prepareStatement(
                    "DELETE FROM voluntar_eveniment WHERE voluntar_id = ?");
                stmtVE.setLong(1, voluntarSelectat.getId());
                stmtVE.executeUpdate();

                // Ștergem voluntarul propriu-zis
                PreparedStatement stmt = conn.prepareStatement(
                    "DELETE FROM voluntari WHERE id = ?");
                stmt.setLong(1, voluntarSelectat.getId());
                stmt.executeUpdate();

                System.out.println("Voluntar șters cu succes!");

                // Refresh tabel
                handleVoluntari();

                // Ascunde detaliile
                detailsPane.setVisible(false);
                salveazaBtn.setVisible(false);
                //stergeBtn.setVisible(false);

            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            System.out.println("Ștergerea a fost anulată.");
        }
    }

    // Ajută la sortarea statusurilor
    private int getStatusPriority(String status) {
        return switch (status.toLowerCase()) {
            case "activ" -> 0;
            case "semi-activ" -> 1;
            case "inactiv" -> 2;
            default -> 3;
        };
    }
}
