package aplication.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

@Validated
public class ErrorModel {
    @JsonProperty("message")
    private String message = null;

    public ErrorModel(String message) {
        this.message = message;
    }

    public ErrorModel message(String message) {
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
