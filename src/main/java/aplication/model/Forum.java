package aplication.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.NotNull;
import java.math.BigInteger;

@Validated
public class Forum {

    @JsonIgnoreProperties
    private Integer id;

    @JsonProperty("posts")
    private Integer posts = 0;

    @JsonProperty("slug")
    private final String slug;

    @JsonProperty("threads")
    private Integer threads = 0;

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

    public Forum(Integer id, Integer posts, Integer threads, String slug, String title, String user) {
        this.id = id;
        this.posts = posts;
        this.threads = threads;
        this.slug = slug;
        this.title = title;
        this.user = user;
    }

    public Integer getPosts() {
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

    public Integer getThreads() {
        return threads;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public Integer getId() {
        return id;
    }
}
