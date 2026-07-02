package com.cloudnative.demo.web;

import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class LabController {

    private final JdbcTemplate jdbcTemplate;
    private final StringRedisTemplate redisTemplate;
    private final double slowSeconds;

    public LabController(
            JdbcTemplate jdbcTemplate,
            StringRedisTemplate redisTemplate,
            @Value("${lab.slow-seconds:3}") double slowSeconds) {
        this.jdbcTemplate = jdbcTemplate;
        this.redisTemplate = redisTemplate;
        this.slowSeconds = slowSeconds;
    }

    @GetMapping("/work")
    public Map<String, Object> work() throws InterruptedException {
        double delay = ThreadLocalRandom.current().nextDouble(0.05, 0.35);
        TimeUnit.MILLISECONDS.sleep((long) (delay * 1000));

        Long hits = redisTemplate.opsForValue().increment("lab:hits");
        jdbcTemplate.queryForObject("SELECT 1", Integer.class);

        return Map.of(
                "hits", hits == null ? 0 : hits,
                "delay_ms", Math.round(delay * 1000 * 10) / 10.0);
    }

    @GetMapping("/slow")
    public Map<String, Object> slow() throws InterruptedException {
        TimeUnit.MILLISECONDS.sleep((long) (slowSeconds * 1000));
        return Map.of("status", "slow", "delay_seconds", slowSeconds);
    }

    @GetMapping("/fail")
    public ResponseEntity<Map<String, String>> fail() {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "simulated failure"));
    }
}
