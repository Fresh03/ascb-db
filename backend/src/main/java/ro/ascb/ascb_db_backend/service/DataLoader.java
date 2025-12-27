package ro.ascb.ascb_db_backend.service;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import ro.ascb.ascb_db_backend.model.Admin;
import ro.ascb.ascb_db_backend.repository.AdminRepository;

// Clasă care rulează la pornirea aplicației (CommandLineRunner)
// Servește pentru a inițializa date în baza de date (ex: un admin default)
@Component
public class DataLoader implements CommandLineRunner {

    private final AdminRepository adminRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    // Constructor cu injectare AdminRepository
    public DataLoader(AdminRepository adminRepository) {
        this.adminRepository = adminRepository;
        this.passwordEncoder = new BCryptPasswordEncoder(); // Inițializează encoder pentru hash parolă
    }

    // Metoda run() se execută la pornirea aplicației
    @Override
    public void run(String... args) throws Exception {
        // Dacă nu există deja un admin cu emailul specificat
        if (adminRepository.findByEmail("admin@ascb.ro").isEmpty()) {
            // Creează un admin nou cu parola criptată
            Admin admin = new Admin("admin@ascb.ro", passwordEncoder.encode("parola123"));
            // Salvează adminul în baza de date
            adminRepository.save(admin);
        }
    }
}
