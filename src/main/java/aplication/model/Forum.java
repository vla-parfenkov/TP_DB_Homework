package aplication.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.NotNull;
import java.math.BigInteger;

@Validated
public class Forum {

    @JsonIgnoreProperties
    private BigInteger id;

    @JsonProperty("posts")
    private BigInteger posts = BigInteger.valueOf(0);

    @JsonProperty("slug")
    private final String slug;

    @JsonProperty("threads")
    private BigInteger threads = BigInteger.valueOf(0);

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

    public Forum(BigInteger id, BigInteger posts, BigInteger threads, String slug, String title, String user) {
        this.id = id;
        this.posts = posts;
        this.threads = threads;
        this.slug = slug;
        this.title = title;
        this.user = user;
    }

    public BigInteger getPosts() {
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

    public BigInteger getThreads() {
        return threads;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public BigInteger getId() {
        return id;
    }
}
