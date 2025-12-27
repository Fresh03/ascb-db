package ro.ascb.frontend.model;

import java.time.LocalDate;

public class Voluntar {
    private long id; // <- adaugă acest câmp
    private String nume;
    private String prenume;
    private LocalDate dataIntrare;
    private String status;
    private int oreVoluntariat;
    private String descriere;


    // Constructor complet
    public Voluntar(long id, String nume, String prenume, LocalDate dataIntrare, String status, int oreVoluntariat, String descriere) {
        this.id = id;
        this.nume = nume;
        this.prenume = prenume;
        this.dataIntrare = dataIntrare;
        this.status = status;
        this.oreVoluntariat = oreVoluntariat;
        this.descriere = descriere;
    }

    // Constructor fără id (pentru inserție nouă)
    public Voluntar(String nume, String prenume, LocalDate dataIntrare, String status, int oreVoluntariat, String descriere) {
        this.nume = nume;
        this.prenume = prenume;
        this.dataIntrare = dataIntrare;
        this.status = status;
        this.oreVoluntariat = oreVoluntariat;
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
    public String getNume() {
        return nume;
    }

    public void setNume(String nume) {
        this.nume = nume;
    }

    public String getPrenume() {
        return prenume;
    }

    public void setPrenume(String prenume) {
        this.prenume = prenume;
    }

    public LocalDate getDataIntrare() {
        return dataIntrare;
    }

    public void setDataIntrare(LocalDate dataIntrare) {
        this.dataIntrare = dataIntrare;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getOreVoluntariat() {
        return oreVoluntariat;
    }

    public void setOreVoluntariat(int oreVoluntariat) {
        this.oreVoluntariat = oreVoluntariat;
    }

    public String getDescriere() {
        return descriere;
    }

    public void setDescriere(String descriere) {
        this.descriere = descriere;
    }
}
