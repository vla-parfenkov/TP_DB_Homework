package model;

import javax.validation.constraints.NotNull;

public class Thread {

    @NotNull
    private final long id;

    @NotNull
    private final String author;

    @NotNull
    private final String created;

    @NotNull
    private final long forum;

    private String message;

    @NotNull
    private final String slug;

    private String title;

    private int votes = 0;

    public Thread(long id, String author, String created, long forum, String message, String slug, String title) {
        this.id = id;
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

    public String getCreated() {
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


    public void newVoite (){
        votes++;
    }
}
