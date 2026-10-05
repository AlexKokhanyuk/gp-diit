package edu.diploma.deadlocklab;

import edu.diploma.deadlocklab.config.DeleteLabProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(DeleteLabProperties.class)
public class SubjectDeleteDeadlockLabApplication {
    public static void main(String[] args) {
        SpringApplication.run(SubjectDeleteDeadlockLabApplication.class, args);
    }
}












