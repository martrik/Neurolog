//
//  NLAddVisit.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 15/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import Eureka


class NLAddVisitVC: FormViewController {
    
    var record: Record? = nil
    var filledRows = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form  +++=
            
            Section(footer: "Tap on save to store this Visit")
            
            <<< TimeRow("time") {
                $0.value = NSDate();
                $0.title = "Date:"
            }.onChange({ (row) -> () in
                if row.value != nil {
                    
                } else {
                        
                }
            })
            <<< PushRow<String>("disease") { (row : PushRow<String>) -> Void in
                row.title = "Disease:"
                row.options = NLSelectionDataManger.sharedInstance.getPortfolioTopics()
                
            }
            <<< PushRow<String>("age") { (row : PushRow<String>) -> Void in
                row.title = "Age:"
                let ages: [Int] = Array(1...120)
                let stringAges = ages.map { String($0) }
                row.options = stringAges
            }
            <<< ActionSheetRow<String>("sex") { (row : ActionSheetRow<String>) -> Void in
                row.title = "Sex:"
                row.options = ["Male", "Female"]
            }
    }

    @IBAction func didTapSave(sender: AnyObject) {
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))

        if form.values()["disease"]! != nil && form.values()["age"]! != nil && form.values()["sex"]! != nil{
            NLRecordsDataManager.sharedInstance.saveVisitInRecord(record!, info: form.values())
            self.noticeSuccess("Saved!")
            dispatch_after(dispatchTime, dispatch_get_main_queue(),{
                self.clearAllNotice()
            })
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.noticeInfo("Info missing")
            dispatch_after(dispatchTime, dispatch_get_main_queue(),{
                self.clearAllNotice()
            })

        }
        
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
