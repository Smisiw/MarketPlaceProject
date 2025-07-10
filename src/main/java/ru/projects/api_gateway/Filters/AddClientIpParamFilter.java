package ru.projects.api_gateway.Filters;

import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.Optional;

@Component
public class AddClientIpParamFilter extends AbstractGatewayFilterFactory<Object> {

    @Override
    public GatewayFilter apply(Object config) {
        return (exchange, chain) -> {
            String clientIp = Optional.ofNullable(exchange.getRequest().getRemoteAddress())
                    .map(addr -> addr.getAddress().getHostAddress())
                    .orElse("127.0.0.1");
            System.out.println(123);
            URI originalUri = exchange.getRequest().getURI();
            String newQuery = originalUri.getQuery();

            newQuery = (newQuery == null || newQuery.isEmpty())
                    ? "ip=" + clientIp
                    : newQuery;

            URI newUri = UriComponentsBuilder.fromUri(originalUri)
                    .replaceQuery(newQuery)
                    .build(true)
                    .toUri();

            ServerHttpRequest newRequest = exchange.getRequest()
                    .mutate()
                    .uri(newUri)
                    .build();

            return chain.filter(exchange.mutate().request(newRequest).build());
        };
    }
}