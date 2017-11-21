package aplication.model;


import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;
import java.sql.Time;
import java.sql.Timestamp;

public class Post {

    @JsonIgnoreProperties
    private long id;

    @JsonProperty("author")
    private String author;

    @JsonProperty("created")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX")
    private Timestamp created;

    @JsonProperty("forum")
    private String forum;

    @JsonProperty("isEdited")
    private Boolean isEdited = false;

    @JsonProperty("message")
    private String message;

    @JsonProperty("parent")
    private long parent = 0;

    public void setId(long id) {
        this.id = id;
    }

    @JsonProperty("thread")
    private long thread;

    public void setAuthor(String author) {
        this.author = author;
    }

    public void setCreated(Timestamp created) {
        this.created = created;
    }

    public void setForum(String forum) {
        this.forum = forum;
    }

    public void setParent(long parent) {
        this.parent = parent;
    }

    public void setThread(long thread) {
        this.thread = thread;
    }

    public Post (@JsonProperty("author") String author,
                 @JsonProperty("message") String message,
                 @JsonProperty("parent") Long parent) {
        this.author = author;
        this.message = message;
        this.parent = parent;
    }

    public Post(long id, String author, Timestamp created, String forum, String message, long parent, long thread) {
        this.id = id;
        this.author = author;
        this.created = created;
        this.forum = forum;
        this.message = message;
        this.parent = parent;
        this.thread = thread;
    }

    public long getId() {
        return id;
    }

    public String getAuthor() {
        return author;
    }

    public Timestamp getCreated() {
        return created;
    }

    public String getForum() {
        return forum;
    }

    public Boolean getEdited() {
        return isEdited;
    }

    public String getMessage() {
        return message;
    }

    public long getParent() {
        return parent;
    }

    public long getThread() {
        return thread;
    }

    public void setEdited(Boolean edited) {
        isEdited = edited;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
