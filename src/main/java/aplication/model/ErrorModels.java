package aplication.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

@Validated
public class ErrorModels {
    @JsonProperty("message")
    private String message = null;

    public ErrorModels(String message) {
        this.message = message;
    }

    public ErrorModels message(String message) {
        this.message = message;
        return this;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
