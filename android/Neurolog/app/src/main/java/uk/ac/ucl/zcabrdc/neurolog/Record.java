package uk.ac.ucl.zcabrdc.neurolog;

import java.util.ArrayList;
import java.util.Date;

import io.realm.RealmList;
import io.realm.RealmObject;

public class Record extends RealmObject {
    private Date date;
    private String location;
    private String setting;
    private String title = null;
    private String lecturer = null;
    private String topic = null;
    private Boolean supervisor;
    private String name = null;
    private RealmList<Case> cases;

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getSetting() {
        return setting;
    }

    public void setSetting(String setting) {
        this.setting = setting;
    }

    public Boolean getSupervisor() {
        return supervisor;
    }

    public void setSupervisor(Boolean supervisor) {
        this.supervisor = supervisor;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getTopic() {
        return topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getLecturer() {
        return lecturer;
    }

    public void setLecturer(String lecturer) {
        this.lecturer = lecturer;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public RealmList<Case> getCases() {
        return cases;
    }

    public void setCases(RealmList<Case> cases) {
        this.cases = cases;
    }
}
