package uk.ac.ucl.zcabrdc.neurolog;

import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;

import java.util.ArrayList;
import java.util.List;


public class SignActivity extends AppCompatActivity {

    private CustomPageAdapter pageAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        List<TabItem> fragments = getTabItems();
        pageAdapter = new CustomPageAdapter(getSupportFragmentManager(), fragments);
        ViewPager pager = (ViewPager)findViewById(R.id.signpager);
        pager.setOffscreenPageLimit(1);
        pager.setAdapter(pageAdapter);
    }

    private List<TabItem> getTabItems() {
        List<TabItem> fList = new ArrayList<>();
        fList.add(new TabItem("", SignFragment.newInstance()));
        return fList;
    }
}
