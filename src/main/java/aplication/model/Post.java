package aplication.model;


import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

import java.math.BigInteger;
import java.sql.Timestamp;

@Validated
public class Post {

    @JsonIgnoreProperties
    private Integer id;

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
    private Integer parent = 0;

    public void setId(Integer id) {
        this.id = id;
    }

    @JsonProperty("thread")
    private Integer thread;

    public void setAuthor(String author) {
        this.author = author;
    }

    public void setCreated(Timestamp created) {
        this.created = created;
    }

    public void setForum(String forum) {
        this.forum = forum;
    }

    public void setParent(Integer parent) {
        this.parent = parent;
    }

    public void setThread(Integer thread) {
        this.thread = thread;
    }



    public Post (@JsonProperty("author") String author,
                 @JsonProperty("message") String message,
                 @JsonProperty(value = "parent",
                 defaultValue = "0") Integer parent) {
        this.author = author;
        this.message = message;
        if(parent != null) {
            this.parent = parent;
        }
    }

    public Post(Integer id, String author, Timestamp created, String forum, String message, Integer parent, Integer thread) {
        this.id = id;
        this.author = author;
        this.created = created;
        this.forum = forum;
        this.message = message;
        if(parent != null) {
            this.parent = parent;
        }
        this.thread = thread;
    }

    public Integer getId() {
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

    public String getMessage() {
        return message;
    }

    public Boolean getIsEdited() {
        return isEdited;
    }

    public Integer getParent() {
        return parent;
    }

    public Integer getThread() {
        return thread;
    }

    public void setIsEdited(Boolean edited) {
        isEdited = edited;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
