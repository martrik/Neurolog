package uk.ac.ucl.zcabrdc.neurolog;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.Toast;

import com.quemb.qmbform.FormManager;
import com.quemb.qmbform.OnFormRowClickListener;
import com.quemb.qmbform.descriptor.DataSource;
import com.quemb.qmbform.descriptor.DataSourceListener;
import com.quemb.qmbform.descriptor.FormDescriptor;
import com.quemb.qmbform.descriptor.FormItemDescriptor;
import com.quemb.qmbform.descriptor.OnFormRowValueChangedListener;
import com.quemb.qmbform.descriptor.RowDescriptor;
import com.quemb.qmbform.descriptor.SectionDescriptor;
import com.quemb.qmbform.descriptor.Value;
import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import io.realm.Realm;
import io.realm.RealmConfiguration;

public class AddFragment extends Fragment implements OnFormRowValueChangedListener, OnFormRowClickListener {
    private ListView mListView;
    private HashMap<String, Value<?>> mChangesMap;
    private MenuItem mSaveMenuItem;
    private FormManager mFormManager;
    private Toast toast = null;
    private SectionDescriptor sectionDescriptor;
    private RowDescriptor pickerDescriptor;
    private RowDescriptor supervisorDescriptor;
    private RowDescriptor nameDescriptor;
    private RowDescriptor titleDescriptor, lecturerDescriptor, topicDescriptor;
    private boolean teachCheck = false;
    private boolean nameCheck = false;
    public static boolean editCheck = false;

    public static String TAG = "AddFragment";

