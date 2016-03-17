//
//  AddRecord.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import Eureka

class NLAddRecordVC: FormViewController, UITextFieldDelegate {

    internal var editingRecord: Record? = nil
    var datePicker: DatePickerDialog!
    var didDismissWithRecord:((Record)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form  +++=
            
            Section(footer: "Tap on save to store this Record")

            <<< DateRow("date") {
                $0.value = NSDate();
                $0.title = "Date:"
            }
            <<< TextRow("location") {
                $0.title =  "Location:"
                if let location = editingRecord?.location {
                    $0.value = location
                }
            }
            <<< AlertRow<String>("facility") {
                $0.title = "Facility:"
                $0.options = NLSelectionDataManger.sharedInstance.getFacilities()
                if let facility = editingRecord?.facility {
                    $0.value = facility
                } else {
                    $0.value = NLSelectionDataManger.sharedInstance.getFacilities().first
                }
            }
            <<< SwitchRow("supervisorswitch") {
                $0.title = "Do you have a supervisor?"
                if let _ = editingRecord?.supervisor {
                    $0.value = true
                } else {
                    $0.value = false
                }
            }
            <<< NameRow("supervisorname") {
                $0.title = "Name:"
                $0.hidden = "$supervisorswitch == false"
                
                if let supervisor = editingRecord?.supervisor {
                    $0.value = supervisor
                } else {
                    $0.value = ""
                }
            }
        
        // Is editing
        if let _ = self.editingRecord {
            self.title = "Update record"
        }
    }
    
    
    // MARK: - Save
    
    @IBAction func didTapSave(sender: AnyObject) {
        var savedRecord = Record()
        if let record = editingRecord {
            NLRecordsDataManager.sharedInstance.updateRecord(record, info: form.values())
            savedRecord = record
        } else {
            savedRecord = NLRecordsDataManager.sharedInstance.saveRecordWith(form.values())
        }
        
        if let completion = didDismissWithRecord {
            completion(savedRecord)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NLRecordDetailSegue" {
            let dest = segue.destinationViewController as! NLDetailRecordVC
            dest.record = sender as! Record
        }
    }
    

}