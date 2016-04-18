package uk.ac.ucl.zcabrdc.neurolog;

import android.app.ProgressDialog;
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
import java.util.Date;
import java.util.HashMap;
import java.util.List;

public class CaseFragment extends Fragment implements OnFormRowValueChangedListener, OnFormRowClickListener {
    private ListView mListView;
    private HashMap<String, Value<?>> mChangesMap;
    private MenuItem mSaveMenuItem;
    private FormManager mFormManager;
    private RowDescriptor pickerDescriptor;
    public static String TAG = "AddFragment";
    public static boolean editCheck;

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

        FormDescriptor descriptor = FormDescriptor.newInstance();
        descriptor.setOnFormRowValueChangedListener(this);

        SectionDescriptor sectionDescriptor = SectionDescriptor.newInstance("section", "Tap on the tick to store this case");
        descriptor.addSection(sectionDescriptor);

        //date
//        if (editCheck)
//            sectionDescriptor.addRow(RowDescriptor.newInstance("dateDialog", RowDescriptor.FormRowDescriptorTypeDate, "Date:", newMap.get("dateDialog")));
//        else

        //time
        sectionDescriptor.addRow(RowDescriptor.newInstance("dateDialog", RowDescriptor.FormRowDescriptorTypeDate, "Date:"));
        mChangesMap.put("dateDialog", new Value<Date>(null));

        //setting
//        if (editCheck)
//            pickerDescriptor = RowDescriptor.newInstance("setting",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Setting:", newMap.get("setting"));
//        else

        //disease
        pickerDescriptor = RowDescriptor.newInstance("disease",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Disease:", new Value<>(">"));
        pickerDescriptor.setDataSource(new DataSource() {
            @Override
            public void loadData(final DataSourceListener listener) {
                CustomTask task = new CustomTask(true);
                task.execute(listener);
            }
        });
        sectionDescriptor.addRow(pickerDescriptor);
        mChangesMap.put("disease", new Value<String>(null));

        //age
        pickerDescriptor = RowDescriptor.newInstance("age",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Case:", new Value<>(">"));
        pickerDescriptor.setDataSource(new DataSource() {
            @Override
            public void loadData(final DataSourceListener listener) {
                CustomTask task = new CustomTask(true);
                task.execute(listener);
            }
        });
        sectionDescriptor.addRow(pickerDescriptor);
        mChangesMap.put("age", new Value<String>(null));

        //gender
        pickerDescriptor = RowDescriptor.newInstance("gender",RowDescriptor.FormRowDescriptorTypeSelectorPickerDialog, "Sex:", new Value<>(">"));
        pickerDescriptor.setDataSource(new DataSource() {
            @Override
            public void loadData(final DataSourceListener listener) {
                CustomTask task = new CustomTask(true);
                task.execute(listener);
            }
        });
        sectionDescriptor.addRow(pickerDescriptor);
        mChangesMap.put("gender", new Value<String>(null));

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

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onFormRowClick(FormItemDescriptor itemDescriptor) {
        //Log.d(TAG, "Value Changed: " + itemDescriptor.getTitle() + " " + mChangesMap.get(itemDescriptor.getTag()).getValue());
    }

    @Override
    public void onValueChanged(RowDescriptor rowDescriptor, Value<?> oldValue, Value<?> newValue) {

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
