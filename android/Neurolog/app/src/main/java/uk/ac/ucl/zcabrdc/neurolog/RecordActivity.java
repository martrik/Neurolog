package uk.ac.ucl.zcabrdc.neurolog;

import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;

import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.quemb.qmbform.descriptor.Value;
import java.text.SimpleDateFormat;
import java.util.HashMap;


public class RecordActivity extends AppCompatActivity {

    public static HashMap<String, Value<?>> editMap;
    //public static Boolean hasSigned;
    private Record record;

    public void showImage(View view) {
        Dialog builder = new Dialog(this);
        builder.requestWindowFeature(Window.FEATURE_NO_TITLE);
        builder.getWindow().setBackgroundDrawable(
                new ColorDrawable(android.graphics.Color.TRANSPARENT));
        builder.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialogInterface) {
                //nothing;
            }
        });

        ImageView imageView = new ImageView(this);
        byte[] data = record.getSignature();
        Bitmap bmp = BitmapFactory.decodeByteArray(data, 0, data.length);
        imageView.setImageBitmap(bmp);
        //imageView.setImageURI(imageUri); //change this
        builder.addContentView(imageView, new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));
        builder.show();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_record);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        record = OptionDialogFragment.record;

        TextView settingDisplay = (TextView) findViewById(R.id.settingDisplay);
        settingDisplay.setText(record.getSetting());

        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        TextView dateDisplay = (TextView) findViewById(R.id.dateDisplay);
        dateDisplay.setText("Date: " + dateFormat.format(record.getDate()));

        TextView locationDisplay = (TextView) findViewById(R.id.locationDisplay);
        locationDisplay.setText("Location: " + record.getLocation());

        View buttonApprove = findViewById(R.id.approveButton);
        buttonApprove.setVisibility(View.INVISIBLE);

        ImageView signatureBadge = (ImageView) findViewById(R.id.signed_image);
        signatureBadge.setVisibility(View.INVISIBLE);

        if (record.getSupervisor()) {
            TextView supervisorDisplay = (TextView) findViewById(R.id.supervisorDisplay);
            supervisorDisplay.setText("Supervisor: " + record.getName());
            if (record.getSignature() == null) buttonApprove.setVisibility(View.VISIBLE);
            if (record.getSignature() != null) signatureBadge.setVisibility(View.VISIBLE);
        }

        //Listview stuff here
        ListView caseList = (ListView) findViewById(R.id.caseList);
        caseList.setAdapter(new CaseListAdapter(this, R.layout.case_list, OptionDialogFragment.record.getCases()));
        caseList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                CaseDialogFragment option = new CaseDialogFragment();
                CaseDialogFragment.newCase = record.getCases().get(position);
                option.show(getFragmentManager(), "options");
            }
        });
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

    public void approveRecord(View view) {
        //Log.d("Test", "The button works woop!");
        startActivity(new Intent(this, SignActivity.class));
    }
}
