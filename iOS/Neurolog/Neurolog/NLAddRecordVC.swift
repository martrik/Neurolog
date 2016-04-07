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
    var didDismissWithRecord:((Record)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++=
            
            Section(footer: "Tap on save to store this Record")

            <<< DateRow("date") {
                $0.title = "Date:"

                if let date = editingRecord?.date {
                    $0.value = date
                } else {
                    $0.value = NSDate();
                }                
            }
            <<< NameRow("location") {
                $0.title =  "Location:"
                if let location = editingRecord?.location {
                    $0.value = location
                }
            }
            <<< AlertRow<String>("setting") {
                $0.title = "Setting:"
                $0.options = NLSelectionDataManger.sharedInstance.clinicalSettings()
                if let setting = editingRecord?.setting {
                    $0.value = setting
                } else {
                    $0.value = NLSelectionDataManger.sharedInstance.clinicalSettings().first
                }
            }
            <<< TextRow("teachingtitle") {
                $0.title = "Title:"
                
                $0.hidden = Condition.Function(["setting"]) { form in
                    if let r1 : AlertRow<String> = form.rowByTag("setting") as? AlertRow<String>{
                        return r1.value != "Teaching"
                    }
                    return true
                }
                
                if editingRecord?.teachingInfo != nil {
                    $0.value = editingRecord?.teachingInfo!.title
                } else {
                    $0.value = ""
                }
            }
            <<< NameRow("teachinglecturer") {
                $0.title = "Lecturer:"
                
                $0.hidden = Condition.Function(["setting"]) { form in
                    if let r1 : AlertRow<String> = form.rowByTag("setting") as? AlertRow<String>{
                        return r1.value != "Teaching"
                    }
                    return true
                }
                
                if editingRecord?.teachingInfo != nil {
                    $0.value = editingRecord?.teachingInfo!.lecturer
                } else {
                    $0.value = ""
                }
            }
            <<< PushRow<String>("teachingtopic") {
                $0.title = "Topic:"
                $0.options = NLSelectionDataManger.sharedInstance.portfolioTopics()
                
                $0.hidden = Condition.Function(["setting"]) { form in
                    if let r1 : AlertRow<String> = form.rowByTag("setting") as? AlertRow<String>{
                        return r1.value != "Teaching"
                    }
                    return true
                }
                
                if editingRecord?.teachingInfo != nil {
                    $0.value = editingRecord?.teachingInfo!.topic
                } else {
                    $0.value = ""
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
        if form.values()["location"]! != nil && (!(form.values()["supervisorswitch"]! as! Bool == true) || form.values()["supervisorname"]! != nil) && checkTeachingFilled() {

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
            self.noticeSuccess("Saved!")
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.noticeSuccess("Missing info")
        }
        
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(),{
            self.clearAllNotice()
        })
    }
    
    func checkTeachingFilled() -> Bool {
        if form.values()["setting"] as! String == "Teaching" {
            if ((form.values()["teachingtitle"]! as! String != "") && (form.values()["teachingtopic"]! as! String != "") && (form.values()["teachinglecturer"]! as! String != "")) {
                return true
            } else {
                return false
            }
        }
        
        return true
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
