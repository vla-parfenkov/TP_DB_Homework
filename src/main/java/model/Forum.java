package model;

import javax.validation.constraints.NotNull;

public class Forum {

    @NotNull
    private final long id;

    private long posts;

    @NotNull
    private final String slug;

    private long threads;

    @NotNull
    private final String title;

    private String user;

    public Forum(long id, long posts, String slug, long threads, String title, String user){

        this.id = id;
        this.posts = posts;
        this.slug = slug;
        this.threads = threads;
        this.title = title;
        this.user = user;
    }

    public long getId() {
        return id;
    }

    public long getPosts() {
        return posts;
    }

    public long getThreads() {
        return threads;
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


    public void newPost (){
        posts++;
    }

    public void newThreads(){
        threads++;
    }

    public void setUser(String user) {
        this.user = user;
    }

}
