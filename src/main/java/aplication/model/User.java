package aplication.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;
import java.util.Objects;

@Validated
public class User {

    private String nickname;

    private String email;


    private String fullname;

    private String about;

    public User(@JsonProperty("about") String about,
                @JsonProperty("email") String email,
                @JsonProperty("fullname") String fullname,
                @JsonProperty("nickname") String nickname){
        this.nickname = nickname;
        this.email = email;
        this.fullname = fullname;
        this.about = about;
    }


    public String getNickname() {
        return nickname;
    }

    public String getEmail() {
        return email;
    }

    public String getFullname() {
        return fullname;
    }

    public String getAbout() {
        return about;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setAbout(String about) {
        this.about = about;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    @Override
    public boolean equals(java.lang.Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        User user = (User) o;
        return Objects.equals(this.about, user.about) &&
                Objects.equals(this.email, user.email) &&
                Objects.equals(this.fullname, user.fullname) &&
                Objects.equals(this.nickname, user.nickname);
    }

    @Override
    public int hashCode() {
        return Objects.hash(about, email, fullname, nickname);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("class User {\n");

        sb.append("    about: ").append(toIndentedString(about)).append("\n");
        sb.append("    email: ").append(toIndentedString(email)).append("\n");
        sb.append("    fullname: ").append(toIndentedString(fullname)).append("\n");
        sb.append("    nickname: ").append(toIndentedString(nickname)).append("\n");
        sb.append("}");
        return sb.toString();
    }

    /**
     * Convert the given object to string with each line indented by 4 spaces
     * (except the first line).
     */
    private String toIndentedString(java.lang.Object o) {
        if (o == null) {
            return "null";
        }
        return o.toString().replace("\n", "\n    ");
    }

}
