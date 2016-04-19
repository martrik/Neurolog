package uk.ac.ucl.zcabrdc.neurolog;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.github.mikephil.charting.data.BarEntry;
import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;

import io.realm.RealmResults;

public class ListAdapter extends ArrayAdapter<Record> {
    private int resource;
    private LayoutInflater inflater;
    private Context context;
    public ListAdapter(Context ctx, int resourceId, RealmResults<Record> objects) {
        super(ctx, resourceId, objects);
        resource = resourceId;
        inflater = LayoutInflater.from( ctx );
        context = ctx;
    }

    @Override
    public View getView ( int position, View convertView, ViewGroup parent ) {
        convertView =  inflater.inflate(resource, null);
        Record record = getItem(position);

        int index = MainActivity.response.getSetting().indexOf(record.getSetting());
        TextView settingText = (TextView) convertView.findViewById(R.id.settingText);
        settingText.setTextColor(MainActivity.colours[index]);
        settingText.setText(record.getSetting());

        TextView locationText = (TextView) convertView.findViewById(R.id.locationText);
        locationText.setText(record.getLocation());

        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        TextView dateText = (TextView) convertView.findViewById(R.id.dateText);
        dateText.setText(dateFormat.format(record.getDate()));

        TextView caseNumber = (TextView) convertView.findViewById(R.id.caseNumber);
        caseNumber.setText(Integer.toString(record.getCases().size()));
        if (record.getSetting().equals("Teaching")) caseNumber.setVisibility(View.INVISIBLE);

        return convertView;
    }
}
