package ro.ascb.ascb_db_backend.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "evenimente")
public class Eveniment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String denumire;

    @Column(name = "data_eveniment")
    private LocalDate data;

    private String descriere;

    public Eveniment() {}

    public Eveniment(Long id, String denumire, LocalDate data, String descriere) {
        this.id = id;
        this.denumire = denumire;
        this.data = data;
        this.descriere = descriere;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getDenumire() { return denumire; }
    public void setDenumire(String denumire) { this.denumire = denumire; }

    public LocalDate getData() { return data; }
    public void setData(LocalDate data) { this.data = data; }

    public String getDescriere() { return descriere; }
    public void setDescriere(String descriere) { this.descriere = descriere; }
}
