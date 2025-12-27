package ro.ascb.ascb_db_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ro.ascb.ascb_db_backend.model.Eveniment;

public interface EvenimentRepository extends JpaRepository<Eveniment, Long> {
}
