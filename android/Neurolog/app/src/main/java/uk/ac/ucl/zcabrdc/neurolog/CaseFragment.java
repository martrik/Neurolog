package uk.ac.ucl.zcabrdc.neurolog;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.Toast;

import com.google.gson.Gson;
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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import io.realm.Realm;
import io.realm.RealmConfiguration;
import io.realm.RealmList;

public class CaseFragment extends Fragment implements OnFormRowValueChangedListener, OnFormRowClickListener {
    private ListView mListView;
    private HashMap<String, Value<?>> mChangesMap;
    private MenuItem mSaveMenuItem;
    private FormManager mFormManager;
    private RowDescriptor pickerDescriptor;
    private Toast toast = null;
    public static String TAG = "CaseFragment";
    public static boolean editCheck = false;

    public static CaseFragment newInstance() {
        return new CaseFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.form_case, container, false);
        mListView = (ListView) v.findViewById(R.id.listCase);
        return v;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) { //add rows to the form
        super.onViewCreated(view, savedInstanceState);
        mChangesMap = new HashMap<>();
        HashMap<String, Value<?>> newMap = CaseDialogFragment.editMap;

        FormDescriptor descriptor = FormDescriptor.newInstance();
        descriptor.setOnFormRowValueChangedListener(this);

        SectionDescriptor sectionDescriptor = SectionDescriptor.newInstance("section", "Tap on the tick to store this case");
        descriptor.addSection(sectionDescriptor);

        //time
        if (editCheck)
            sectionDescriptor.addRow(RowDescriptor.newInstance("time", RowDescriptor.FormRowDescriptorTypeTime, "Time:", newMap.get("time")));
        else
            sectionDescriptor.addRow(RowDescriptor.newInstance("time", RowDescriptor.FormRowDescriptorTypeTime, "Time:"));
        mChangesMap.put("time", new Value<>(null));

        //disease
        if (editCheck)
            pickerDescriptor = RowDescriptor.newInstance("disease",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Disease:", newMap.get("disease"));
        else
            pickerDescriptor = RowDescriptor.newInstance("disease",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Disease:", new Value<>(">"));
        pickerDescriptor.setDataSource(new DataSource() {
            @Override
            public void loadData(final DataSourceListener listener) {
                CustomTask task = new CustomTask(0);
                task.execute(listener);
            }
        });
        sectionDescriptor.addRow(pickerDescriptor);
        mChangesMap.put("disease", new Value<String>(null));

        //age
        if (editCheck)
            pickerDescriptor = RowDescriptor.newInstance("age",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Age:", newMap.get("age"));
        else
            pickerDescriptor = RowDescriptor.newInstance("age",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Age:", new Value<>(">"));
        pickerDescriptor.setDataSource(new DataSource() {
            @Override
            public void loadData(final DataSourceListener listener) {
                CustomTask task = new CustomTask(1);
                task.execute(listener);
            }
        });
        sectionDescriptor.addRow(pickerDescriptor);
        mChangesMap.put("age", new Value<Integer>(null));

        //gender
        if (editCheck)
            pickerDescriptor = RowDescriptor.newInstance("gender",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Sex:", newMap.get("gender"));
        else
            pickerDescriptor = RowDescriptor.newInstance("gender",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Sex:", new Value<>(">"));
        pickerDescriptor.setDataSource(new DataSource() {
            @Override
            public void loadData(final DataSourceListener listener) {
                CustomTask task = new CustomTask(2);
                task.execute(listener);
            }
        });
        sectionDescriptor.addRow(pickerDescriptor);
        mChangesMap.put("gender", new Value<String>(null));

        if (editCheck) mChangesMap = newMap;

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

    private boolean validate (String id, Realm realm) {
        if (mChangesMap.get(id).getValue() == null) {
            if (toast != null) toast.cancel();
            toast = Toast.makeText(getActivity(), "Missing field entries", Toast.LENGTH_SHORT);
            toast.show();
            realm.commitTransaction();
            return true;
        }
        return false;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item == mSaveMenuItem) {
            RealmConfiguration realmConfig = new RealmConfiguration.Builder(getActivity()).build();
            Realm realm = Realm.getInstance(realmConfig);
            Record record = OptionDialogFragment.record;

            realm.beginTransaction();
            Case newCase = new Case();
            if (editCheck) newCase = CaseDialogFragment.newCase;

            if (validate("time", realm)) return super.onOptionsItemSelected(item);
            newCase.setTime((Date) mChangesMap.get("time").getValue());

            if (validate("disease", realm)) return super.onOptionsItemSelected(item);
            newCase.setDisease((String) mChangesMap.get("disease").getValue());

            if (validate("age", realm)) return super.onOptionsItemSelected(item);
            newCase.setAge(Integer.parseInt((String) mChangesMap.get("age").getValue()));

            if (validate("gender", realm)) return super.onOptionsItemSelected(item);
            newCase.setGender((String) mChangesMap.get("gender").getValue());

            newCase.setRecord(record);

            if (!editCheck)
                record.getCases().add(newCase);
            else
                realm.copyToRealm(newCase);
            realm.commitTransaction();

            mChangesMap.clear();
            editCheck = false;

            Intent i = new Intent(getActivity(), RecordActivity.class);
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
        mFormManager.updateRows();
        mChangesMap.put(rowDescriptor.getTag(), newValue);
    }

    private class CustomTask extends AsyncTask<DataSourceListener, Void, List<String>> {

        private DataSourceListener mListener;
        private ProgressDialog mProgressDialog;
        private int type;

        public CustomTask(int type) {
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
            List<String> list;
            try (InputStream input = getActivity().getAssets().open("data.json")) {
                BufferedReader in = new BufferedReader(new InputStreamReader(input));
                Gson gson = new Gson();
                Response response = gson.fromJson(in, Response.class);
                switch (type) {
                    case 0:
                        return response.getPortfolio();
                    case 1:
                         list = new ArrayList<>();
                        for (int i = 0; i <= 125; i++) {
                            list.add(Integer.toString(i));
                        }
                        return list;
                    default:
                        list = new ArrayList<>();
                        list.add("Male");
                        list.add("Female");
                        return list;
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
