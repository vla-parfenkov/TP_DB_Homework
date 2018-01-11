package aplication.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigInteger;

public class ServiceModel {
    @JsonProperty("forum")
    private Integer forum;
    @JsonProperty("post")
    private Integer post;
    @JsonProperty("thread")
    private Integer thread;
    @JsonProperty("user")
    private Integer user;

    public ServiceModel(Integer forum, Integer post, Integer thread, Integer user) {
        this.forum = forum;
        this.post = post;
        this.thread = thread;
        this.user = user;
    }

    public Integer getForum() {
        return forum;
    }

    public void setForum(Integer forum) {
        this.forum = forum;
    }

    public Integer getPost() {
        return post;
    }

    public void setPost(Integer post) {
        this.post = post;
    }

    public Integer getThread() {
        return thread;
    }

    public void setThread(Integer thread) {
        this.thread = thread;
    }

    public Integer getUser() {
        return user;
    }

    public void setUser(Integer user) {
        this.user = user;
    }
}
