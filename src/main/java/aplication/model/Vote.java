package aplication.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.validation.annotation.Validated;

import java.math.BigInteger;

@Validated
public class Vote {

    @JsonIgnoreProperties
    private BigInteger id;

    @JsonProperty("nickname")
    private String nickname;

    @JsonProperty("voice")
    private Integer voice;

    @JsonProperty("thread")
    private BigInteger thread;

    public BigInteger getId() {
        return id;
    }

    public void setId(BigInteger id) {
        this.id = id;
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

    public BigInteger getThread() {
        return thread;
    }

    public void setThread(BigInteger thread) {
        this.thread = thread;
    }

    public Vote (@JsonProperty("nickname") String nickname,
                 @JsonProperty("voice") Integer voice) {
        this.nickname = nickname;
        this.voice = voice;
    }

    public Vote(String nickname, Integer voice, BigInteger thread) {
        this.nickname = nickname;
        this.voice = voice;
        this.thread = thread;
    }
}
