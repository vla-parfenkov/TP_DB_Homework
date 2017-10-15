package aplication.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.NotNull;

@Validated
public class Forum {

    @JsonIgnoreProperties
    private long id;

    @JsonProperty("posts")
    private long posts = 0;

    @JsonProperty("slug")
    private final String slug;

    @JsonProperty("threads")
    private long threads = 0;

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

    public Forum(long id, long posts, long threads, String slug, String title, String user) {
        this.id = id;
        this.posts = posts;
        this.threads = threads;
        this.slug = slug;
        this.title = title;
        this.user = user;
    }

    public long getPosts() {
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

    public long getThreads() {
        return threads;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public long getId() {
        return id;
    }
}
