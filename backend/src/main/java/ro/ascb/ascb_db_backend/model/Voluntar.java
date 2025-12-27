package ro.ascb.ascb_db_backend.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "voluntari")
public class Voluntar {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nume;
    private String prenume;

    @Column(name = "data_intrare")
    private LocalDate dataIntrare;

    private String status;

    @Column(name = "ore_voluntariat")
    private int oreVoluntariat;

    private String descriere;

    public Voluntar() {}

    public Voluntar(Long id, String nume, String prenume, LocalDate dataIntrare, String status, int oreVoluntariat, String descriere) {
        this.id = id;
        this.nume = nume;
        this.prenume = prenume;
        this.dataIntrare = dataIntrare;
        this.status = status;
        this.oreVoluntariat = oreVoluntariat;
        this.descriere = descriere;
    }

    // getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNume() { return nume; }
    public void setNume(String nume) { this.nume = nume; }

    public String getPrenume() { return prenume; }
    public void setPrenume(String prenume) { this.prenume = prenume; }

    public LocalDate getDataIntrare() { return dataIntrare; }
    public void setDataIntrare(LocalDate dataIntrare) { this.dataIntrare = dataIntrare; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getOreVoluntariat() { return oreVoluntariat; }
    public void setOreVoluntariat(int oreVoluntariat) { this.oreVoluntariat = oreVoluntariat; }

    public String getDescriere() { return descriere; }
    public void setDescriere(String descriere) { this.descriere = descriere; }
}
