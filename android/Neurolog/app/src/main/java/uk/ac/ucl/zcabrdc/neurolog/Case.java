package uk.ac.ucl.zcabrdc.neurolog;

import java.util.Date;

import io.realm.RealmObject;

public class Case extends RealmObject {
    private Date time;
    private String disease;
    private int age;
    private String gender;

    public String getDisease() {
        return disease;
    }

    public void setDisease(String disease) {
        this.disease = disease;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Date getTime() {
        return time;
    }

    public void setTime(Date time) {
        this.time = time;
    }
}
