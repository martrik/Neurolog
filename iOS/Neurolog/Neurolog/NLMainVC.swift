//
//  ViewController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

class NLMainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    
    var data = [AnyObject]()
    var selectedRow = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
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
        var cell: UITableViewCell!
        
        switch self.segmented.selectedSegmentIndex {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("recordcell", forIndexPath: indexPath)
            break;
        case 1, 2:
            cell = tableView.dequeueReusableCellWithIdentifier("detailcell", forIndexPath: indexPath)
            break;
        default:
            break;
            
        }
        
        let elem = data[indexPath.row]
        if elem is Record {
            let record: Record = elem as! Record
            cell.textLabel?.text = record.facility + " at " + record.location
            //cell.detailTextLabel?.text = record.date + " at " + record.time
        }
        else if elem is String {
            cell.textLabel?.text = elem as? String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row

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

    // MARK: - Selector
    
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
            data = NLSelectionDataManger.sharedInstance.getFacilities()
            break;
        default:
            break;
            
        }
        self.table.reloadData()
    }
    
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

