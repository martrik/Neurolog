//
//  NLDetailRecordsController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 14/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import SimpleAlert

class NLDetailRecordVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var supervisorLabel: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var signedBadge: UIImageView!
    
    @IBOutlet weak var table: UITableView!
    internal var record = Record()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 60
        table.registerNib(UINib(nibName: "NLVisitCell", bundle: nil), forCellReuseIdentifier: "NLVisitCell")
        
        loadUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.table.reloadData()
        
        self.updateApproveButton()
    }
    
    func loadUI() {
        // Fill top labels
        settingLabel.text = "Setting: " + record.facility
        locationLabel.text = "Location: " + record.location
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .MediumStyle
        dateLabel.text = "Date: " + timeFormatter.stringFromDate(record.date)
        
        if let supervisor = record.supervisor {
            supervisorLabel.text = "Supervisor: " + supervisor
        } else {
            supervisorLabel.text = "Supervisor: none"
        }
    }
    
    func updateApproveButton() {
        if (record.supervisor != nil && !record.signed) {
            approveButton.hidden = false
            signedBadge.hidden = true
        }
        else {
            approveButton.hidden = true
            signedBadge.hidden = true

            if record.signed {
                signedBadge.hidden = false
            }
        }
    }
    
    // MARK: Table Delegate

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return record.visits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NLVisitCell", forIndexPath: indexPath) as! NLVisitCell
        
        let visit = record.visits[indexPath.row]
        cell.disease.text = visit.topic
        cell.info.text =  "Sex: " + visit.sex + " Age: " + String(visit.age)
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.locale = NSLocale.currentLocale()
        timeFormatter.timeStyle = .MediumStyle
        cell.time.text = timeFormatter.stringFromDate(visit.time)
    
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        table.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Approve supervisor
    
    @IBAction func didTapApprove(sender: AnyObject) {
        let viewController = SignatureVC()
        let alert = SimpleAlert.Controller(view: viewController.view, style: .ActionSheet)
        
        alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Destructive) { action in
        })
        
        alert.addAction(SimpleAlert.Action(title: "I approve these visits", style: .OK) { action in
            if viewController.signatureView?.hasSignature == true {
                NLRecordsDataManager.sharedInstance.approveRecord(self.record, signed: true)
                self.updateApproveButton()
            }
        })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NLUpdateRecordSegue" {
            let dest = segue.destinationViewController as! NLAddRecordVC
            dest.editingRecord = record
        }
        if segue.identifier == "NLAddVisitSegue" {
            let dest = segue.destinationViewController as! NLAddVisitVC
            dest.record = record
        }
    }

}
