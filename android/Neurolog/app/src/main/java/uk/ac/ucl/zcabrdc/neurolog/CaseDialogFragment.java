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

public class CaseDialogFragment extends DialogFragment { //change for cases, then add listener to RecordActivity
    public static Case newCase;
    public static HashMap<String, Value<?>> editMap;

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle(R.string.options)
                .setItems(R.array.option_array, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        switch (which) {
                            case 0:
                                //Edit
                                editMap = new HashMap<>();
                                editMap.put("time", new Value<>(newCase.getTime()));
                                editMap.put("disease", new Value<>(newCase.getDisease()));
                                editMap.put("age", new Value<>(Integer.toString(newCase.getAge())));
                                editMap.put("gender", new Value<>(newCase.getGender()));

                                CaseFragment.editCheck = true;
                                startActivity(new Intent(getActivity(), CaseActivity.class));
                                break;
                            case 1:
                                //Delete
                                Realm realm = MainActivity.realm;
                                realm.beginTransaction();
                                OptionDialogFragment.record.getCases().remove(newCase);
                                newCase.removeFromRealm();
                                realm.commitTransaction();
                                dialog.dismiss();
                                Intent i = new Intent(getActivity(), RecordActivity.class);
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
