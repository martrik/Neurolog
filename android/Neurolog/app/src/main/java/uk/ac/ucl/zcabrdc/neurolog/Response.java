package uk.ac.ucl.zcabrdc.neurolog;

import java.util.List;

public class Response {
    private List<String> setting;
    private List<String> portfolio;

    public List<String> getSetting() {
        return setting;
    }

    public void setSetting(List<String> setting) {
        this.setting = setting;
    }

    public List<String> getPortfolio() {
        return portfolio;
    }

    public void setPortfolio(List<String> portfolio) {
        this.portfolio = portfolio;
    }
}
