package uk.ac.ucl.zcabrdc.neurolog;

import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;

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
                                startActivity(new Intent(getActivity(), RecordActivity.class));
                                break;
                            case 1:
                                //Share
                                break;
                            case 2:
                                //Delete
                                Realm realm = MainActivity.realm;
                                realm.beginTransaction();
                                record.removeFromRealm();
                                realm.commitTransaction();
                                dialog.dismiss();
                                Intent i = new Intent(getActivity(), MainActivity.class);
                                startActivity(i);
                                break;
                            case 3:
                                //Cancel
                                dialog.dismiss();
                                break;
                        }
                    }
                });
        return builder.create();
    }

}
