//
//  NLDetailRecordsController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 14/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

class NLDetailRecordsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    internal var records = [Record]()
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table
        self.table.delegate = self
        self.table.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.table.reloadData()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recordcell", forIndexPath: indexPath)
        
        let record = records[indexPath.row]
        cell.textLabel?.text = record.disease + " in " + record.facility
        cell.detailTextLabel?.text = record.date + " at " + record.time
    
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        self.performSegueWithIdentifier("NLUpdateRecordSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NLUpdateRecordSegue" {
            let dest = segue.destinationViewController as! NLAddRecordVC
            dest.editingRecord = records[selectedRow]
        }
    }

}
