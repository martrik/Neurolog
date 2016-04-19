package uk.ac.ucl.zcabrdc.neurolog;

import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;

import com.quemb.qmbform.descriptor.Value;

import java.util.HashMap;

import io.realm.Realm;

public class OptionDialogFragment extends DialogFragment {
    public static Record record;

    public void setRecord(Record record) {
        this.record = record;
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle(R.string.options)
                .setItems(R.array.option_array, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        switch (which) {
                            case 0:
                                //Edit
                                if (record.getSetting().equals("Teaching")) {
                                    RecordActivity.editMap = new HashMap<>();
                                    HashMap<String, Value<?>> editMap = RecordActivity.editMap;
                                    editMap.put("dateDialog", new Value<>(record.getDate()));
                                    editMap.put("location", new Value<>(record.getLocation()));
                                    editMap.put("setting", new Value<>(record.getSetting()));
                                    editMap.put("title", new Value<>(record.getTitle()));
                                    editMap.put("lecturer", new Value<>(record.getLecturer()));
                                    editMap.put("topic", new Value<>(record.getTopic()));
                                    editMap.put("supervisor", new Value<>(record.getSupervisor()));
                                    editMap.put("name", new Value<>(record.getName()));

                                    AddFragment.editCheck = true;
                                    startActivity(new Intent(getActivity(), AddActivity.class));
                                }
                                else
                                    startActivity(new Intent(getActivity(), RecordActivity.class));
                                break;
                            case 1:
                                //Delete
                                Realm realm = MainActivity.realm;
                                realm.beginTransaction();
                                for (Case removeCase : record.getCases())
                                    removeCase.removeFromRealm();
                                record.removeFromRealm();
                                realm.commitTransaction();
                                dialog.dismiss();
                                Intent i = new Intent(getActivity(), MainActivity.class);
                                startActivity(i);
                                break;
                            case 2:
                                //Cancel
                                dialog.dismiss();
                                break;
                        }
                    }
                });
        return builder.create();
    }

}
