//
//  ViewController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

class NLMainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
            cell.textLabel?.text = record.disease + " in " + record.facility
            cell.detailTextLabel?.text = record.date + " at " + record.time
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
            self.performSegueWithIdentifier("NLCreateRecordSegue", sender: self)
            break;
        case 1, 2:
            self.performSegueWithIdentifier("NLDetailSegue", sender: self)
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
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NLCreateRecordSegue" {
            if selectedRow != -1 {
                let dest = segue.destinationViewController as! NLAddRecordVC
                dest.editingRecord = self.data[selectedRow] as? Record
                selectedRow = -1
            }
        }
        if segue.identifier == "NLDetailSegue" {
            let dest = segue.destinationViewController as! NLDetailRecordsVC
            
            switch self.segmented.selectedSegmentIndex {
            case 1:
                break
            case 2:
                dest.records = NLRecordsDataManager.sharedInstance.getRecordsWithFacility(data[selectedRow] as! String)
                break
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

