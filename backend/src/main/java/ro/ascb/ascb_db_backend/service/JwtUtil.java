package ro.ascb.ascb_db_backend.service;

import java.security.Key;
import java.util.Date;

import org.springframework.stereotype.Service;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtUtil {

    // cheia secretă pentru semnătura tokenului
    private final Key key = Keys.secretKeyFor(SignatureAlgorithm.HS256);

    // durata de viață a tokenului (1 oră)
    private final long expiration = 3600000;

    // generăm token
    public String generateToken(String email) {
        return Jwts.builder()
                .setSubject(email)
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(key)
                .compact();
    }

    // validăm token și returnăm email-ul
    public String validateToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }
}
