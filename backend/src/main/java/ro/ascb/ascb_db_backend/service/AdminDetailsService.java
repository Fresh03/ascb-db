package ro.ascb.ascb_db_backend.service;

import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import ro.ascb.ascb_db_backend.model.Admin;
import ro.ascb.ascb_db_backend.repository.AdminRepository;

@Service
public class AdminDetailsService implements UserDetailsService {

    private final AdminRepository adminRepository;

    public AdminDetailsService(AdminRepository adminRepository) {
        this.adminRepository = adminRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Admin admin = adminRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Adminul nu a fost găsit: " + email));

        return User.builder()
                .username(admin.getEmail())
                .password(admin.getPasswordHash())
                .roles("ADMIN")
                .build();
    }
}
