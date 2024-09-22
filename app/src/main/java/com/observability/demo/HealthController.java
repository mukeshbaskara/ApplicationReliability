package com.observability.demo;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/")
    public String check() {
        return "Application is running";
    }

    @GetMapping("/health")
    public String healthCheck() {
        return "hello world";
    }
}