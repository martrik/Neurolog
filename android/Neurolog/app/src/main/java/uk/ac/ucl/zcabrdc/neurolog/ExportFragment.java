package uk.ac.ucl.zcabrdc.neurolog;

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

import com.quemb.qmbform.FormManager;
import com.quemb.qmbform.OnFormRowClickListener;
import com.quemb.qmbform.descriptor.FormDescriptor;
import com.quemb.qmbform.descriptor.FormItemDescriptor;
import com.quemb.qmbform.descriptor.OnFormRowValueChangedListener;
import com.quemb.qmbform.descriptor.RowDescriptor;
import com.quemb.qmbform.descriptor.SectionDescriptor;
import com.quemb.qmbform.descriptor.Value;

import java.util.HashMap;

public class ExportFragment extends Fragment implements OnFormRowValueChangedListener, OnFormRowClickListener {
    private ListView mListView;
    private HashMap<String, Value<?>> mChangesMap;
    private MenuItem mSaveMenuItem;
    private FormManager mFormManager;
    private Toast toast = null;
    public static String TAG = "ExportFragment";

    public static ExportFragment newInstance() {
        return new ExportFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.form_export, container, false);
        mListView = (ListView) v.findViewById(R.id.listExport);
        return v;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) { //add rows to the form
        super.onViewCreated(view, savedInstanceState);
        mChangesMap = new HashMap<>();

        FormDescriptor descriptor = FormDescriptor.newInstance();
        descriptor.setOnFormRowValueChangedListener(this);

        SectionDescriptor sectionDescriptor = SectionDescriptor.newInstance("section", "Tap on the icon to export this data");
        descriptor.addSection(sectionDescriptor);

        sectionDescriptor.addRow(RowDescriptor.newInstance("fromDate", RowDescriptor.FormRowDescriptorTypeDate, "Records from:"));
        mChangesMap.put("fromDate", new Value<>(null));

        sectionDescriptor.addRow(RowDescriptor.newInstance("toDate", RowDescriptor.FormRowDescriptorTypeDate, "To:"));
        mChangesMap.put("toDate", new Value<>(null));

        sectionDescriptor.addRow(RowDescriptor.newInstance("report", RowDescriptor.FormRowDescriptorTypeBooleanSwitch, "Include detailed report", new Value<>(false)));
        mChangesMap.put("report", new Value<>(false));

        sectionDescriptor.addRow(RowDescriptor.newInstance("teaching",RowDescriptor.FormRowDescriptorTypeBooleanSwitch, "Include teaching", new Value<>(false)));
        mChangesMap.put("teaching", new Value<>(false));

        mFormManager = new FormManager();
        mFormManager.setup(descriptor, mListView, getActivity());
        mFormManager.setOnFormRowClickListener(this);
        mFormManager.setOnFormRowValueChangedListener(this);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);

        inflater.inflate(R.menu.menu_export, menu);
        mSaveMenuItem = menu.findItem(R.id.action_export);
    }

    private boolean validate (String id) {
        if (mChangesMap.get(id).getValue() == null) {
            if (toast != null) toast.cancel();
            toast = Toast.makeText(getActivity(), "Missing field entries", Toast.LENGTH_SHORT);
            toast.show();
            return true;
        }
        return false;
    }

    public boolean onOptionsItemSelected(MenuItem item) {
        if (item == mSaveMenuItem) {
            if (validate("fromDate")) return super.onOptionsItemSelected(item);
            if (validate("toDate")) return super.onOptionsItemSelected(item);
            if (validate("report")) return super.onOptionsItemSelected(item);
            if (validate("teaching")) return super.onOptionsItemSelected(item);
            //export code
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
}
