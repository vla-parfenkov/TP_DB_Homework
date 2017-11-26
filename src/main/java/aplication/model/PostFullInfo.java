package aplication.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

@Validated
public class PostFullInfo {
    @JsonProperty("author")
    private User author;

    @JsonProperty("forum")
    private Forum forum;

    @JsonProperty("post")
    private Post post;

    public PostFullInfo() {
    }

    @JsonProperty("thread")
    private Thread thread;

    public User getAuthor() {
        return author;
    }

    public void setAuthor(User author) {
        this.author = author;
    }

    public Forum getForum() {
        return forum;
    }

    public void setForum(Forum forum) {
        this.forum = forum;
    }

    public Post getPost() {
        return post;
    }

    public void setPost(Post post) {
        this.post = post;
    }

    public Thread getThread() {
        return thread;
    }

    public void setThread(Thread thread) {
        this.thread = thread;
    }
}