    public static AddFragment newInstance() {
        return new AddFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.form_add, container, false);
        mListView = (ListView) v.findViewById(R.id.list);
        return v;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) { //add rows to the form
        super.onViewCreated(view, savedInstanceState);
        mChangesMap = new HashMap<>();
        HashMap<String, Value<?>> newMap = RecordActivity.editMap;

        Log.d(TAG, "This form is being edited: " + editCheck);

        //sets up the form
        FormDescriptor descriptor = FormDescriptor.newInstance();
        descriptor.setOnFormRowValueChangedListener(this);

        sectionDescriptor = SectionDescriptor.newInstance("section","Tap on the tick to store this record");
        descriptor.addSection(sectionDescriptor);

        //date
        if (editCheck)
            sectionDescriptor.addRow(RowDescriptor.newInstance("dateDialog", RowDescriptor.FormRowDescriptorTypeDate, "Date:", newMap.get("dateDialog")));
        else
            sectionDescriptor.addRow(RowDescriptor.newInstance("dateDialog", RowDescriptor.FormRowDescriptorTypeDate, "Date:"));
        mChangesMap.put("dateDialog", new Value<Date>(null));

        //location
        if (editCheck)
            sectionDescriptor.addRow(RowDescriptor.newInstance("location", RowDescriptor.FormRowDescriptorTypeTextInline, "Location:", newMap.get("location")));
        else
            sectionDescriptor.addRow(RowDescriptor.newInstance("location", RowDescriptor.FormRowDescriptorTypeTextInline, "Location:"));
        mChangesMap.put("location", new Value<String>(null));

        //setting
        if (editCheck)
            pickerDescriptor = RowDescriptor.newInstance("setting",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Setting:", newMap.get("setting"));
        else
            pickerDescriptor = RowDescriptor.newInstance("setting",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Setting:", new Value<>(">"));
        pickerDescriptor.setDataSource(new DataSource() {
            @Override
            public void loadData(final DataSourceListener listener) {
                CustomTask task = new CustomTask(true);
                task.execute(listener);
            }
        });
        sectionDescriptor.addRow(pickerDescriptor);
        mChangesMap.put("setting", new Value<String>(null));

        if (editCheck && newMap.get("setting").getValue().equals("Teaching")) {
            titleDescriptor = RowDescriptor.newInstance("title", RowDescriptor.FormRowDescriptorTypeTextInline, "Title:", newMap.get("title"));
            sectionDescriptor.addRow(titleDescriptor);

            lecturerDescriptor = RowDescriptor.newInstance("lecturer", RowDescriptor.FormRowDescriptorTypeTextInline, "Lecturer:", newMap.get("lecturer"));
            sectionDescriptor.addRow(lecturerDescriptor);

            topicDescriptor = RowDescriptor.newInstance("topic",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Topic:", newMap.get("topic"));
            topicDescriptor.setDataSource(new DataSource() {
                @Override
                public void loadData(final DataSourceListener listener) {
                    CustomTask task = new CustomTask(false);
                    task.execute(listener);
                }
            });
            sectionDescriptor.addRow(topicDescriptor);
            teachCheck = true;
        }

        //superviosr
        supervisorDescriptor = RowDescriptor.newInstance("supervisor",RowDescriptor.FormRowDescriptorTypeBooleanSwitch, "Do you have a supervisor?", new Value<>(false));
        if (editCheck) supervisorDescriptor = RowDescriptor.newInstance("supervisor",RowDescriptor.FormRowDescriptorTypeBooleanSwitch, "Do you have a supervisor?", newMap.get("supervisor"));
        sectionDescriptor.addRow(supervisorDescriptor);
        mChangesMap.put("supervisor", new Value<>(false));

        if (editCheck && (Boolean) newMap.get("supervisor").getValue()) {
            nameDescriptor = RowDescriptor.newInstance("name", RowDescriptor.FormRowDescriptorTypeTextInline, "Name:", newMap.get("name"));
            sectionDescriptor.addRow(nameDescriptor);
            nameCheck = true;
        }

        if (editCheck) mChangesMap = newMap;

        //renders the form
        mFormManager = new FormManager();
        mFormManager.setup(descriptor, mListView, getActivity());
        mFormManager.setOnFormRowClickListener(this);
        mFormManager.setOnFormRowValueChangedListener(this);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);

        inflater.inflate(R.menu.menu_add, menu);
        mSaveMenuItem = menu.findItem(R.id.action_save);
    }

    private boolean validate (String id, String text, Realm realm) {
        if (mChangesMap.get(id).getValue() == null) {
            if (toast != null) toast.cancel();
            toast = Toast.makeText(getActivity(), text, Toast.LENGTH_SHORT);
            toast.show();
            realm.commitTransaction();
            return true;
        }
        return false;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        String validateFail = "Missing field entries.";
        if (item == mSaveMenuItem){
            RealmConfiguration realmConfig = new RealmConfiguration.Builder(getActivity()).build();
            Realm realm = Realm.getInstance(realmConfig);

            realm.beginTransaction();
            Record record = new Record();
            if (editCheck) record = OptionDialogFragment.record;

            if (validate("dateDialog", validateFail, realm)) return super.onOptionsItemSelected(item);
            record.setDate((Date) mChangesMap.get("dateDialog").getValue());

            if (validate("location", validateFail, realm)) return super.onOptionsItemSelected(item);
            record.setLocation((String) mChangesMap.get("location").getValue());

            if (validate("setting", validateFail, realm)) return super.onOptionsItemSelected(item);
            record.setSetting((String) mChangesMap.get("setting").getValue());

            if (mChangesMap.get("setting").getValue().equals("Teaching")) {
                if (validate("title", validateFail, realm)) return super.onOptionsItemSelected(item);
                record.setTitle((String) mChangesMap.get("title").getValue());

                if (validate("lecturer", validateFail, realm)) return super.onOptionsItemSelected(item);
                record.setLecturer((String) mChangesMap.get("title").getValue());

                if (validate("topic", validateFail, realm)) return super.onOptionsItemSelected(item);
                record.setTopic((String) mChangesMap.get("topic").getValue());
            }

            record.setSupervisor((Boolean) mChangesMap.get("supervisor").getValue());
            if ((Boolean) mChangesMap.get("supervisor").getValue()) {
                if (validate("name", validateFail, realm)) return super.onOptionsItemSelected(item);
                record.setName((String) mChangesMap.get("name").getValue());
            }

            realm.copyToRealm(record);
            realm.commitTransaction();

            mChangesMap.clear();
            editCheck = false;

            Intent i = new Intent(getActivity(), MainActivity.class);
            startActivity(i);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onFormRowClick(FormItemDescriptor itemDescriptor) {
        //Log.d(TAG, "Value Changed: " + itemDescriptor.getTitle() + " " + mChangesMap.get(itemDescriptor.getTag()).getValue());
    }

    @Override
    public void onValueChanged(RowDescriptor rowDescriptor, Value<?> oldValue, Value<?> newValue) {
        boolean check = rowDescriptor.getTag().equals("dateDialog") || rowDescriptor.getTag().equals("setting") || rowDescriptor.getTag().equals("topic");
        if (check) {
            mFormManager.updateRows();
        }
        if (newValue.getValue().equals("Teaching")) {
            sectionDescriptor.removeRow(supervisorDescriptor);
            if (nameCheck) sectionDescriptor.removeRow(nameDescriptor);

            titleDescriptor = RowDescriptor.newInstance("title", RowDescriptor.FormRowDescriptorTypeTextInline, "Title:");
            sectionDescriptor.addRow(titleDescriptor);
            mChangesMap.put("title", new Value<String>(null));

            lecturerDescriptor = RowDescriptor.newInstance("lecturer", RowDescriptor.FormRowDescriptorTypeTextInline, "Lecturer:");
            sectionDescriptor.addRow(lecturerDescriptor);
            mChangesMap.put("lecturer", new Value<String>(null));

            topicDescriptor = RowDescriptor.newInstance("topic",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Topic:", new Value<>(">"));
            topicDescriptor.setDataSource(new DataSource() {
                @Override
                public void loadData(final DataSourceListener listener) {
                    CustomTask task = new CustomTask(false);
                    task.execute(listener);
                }
            });
            sectionDescriptor.addRow(topicDescriptor);
            mChangesMap.put("topic", new Value<String>(null));

            sectionDescriptor.addRow(supervisorDescriptor);
            if (nameCheck) sectionDescriptor.addRow(nameDescriptor);
            teachCheck = true;
        }
        if (rowDescriptor.getTag().equals("setting") && !newValue.getValue().equals("Teaching") && teachCheck) {
            sectionDescriptor.removeRow(titleDescriptor);
            sectionDescriptor.removeRow(lecturerDescriptor);
            sectionDescriptor.removeRow(topicDescriptor);
            teachCheck = false;
        }
        if (rowDescriptor.getTag().equals("supervisor")) {
            if ((Boolean) newValue.getValue()) {
                nameDescriptor = RowDescriptor.newInstance("name", RowDescriptor.FormRowDescriptorTypeTextInline, "Name:");
                sectionDescriptor.addRow(nameDescriptor);
                mChangesMap.put("name", new Value<String>(null));
                nameCheck = true;
            } else {
                sectionDescriptor.removeRow(nameDescriptor);
                nameCheck = false;
            }
        }
        mChangesMap.put(rowDescriptor.getTag(), newValue);
        Log.d(TAG, rowDescriptor.getTitle() + " " + newValue.getValue());
    }

    private class CustomTask extends AsyncTask<DataSourceListener, Void, List<String>> {

        private DataSourceListener mListener;
        private ProgressDialog mProgressDialog;
        private boolean type;

        public CustomTask(boolean type) {
            this.type = type;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mProgressDialog = ProgressDialog.show(getActivity(), "Loading", "Preparing options", true);
        }

        @Override
        protected List<String> doInBackground(DataSourceListener... listeners) { //json parse
            mListener = listeners[0];
            try (InputStream input = getActivity().getAssets().open("data.json")) {
                BufferedReader in = new BufferedReader(new InputStreamReader(input));
                Gson gson = new Gson();
                Response response = gson.fromJson(in, Response.class);
                if (type) {
                    return response.getSetting();
                } else {
                    return response.getPortfolio();
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        @Override
        protected void onPostExecute(List<String> strings) {
            super.onPostExecute(strings);
            mProgressDialog.dismiss();
            mListener.onDataSourceLoaded(strings);
        }
    }
}
