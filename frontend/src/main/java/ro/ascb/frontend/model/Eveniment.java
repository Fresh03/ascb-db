package ro.ascb.frontend.model;

import java.time.LocalDate;

public class Eveniment {
    private long id; // <- adaugă acest câmp
    private String denumire;
    private LocalDate data;
    private String descriere;

    // Constructor complet
    public Eveniment(long id, String denumire, LocalDate data, String descriere) {
        this.id = id;
        this.denumire = denumire;
        this.data = data;
        this.descriere = descriere;
    }

    // Constructor fără id (pentru inserție nouă)
    public Eveniment(String denumire, LocalDate data, String descriere) {
        this.denumire = denumire;
        this.data = data;
        this.descriere = descriere;
    }

    // Getter și setter pentru id
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    // Gettere și settere pentru celelalte câmpuri
    public String getDenumire() {
        return denumire;
    }

    public void setDenumire(String denumire) {
        this.denumire = denumire;
    }

    public LocalDate getData() {
        return data;
    }

    public void setData(LocalDate data) {
        this.data = data;
    }

    public String getDescriere() {
        return descriere;
    }

    public void setDescriere(String descriere) {
        this.descriere = descriere;
    }

    @Override
    public String toString() {
        return denumire + " (" + data + ")";
    }
}
