package aplication.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

import java.math.BigInteger;

@Validated
public class Vote {

    @JsonIgnoreProperties
    private Integer userId;

    @JsonProperty("nickname")
    private String nickname;

    @JsonProperty("voice")
    private Integer voice;

    @JsonProperty("thread")
    private Integer thread;

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public Integer getVoice() {
        return voice;
    }

    public void setVoice(Integer voice) {
        this.voice = voice;
    }

    public Integer getThread() {
        return thread;
    }

    public void setThread(Integer thread) {
        this.thread = thread;
    }

    public Vote (@JsonProperty("nickname") String nickname,
                 @JsonProperty("voice") Integer voice) {
        this.nickname = nickname;
        this.voice = voice;
    }

    public Vote(String nickname, Integer voice, Integer thread) {
        this.nickname = nickname;
        this.voice = voice;
        this.thread = thread;
    }
}
