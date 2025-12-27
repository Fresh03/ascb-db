package ro.ascb.ascb_db_backend.controller;

import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ro.ascb.ascb_db_backend.repository.VoluntarRepository;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/debug")
public class DebugController {

    private final Environment env;
    private final VoluntarRepository voluntarRepository;

    public DebugController(Environment env, VoluntarRepository voluntarRepository) {
        this.env = env;
        this.voluntarRepository = voluntarRepository;
    }

    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, Object> m = new HashMap<>();
        String url = env.getProperty("spring.datasource.url");
        m.put("datasourceUrl", url == null ? "(none)" : url);
        try {
            long cnt = voluntarRepository.count();
            m.put("voluntariCount", cnt);
        } catch (Exception ex) {
            m.put("voluntariCountError", ex.getMessage());
        }
        return m;
    }
}
