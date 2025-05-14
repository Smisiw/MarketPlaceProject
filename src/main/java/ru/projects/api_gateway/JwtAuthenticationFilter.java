package ru.projects.api_gateway;

import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtAuthenticationFilter extends AbstractGatewayFilterFactory<Object> {
    @Value("${jwt.secret}")
    private String secretKey;

    @Override
    public GatewayFilter apply(Object config) {
        return (exchange, chain) -> {
            String token = exchange.getRequest().getHeaders().getFirst("Authorization");

            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
                try {
                    if (!isValidJwt(token)) {
                        throw new JwtValidationException("Invalid token");
                    }
                } catch (JwtValidationException e) {
                    return Mono.error(e);
                }
            }
            return chain.filter(exchange);
        };
    }

    private boolean isValidJwt(String token) {
        JwtParser parser = Jwts.parserBuilder()
                .setSigningKey(Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8)))
                .build();
        Date expiration = parser
                .parseClaimsJws(token)
                .getBody()
                .getExpiration();
        return expiration.before(new Date()) && parser.isSigned(token);
    }
}
