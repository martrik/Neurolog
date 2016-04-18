package uk.ac.ucl.zcabrdc.neurolog;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.text.SimpleDateFormat;

import io.realm.RealmList;

public class CaseListAdapter extends ArrayAdapter<Case> {
    private int resource;
    private LayoutInflater inflater;
    private Context context;
    public CaseListAdapter(Context ctx, int resourceId, RealmList<Case> objects) {
        super(ctx, resourceId, objects);
        resource = resourceId;
        inflater = LayoutInflater.from( ctx );
        context = ctx;
    }

    @Override
    public View getView ( int position, View convertView, ViewGroup parent ) {
        convertView =  inflater.inflate(resource, null);
        Case curCase = getItem(position);

        TextView topicText = (TextView) convertView.findViewById(R.id.topicText);
        topicText.setText(curCase.getDisease());

        TextView patientText = (TextView) convertView.findViewById(R.id.patientText);
        patientText.setText("Sex: " + curCase.getGender() + " Age: " + curCase.getAge());

        SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm");
        TextView timeText = (TextView) convertView.findViewById(R.id.timeText);
        timeText.setText(dateFormat.format(curCase.getTime()));

        return convertView;
    }
}
