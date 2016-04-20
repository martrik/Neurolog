package uk.ac.ucl.zcabrdc.neurolog;

import android.net.Uri;
import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;

import io.realm.RealmResults;

/**
 * Created by Marti on 20/04/16.
 */
public class CSVManager {

    public static File generateGeneralCSV(Date from, Date to, Boolean teaching) {
        String stringData = new String();

        stringData += "Disease, Number of Cases \n";
        for (String topic : MainActivity.response.getPortfolio()) {
            int count = MainActivity.realm.where(Case.class)
                    .equalTo("disease", topic)
                    .between("time", from, to)
                    .findAll().size();

            String rowString = topic + "," + Integer.toString(count) +  "\n";
            stringData += rowString;
        }


        if (teaching) {
            stringData += " \n";
            stringData += "Teaching statistics \n";
            stringData += "Disease, Teachings attended \n";

            for (String topic : MainActivity.response.getPortfolio()) {
                int count = MainActivity.realm.where(Record.class)
                        .equalTo("topic", topic)
                        .between("date", from, to)
                        .findAll().size();

                String rowString = topic + "," + Integer.toString(count) +  "\n";
                stringData += rowString;
            }
        }

        Log.d("export", stringData);

        File data = null;
        try {
            Date dateVal = new Date();
            String filename = dateVal.toString();
            data = File.createTempFile("Report", ".csv");
            FileWriter out = (FileWriter) generateCsvFile(data, stringData);

            return data;
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static FileWriter generateCsvFile(File sFileName, String fileContent) {
        FileWriter writer = null;

        try {
            writer = new FileWriter(sFileName);
            writer.append(fileContent);
            writer.flush();

        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } finally
        {
            try {
                writer.close();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return writer;
    }
}
