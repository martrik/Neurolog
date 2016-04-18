package uk.ac.ucl.zcabrdc.neurolog;

import android.support.v4.app.Fragment;

public class TabItem {

    private String mTitle;
    private Fragment mFragment;

    public TabItem(String title, Fragment fragment){
        mTitle = title;
        mFragment = fragment;
    }

    public Fragment getFragment() {
        return mFragment;
    }

    public String getTitle() {
        return mTitle;
    }
}