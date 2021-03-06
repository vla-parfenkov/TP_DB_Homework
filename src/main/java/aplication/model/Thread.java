package aplication.model;


import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

import java.math.BigInteger;
import java.sql.Timestamp;
import java.time.OffsetDateTime;

@Validated
public class Thread {

    @JsonIgnoreProperties
    private Integer id;

    @JsonProperty("author")
    private final String author;

    @JsonProperty("created")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX")
    private final Timestamp created;

    @JsonProperty("forum")
    private String forum;

    @JsonProperty("message")
    private String message;

    @JsonIgnoreProperties
    private String slug;

    @JsonProperty("title")
    private String title;

    @JsonProperty("votes")
    private Integer votes = 0;


    public Thread(@JsonProperty("author") String author,
                  @JsonProperty("created") Timestamp created,
                  @JsonProperty("message") String message,
                  @JsonProperty("title") String title) {
        this.author = author;
        this.created = created;
        this.message = message;
        this.title = title;
    }

    public Thread(String author, Timestamp created, String forum, String message, String slug, String title){
        this.author = author;
        this.created = created;
        this.forum = forum;
        this.message = message;
        this.slug = slug;
        this.title = title;
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

    public void setVotes(Integer votes) {
        this.votes = votes;
    }

    public void setId(Integer id) {
        this.id = id;
    }
}
