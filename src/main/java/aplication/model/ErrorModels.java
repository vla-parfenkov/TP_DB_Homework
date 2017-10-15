package aplication.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ErrorModels {
    @JsonProperty("message")
    private final String message;

    public ErrorModels(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}
