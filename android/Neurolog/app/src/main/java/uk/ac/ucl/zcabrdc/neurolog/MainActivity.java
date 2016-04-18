package uk.ac.ucl.zcabrdc.neurolog;

import android.content.Intent;
import android.support.design.widget.TabLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

import com.github.mikephil.charting.charts.HorizontalBarChart;
import com.github.mikephil.charting.data.BarData;
import com.github.mikephil.charting.data.BarDataSet;
import com.github.mikephil.charting.data.BarEntry;
import com.github.mikephil.charting.utils.ColorTemplate;
import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;

import io.realm.Realm;
import io.realm.RealmConfiguration;

public class MainActivity extends AppCompatActivity {
    public static Realm realm;
    private static Object fragmentManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        SectionsPagerAdapter mSectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());

        ViewPager mViewPager = (ViewPager) findViewById(R.id.container);
        mViewPager.setAdapter(mSectionsPagerAdapter);

        TabLayout tabLayout = (TabLayout) findViewById(R.id.tabs);
        tabLayout.setupWithViewPager(mViewPager);

        fragmentManager = getFragmentManager();

        RealmConfiguration realmConfig = new RealmConfiguration.Builder(this).build();
        realm = Realm.getInstance(realmConfig);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.action_add:
                Intent i = new Intent(this, AddActivity.class);
                startActivity(i);
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }

    public static class PlaceholderFragment extends Fragment {

        private static final String ARG_SECTION_NUMBER = "section_number";

        public static PlaceholderFragment newInstance(int sectionNumber) {
            PlaceholderFragment fragment = new PlaceholderFragment();
            Bundle args = new Bundle();
            args.putInt(ARG_SECTION_NUMBER, sectionNumber);
            fragment.setArguments(args);
            return fragment;
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_all, container, false);
            switch (getArguments().getInt(ARG_SECTION_NUMBER)) {
                case 1:
                    rootView = inflater.inflate(R.layout.fragment_all, container, false);
                    final ListView recordList = ( ListView ) rootView.findViewById(R.id.recordList);
                    recordList.setAdapter( new ListAdapter(getActivity(), R.layout.record_list, realm.where(Record.class).findAll()) );
                    recordList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                        @Override
                        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                            OptionDialogFragment option = new OptionDialogFragment();
                            option.setRecord(realm.where(Record.class).findAll().get(position));
                            option.show((android.app.FragmentManager) fragmentManager, "options");
                        }
                    });
                    break;
                case 2:
                    rootView = inflater.inflate(R.layout.fragment_sum, container, false);
                    
                    //setting chart
                    HorizontalBarChart settingChart = (HorizontalBarChart) rootView.findViewById(R.id.settingChart);
                    ArrayList<BarEntry> entries = new ArrayList<>();
                    ArrayList<String> labels = new ArrayList<>();

                    try (InputStream input = getActivity().getAssets().open("data.json")) {
                        BufferedReader in = new BufferedReader(new InputStreamReader(input));
                        Gson gson = new Gson();
                        Response response = gson.fromJson(in, Response.class);
                        for (int i = 0; i < response.getSetting().size(); i++) {
                            int total = realm.where(Record.class).contains("setting", response.getSetting().get(i)).findAll().size();
                            entries.add(new BarEntry(total, i));
                            labels.add(response.getSetting().get(i));
                        }
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }

                    BarDataSet dataset = new BarDataSet(entries, "Number of records per setting");
                    BarData data = new BarData(labels, dataset);
                    settingChart.setData(data);
                    settingChart.setDrawGridBackground(false);
                    settingChart.setDrawValueAboveBar(false);
                    settingChart.setPinchZoom(true);
                    settingChart.setDescription("");
                    dataset.setColors(ColorTemplate.COLORFUL_COLORS);
                    
                    //age chart
                    HorizontalBarChart ageChart = (HorizontalBarChart) rootView.findViewById(R.id.ageChart);
                    entries = new ArrayList<>();
                    labels = new ArrayList<>();
                    for (int i = 0; i <= 110; i+=10) {
                        int total = realm.where(Case.class).between("age", i, i + 9).findAll().size();
                        entries.add(new BarEntry(total, i / 10));
                        labels.add(Integer.toString(i));
                    }

                    BarDataSet agedataset = new BarDataSet(entries, "Number of cases per age range");
                    BarData agedata = new BarData(labels, agedataset);
                    ageChart.setData(agedata);
                    ageChart.setDrawGridBackground(false);
                    ageChart.setDrawValueAboveBar(false);
                    ageChart.setPinchZoom(true);
                    ageChart.setDescription("");
                    break;
            }
            return rootView;
        }
    }

    public class SectionsPagerAdapter extends FragmentPagerAdapter {
        public SectionsPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public Fragment getItem(int position) {
            return PlaceholderFragment.newInstance(position + 1);
        }

        @Override
        public int getCount() {
            return 2;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            switch (position) {
                case 0:
                    return "ALL";
                case 1:
                    return "SUMMARY";
            }
            return null;
        }
    }
}
