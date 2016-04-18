package uk.ac.ucl.zcabrdc.neurolog;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import java.util.List;

public class CustomPageAdapter extends FragmentPagerAdapter {
    private List<TabItem> mTabItems;

    public CustomPageAdapter(FragmentManager fm, List<TabItem> tabItems) {
        super(fm);
        mTabItems = tabItems;
    }

    @Override
    public Fragment getItem(int position) {
        return mTabItems.get(position).getFragment();
    }

    @Override
    public int getCount() {
        return mTabItems.size();
    }

    @Override
    public CharSequence getPageTitle (int position) {
        return mTabItems.get(position).getTitle();
    }

}
