package uk.ac.ucl.zcabrdc.neurolog;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.quemb.qmbform.descriptor.Value;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;

import io.realm.Realm;

public class RecordActivity extends AppCompatActivity {

    public static HashMap<String, Value<?>> editMap;
    private Record record;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_record);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        record = OptionDialogFragment.record;

        TextView settingDisplay = (TextView) findViewById(R.id.settingDisplay);
        settingDisplay.setText("Setting: " + record.getSetting());

        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        TextView dateDisplay = (TextView) findViewById(R.id.dateDisplay);
        dateDisplay.setText("Date: " + dateFormat.format(record.getDate()));

        TextView locationDisplay = (TextView) findViewById(R.id.locationDisplay);
        locationDisplay.setText("Location: " + record.getLocation());

        if (record.getSupervisor()) {
            TextView supervisorDisplay = (TextView) findViewById(R.id.supervisorDisplay);
            supervisorDisplay.setText("Supervisor: " + record.getName());
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_record, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.action_addCase:
                startActivity(new Intent(this, CaseActivity.class));
                return true;
            case R.id.action_edit:
                editMap = new HashMap<>();
                editMap.put("dateDialog", new Value<>(record.getDate()));
                editMap.put("location", new Value<>(record.getLocation()));
                editMap.put("setting", new Value<>(record.getSetting()));
                editMap.put("title", new Value<>(record.getTitle()));
                editMap.put("lecturer", new Value<>(record.getLecturer()));
                editMap.put("topic", new Value<>(record.getTopic()));
                editMap.put("supervisor", new Value<>(record.getSupervisor()));
                editMap.put("name", new Value<>(record.getName()));

                AddFragment.editCheck = true;
                startActivity(new Intent(this, AddActivity.class));
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

}
