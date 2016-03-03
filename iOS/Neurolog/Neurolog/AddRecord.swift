//
//  AddRecord.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class AddRecord: UIViewController, UITextFieldDelegate {

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
            ActionSheetStringPicker.showPickerWithTitle("Select:", rows: ["Hello", "There"], initialSelection: 0, doneBlock: { (actionSheet:ActionSheetStringPicker!, index: Int, selected: AnyObject!) -> Void in
                    print("Selected")
                }, cancelBlock: nil, origin: textField)
            
        }
        return false;
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
