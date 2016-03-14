//
//  ViewController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    var data = [Record]()
    var selectedRow = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.delegate = self
        self.table.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Get data
        data = RecordsDataManager.sharedInstance.getAllRecords()
        self.table.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recordcell", forIndexPath: indexPath)
        
        let record = data[indexPath.row]
        
        cell.textLabel?.text = record.disease + " in " + record.facility
        cell.detailTextLabel?.text = record.date + " at " + record.time
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        self.performSegueWithIdentifier("CreateRecordSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateRecordSegue" {
            let dest = segue.destinationViewController as! AddRecord
            dest.editingRecord = self.data[selectedRow];
            
        }
    }
    


}

