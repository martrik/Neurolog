//
//  ViewController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import MessageUI

class NLMainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var summaryView: NLStatsView!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareButtonBottom: NSLayoutConstraint!
    
    var selectingRows = false
    var selectedRows = [Int]()
    
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
            cell.accessoryType = (selectedRows.contains(indexPath.row)  ? .Checkmark : .None)
        }
        else if elem is String {
            cell.textLabel?.text = elem as? String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        if selectingRows {
            selectedRowShare(indexPath)
        } else {
            switch segmented.selectedSegmentIndex {
            case 0:
                if let record = data[selectedRow] as? Record {
                    self.performSegueWithIdentifier("NLDetailSegue", sender: data[selectedRow])
                }
                break;
            case 1, 2:
                break;
            default:
                break;
            }
        }
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Share", handler:{action, indexpath in
            let record = self.data[indexPath.row] as! Record
            self.shareRecords([record])
        });
        shareRowAction.backgroundColor = UIColor.appLightBlue()
        
        return [shareRowAction];
    }
    
    
    // MARK: Sharing
    
    func selectedRowShare(indexPath: NSIndexPath) {
        if let index = selectedRows.indexOf(indexPath.row) {
            table.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            selectedRows.removeAtIndex(index)
        } else {
            selectedRows.append(indexPath.row)
            table.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        }
        
        updateShareButton()
    }
    
    func selectAllRows(state: Bool) {
        for i in 0 ..< table.numberOfRowsInSection(0) {
            if state {
                if selectedRows.indexOf(i) == nil {
                    selectedRows.append(i)
                }
            } else {
                if let index = selectedRows.indexOf(i) {
                    selectedRows.removeAtIndex(index)
                }
            }
        }
        table.reloadData()
        updateShareButton()
    }
    
    func toggleShareButton(state: Bool) {
        shareButtonBottom.constant = (state ? 0 : -CGRectGetHeight(shareButton.frame))
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.shareButton.alpha = (state ? 1 : 0)
            self.shareButton.layoutIfNeeded()
        }
        
        updateShareButton()
    }
    
    func updateShareButton() {
        if selectedRows.count == 0 {
            shareButton.setTitle("Select the records you want to share", forState: UIControlState.Normal)
        } else {
            shareButton.setTitle("Share this \(selectedRows.count) record" + (selectedRows.count == 1 ? "" : "s"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func didTapShareRecordsButton(sender: AnyObject) {
        if selectedRows.count > 0 {
                        
            // Unwrapping the optional.
            var records = [Record]()
            
            for i in selectedRows {
                records.append(data[i] as! Record)
            }
            
            shareRecords(records)
        }
    }
    
    func shareRecords(records: [Record]) {
        let csv = NLRecordsDataManager.sharedInstance.generateCSVWithRecords(records)
        
        func configuredMailComposeViewController() -> MFMailComposeViewController {
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self
            emailController.setSubject("Shared records")
            emailController.setMessageBody("", isHTML: false)
            
            // Attaching the .CSV file to the email.
            emailController.addAttachmentData(csv, mimeType: "text/csv", fileName: "Records.csv")
            
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
            changeNavButtonsState()
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
        
        print(NLStatsManager.sharedInstance.statsForClinicalSettings())
    }
    
    func loadDataAccordingSegmented() {
        switch segmented.selectedSegmentIndex {
        case 0:
            data = NLRecordsDataManager.sharedInstance.allRecords()
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
        if selectingRows {
            selectAllRows(true)
        } else {
            self.performSegueWithIdentifier("NLAddRecordSegue", sender: self)
        }
    }
    
    
    @IBAction func didTapLeftNavBarButton(sender: AnyObject) {
        changeNavButtonsState()
    }
    
    func changeNavButtonsState() {
        if selectingRows {
            leftNavBarButton.title = "Share"
            leftNavBarButton.tintColor = UIColor.appLightBlue()
            table.allowsMultipleSelection = false
            
            rightNavBarButton.title = "New record"
            
            // Uncheck all cells
            selectAllRows(false)
        } else {
            leftNavBarButton.title = "Cancel"
            leftNavBarButton.tintColor = UIColor.appRed()
            table.allowsMultipleSelection = true
            
            rightNavBarButton.title = "Select all"
        }
        toggleShareButton(!selectingRows)
        selectingRows = !selectingRows
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
        if segue.identifier == "NLDetailSegue" {
            let dest = segue.destinationViewController as! NLDetailRecordVC
            dest.record = sender as! Record           
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

