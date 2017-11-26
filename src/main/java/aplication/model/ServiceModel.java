package aplication.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigInteger;

public class ServiceModel {
    @JsonProperty("forum")
    private BigInteger forum;
    @JsonProperty("post")
    private BigInteger post;
    @JsonProperty("thread")
    private BigInteger thread;
    @JsonProperty("user")
    private BigInteger user;

    public ServiceModel(BigInteger forum, BigInteger post, BigInteger thread, BigInteger user) {
        this.forum = forum;
        this.post = post;
        this.thread = thread;
        this.user = user;
    }

    public BigInteger getForum() {
        return forum;
    }

    public void setForum(BigInteger forum) {
        this.forum = forum;
    }

    public BigInteger getPost() {
        return post;
    }

    public void setPost(BigInteger post) {
        this.post = post;
    }

    public BigInteger getThread() {
        return thread;
    }

    public void setThread(BigInteger thread) {
        this.thread = thread;
    }

    public BigInteger getUser() {
        return user;
    }

    public void setUser(BigInteger user) {
        this.user = user;
    }
}
