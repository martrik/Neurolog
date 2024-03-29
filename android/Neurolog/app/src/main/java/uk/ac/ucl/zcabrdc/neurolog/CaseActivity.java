package uk.ac.ucl.zcabrdc.neurolog;

import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.WindowManager;

import java.util.ArrayList;
import java.util.List;

public class CaseActivity extends AppCompatActivity {

    private CustomPageAdapter pageAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
        setContentView(R.layout.activity_case);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (CaseFragment.editCheck) toolbar.setTitle("Update Case");
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        List<TabItem> fragments = getTabItems();
        pageAdapter = new CustomPageAdapter(getSupportFragmentManager(), fragments);
        ViewPager pager = (ViewPager)findViewById(R.id.caseViewpager);
        pager.setOffscreenPageLimit(1);
        pager.setAdapter(pageAdapter);
    }

    private List<TabItem> getTabItems() {
        List<TabItem> fList = new ArrayList<>();
        fList.add(new TabItem("", CaseFragment.newInstance()));
        return fList;
    }

}