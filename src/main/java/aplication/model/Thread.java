package aplication.model;


import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.sql.Timestamp;
import java.time.OffsetDateTime;

public class Thread {

    @JsonIgnoreProperties
    private long id;

    @JsonProperty("author")
    private final String author;

    @JsonProperty("created")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX")
    private final Timestamp created;

    @JsonProperty("forum")
    private long forum;

    @JsonProperty("message")
    private String message;

    @JsonProperty("slug")
    private String slug;

    @JsonProperty("title")
    private String title;

    @JsonProperty("votes")
    private int votes = 0;


    public Thread(@JsonProperty("author") String author,
                  @JsonProperty("created") Timestamp created,
                  @JsonProperty("message") String message,
                  @JsonProperty("title") String title) {
        this.author = author;
        this.created = created;
        this.message = message;
        this.title = title;
    }

    public Thread(String author, Timestamp created, long forum, String message, String slug, String title){
        this.author = author;
        this.created = created;
        this.forum = forum;
        this.message = message;
        this.slug = slug;
        this.title = title;
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

    public long getForum() {
        return forum;
    }

    public String getMessage() {
        return message;
    }

    public String getSlug() {
        return slug;
    }

    public String getTitle() {
        return title;
    }

    public int getVotes() {
        return votes;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setVotes(int votes) {
        this.votes = votes;
    }

    public void setId(long id) {
        this.id = id;
    }
}
