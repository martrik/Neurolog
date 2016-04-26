//
//  ViewController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import MessageUI
import UIAlertController_Blocks

class NLMainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var summaryView: NLStatsView!
    
    var data = [AnyObject]()
    var selectedRow = -1

    override func viewDidLoad() {
        super.viewDidLoad()
    
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 60
        table.registerNib(UINib(nibName: "NLRecordCell", bundle: nil), forCellReuseIdentifier: "NLRecordCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        // Get data
        self.loadDataAccordingSegmented()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NLRecordCell", forIndexPath: indexPath) as! NLRecordCell
        
        let elem = data[indexPath.row]
        if elem is Record {
            let record: Record = elem as! Record
            cell.setRecord(record)
            cell.selectionStyle = .Gray
            cell.tintColor = UIColor.appRed()
        }
        else if elem is String {
            cell.textLabel?.text = elem as? String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        switch segmented.selectedSegmentIndex {
        case 0:
            self.performSegueWithIdentifier("NLDetailSegue", sender: data[selectedRow])
            break;
        case 1:
            break;
        default:
            break;
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareRowAction = UITableViewRowAction(style: .Default, title: "Share", handler:{action, indexpath in
            let record = self.data[indexPath.row] as! Record
            self.shareRecords(record)
        });
        shareRowAction.backgroundColor = UIColor.appLightBlue()
        
        let deleteRow = UITableViewRowAction(style: .Destructive, title: "Delete", handler:{action, indexpath in
            UIAlertController.showAlertInViewController(self,
                withTitle: "Are you sure?",
                message: "You won't be able to recover this record and its cases.",
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: "Delete",
                otherButtonTitles: [],
                tapBlock: {(controller, action, buttonIndex) in
                    if (buttonIndex == controller.destructiveButtonIndex) {
                        let record = self.data[indexPath.row] as! Record
                        NLRecordsManager.sharedInstance.deleteRecord(record)
                        self.data = NLRecordsManager.sharedInstance.allRecords()
                        self.table.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                    else if (buttonIndex == controller.cancelButtonIndex) {
                        self.table.setEditing(false, animated: true)
                    }
            })
        })
        
        return [shareRowAction, deleteRow];
    }
    
    
    // MARK: Sharing
    
    func shareRecords(record: Record) {
        let csv = NLExportManager.sharedInstance.generateCSVWithRecord(record)
        
        func configuredMailComposeViewController() -> MFMailComposeViewController {
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self
            emailController.setSubject("Shared records")
            emailController.setMessageBody("", isHTML: false)
            
            // Attaching the .CSV file to the email.
            emailController.addAttachmentData(csv, mimeType: "text/csv", fileName: "Record.csv")
            
            return emailController
        }
        
        let emailViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(emailViewController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        if result == MFMailComposeResultSent {
            noticeSuccess("Sent!")
        } else if result == MFMailComposeResultFailed {
            noticeError("Failed...")
        }
        
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(),{
            self.clearAllNotice()
        })
    }
    
    
    // MARK: Selector
    
    @IBAction func segmentedValueChanged(sender: AnyObject) {
        if sender as! NSObject == segmented {
            self.loadDataAccordingSegmented()
        }
    }
    
    func loadDataAccordingSegmented() {
        switch segmented.selectedSegmentIndex {
        case 0:
            data = NLRecordsManager.sharedInstance.allRecords()
            switchToSummaryView(false)
            break;
        case 1:
            switchToSummaryView(true)
            break;
        default:
            break;
            
        }
        self.table.reloadData()
    }
    
    func switchToSummaryView(state: Bool) {
        table.hidden = state
        summaryView.hidden = !state
        
        if state {
            summaryView.displayGraphs()
        }
    }
    
    // MARK: Navigation bar buttons
    
    @IBAction func didTapAdd(sender: AnyObject) {
      self.performSegueWithIdentifier("NLAddRecordSegue", sender: self)
    }

    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let addRecord = segue.destinationViewController as? NLAddRecordVC {
            addRecord.didDismissWithRecord = { (record) -> Void in
                self.performSegueWithIdentifier("NLDetailSegue", sender: record)
            }
            let recordPC = addRecord.popoverPresentationController
            recordPC?.delegate = self
        }
        else if segue.identifier == "NLDetailSegue" {
            let dest = segue.destinationViewController as! NLDetailRecordVC
            dest.record = sender as! Record           
        }
        else if segue.identifier == "NLSharingOptionsSegue" {
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        return navController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

