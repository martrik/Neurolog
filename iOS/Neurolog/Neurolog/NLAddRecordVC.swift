//
//  AddRecord.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class NLAddRecordVC: UIViewController, UITextFieldDelegate {

    internal var editingRecord: Record? = nil
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var facilityField: UITextField!
    @IBOutlet weak var portfolioField: UITextField!
    @IBOutlet weak var diseaseField: UITextField!
    var datePicker: DatePickerDialog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Text fields
        self.dateField.delegate = self
        self.timeField.delegate = self
        self.facilityField.delegate = self
        self.portfolioField.delegate = self
        self.diseaseField.delegate = self
        enableDiseasesField(false)
        
        // Is editing
        if let record = self.editingRecord {
            self.dateField.text = record.date
            self.timeField.text = record.time
            self.facilityField.text = record.facility
            self.portfolioField.text = record.portfolio
            self.diseaseField.text = record.disease
            enableDiseasesField(true)
            
            self.title = "Update record"
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField == dateField) {
            DatePickerDialog().show("Select the date:", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
                (date) -> Void in
                let dateFormatter = NSDateFormatter()
                dateFormatter.locale = NSLocale.currentLocale()
                dateFormatter.dateStyle = .FullStyle
                
                self.dateField.text = "\(dateFormatter.stringFromDate(date))"
            }
        }
        else if (textField == timeField) {
            DatePickerDialog().show("Select the time:", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Time) {
                (time) -> Void in
                
                let timeFormatter = NSDateFormatter()
                timeFormatter.locale = NSLocale.currentLocale()
                timeFormatter.timeStyle = .MediumStyle

                self.timeField.text = "\(timeFormatter.stringFromDate(time))"
            }
        }
        else {
            var rows = [String]()
            
            switch textField {
            case facilityField:
                rows = NLSelectionDataManger.sharedInstance.getFacilities()
            case portfolioField:
                rows = NLSelectionDataManger.sharedInstance.getPortfolioTopics()
            case diseaseField:
                rows = NLSelectionDataManger.sharedInstance.getDiseaseForPortfolio(portfolioField.text!)
            default:
                break
            }
            
            ActionSheetStringPicker.showPickerWithTitle("Select:", rows: rows, initialSelection: 0, doneBlock: { (actionSheet:ActionSheetStringPicker!, index: Int, selected: AnyObject!) -> Void in
                    textField.text = selected as! String!
                if textField == self.portfolioField {
                    self.enableDiseasesField(true)
                }
                }, cancelBlock: nil, origin: textField)
            
        }
        return false;
    }
    
    func enableDiseasesField(state: Bool) {
        diseaseField.alpha = state ? 1 : 0.6
        diseaseField.enabled = state
    }

    // MARK: - Save
    
    @IBAction func didTapSave(sender: AnyObject) {
        let info = [dateField.text!, timeField.text!, facilityField.text!, portfolioField.text!,diseaseField.text!]
        
        if let record = editingRecord {
            NLRecordsDataManager.sharedInstance.updateRecord(record, info: info, signed: false, supervisor: nil)
        } else {
            NLRecordsDataManager.sharedInstance.saveRecordWith(info, signed: false, supervisor: nil)
        }
        
        if self.editingRecord == nil {
            self.noticeSuccess("Saved!")
        } else {
            self.noticeSuccess("Updated!")
        }
        
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.clearAllNotice()
        })
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
