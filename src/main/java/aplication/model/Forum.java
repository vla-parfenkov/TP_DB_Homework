package aplication.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

@Validated
public class Forum {

    @JsonIgnoreProperties
    private BigDecimal id;

    @JsonProperty("posts")
    private BigDecimal posts = new BigDecimal(0);

    @JsonProperty("slug")
    private final String slug;

    @JsonProperty("threads")
    private BigDecimal threads = new BigDecimal(0);

    @JsonProperty("title")
    private final String title;

    @JsonProperty("user")
    private String user;

    public Forum(@JsonProperty("slug") String slug,
                 @JsonProperty("title") String title,
                 @JsonProperty("user") String user){
        this.slug = slug;
        this.title = title;
        this.user = user;
    }

    public Forum(BigDecimal id, BigDecimal posts, BigDecimal threads, String slug, String title, String user) {
        this.id = id;
        this.posts = posts;
        this.threads = threads;
        this.slug = slug;
        this.title = title;
        this.user = user;
    }

    public BigDecimal getPosts() {
        return posts;
    }

    public String getSlug() {
        return slug;
    }

    public String getTitle() {
        return title;
    }

    public String getUser() {
        return user;
    }

    public BigDecimal getThreads() {
        return threads;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public BigDecimal getId() {
        return id;
    }
}
