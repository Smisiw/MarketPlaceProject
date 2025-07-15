package ru.projects.api_gateway;

import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.Optional;

@Component
public class AddClientIpParamFilter extends AbstractGatewayFilterFactory<Object> {

    public AddClientIpParamFilter() {
        super(Object.class);
    }

    @Override
    public GatewayFilter apply(Object config) {
        return (exchange, chain) -> {
            String clientIp = Optional.ofNullable(exchange.getRequest().getRemoteAddress())
                    .map(addr -> addr.getAddress().getHostAddress())
                    .orElse("127.0.0.1");

            URI originalUri = exchange.getRequest().getURI();
            String query = originalUri.getQuery();

            String newQuery = (query == null || query.isEmpty())
                    ? "ip=" + clientIp
                    : query + "&ip=" + clientIp;

            URI newUri = UriComponentsBuilder.fromUri(originalUri)
                    .replaceQuery(newQuery)
                    .build(true)
                    .toUri();

            ServerHttpRequest newRequest = exchange.getRequest().mutate().uri(newUri).build();
            return chain.filter(exchange.mutate().request(newRequest).build());
        };
    }
}