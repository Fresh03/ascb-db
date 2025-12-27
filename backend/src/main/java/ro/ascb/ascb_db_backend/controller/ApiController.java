package ro.ascb.ascb_db_backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ro.ascb.ascb_db_backend.model.Eveniment;
import ro.ascb.ascb_db_backend.model.Voluntar;
import ro.ascb.ascb_db_backend.repository.EvenimentRepository;
import ro.ascb.ascb_db_backend.repository.VoluntarRepository;

import java.util.List;

@RestController
@RequestMapping("/api")
public class ApiController {

    private final VoluntarRepository voluntarRepo;
    private final EvenimentRepository evenimentRepo;

    public ApiController(VoluntarRepository voluntarRepo, EvenimentRepository evenimentRepo) {
        this.voluntarRepo = voluntarRepo;
        this.evenimentRepo = evenimentRepo;
    }

    @GetMapping("/voluntari")
    public List<Voluntar> getVoluntari() {
        return voluntarRepo.findAll();
    }

    @GetMapping("/evenimente")
    public List<Eveniment> getEvenimente() {
        return evenimentRepo.findAll();
    }
}
