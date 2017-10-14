package model;


import javax.validation.constraints.NotNull;

public class Post {

    @NotNull
    private final long id;

    @NotNull
    private final String author;

    @NotNull
    private final String created;

    @NotNull
    private final String forum;

    private Boolean isEdited = false;

    private String message;

    private final long parent;

    private final long thread;


    public Post(long id, String author, String created, String forum, String message, long parent, long thread) {
        this.id = id;
        this.author = author;
        this.created = created;
        this.forum = forum;
        this.message = message;
        this.parent = parent;
        this.thread = thread;
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

    public String getForum() {
        return forum;
    }

    public Boolean getEdited() {
        return isEdited;
    }

    public String getMessage() {
        return message;
    }

    public long getParent() {
        return parent;
    }

    public long getThread() {
        return thread;
    }

    public void setEdited(Boolean edited) {
        isEdited = edited;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
