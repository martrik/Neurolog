//
//  ViewController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

class NLMainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    
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
            cell.settingLabel.text = record.facility
            cell.updateSettingLabelColor()
            cell.locationLabel.text = record.location
            
            let timeFormatter = NSDateFormatter()
            timeFormatter.locale = NSLocale.currentLocale()
            timeFormatter.dateStyle = .ShortStyle
            cell.dateLabel.text  = timeFormatter.stringFromDate(record.date)
            
            cell.visitsLabel.text = String(record.visits.count)
            cell.setSigned(record.signaturePath != nil)
            
            cell.selectionStyle = .None
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
        
        if selectingRows {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            selectedRows.append(selectedRow)
        } else {
            switch segmented.selectedSegmentIndex {
            case 0:
                self.performSegueWithIdentifier("NLDetailSegue", sender: data[selectedRow])
                break;
            case 1, 2:
                break;
            default:
                break;
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if selectingRows {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            if let index = selectedRows.indexOf(indexPath.row) {
                selectedRows.removeAtIndex(index)
            }
        }
    }
    
    // MARK: Share records

    @IBAction func didTapLeftNavBarButton(sender: AnyObject) {
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
        
        selectingRows = !selectingRows
    }
    
    func selectAllRows(state: Bool) {
        for var i = 0; i < table.numberOfRowsInSection(0); i++ {
            if state {
                selectedRows.append(i)
            } else {
                if let index = selectedRows.indexOf(i) {
                    selectedRows.removeAtIndex(index)
                }
            }
        }
        table.reloadData()
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
            data = NLRecordsDataManager.sharedInstance.getAllRecords()
            break;
        case 1:
            //data = SelectionDataManger.sharedInstance.ge
            break;
        case 2:
            data = NLSelectionDataManger.sharedInstance.getClinicalSettings()
            break;
        default:
            break;
            
        }
        self.table.reloadData()
    }
    
    @IBAction func didTapAdd(sender: AnyObject) {
        if selectingRows {
            selectAllRows(true)
        } else {
            self.performSegueWithIdentifier("NLAddRecordSegue", sender: self)
        }
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

