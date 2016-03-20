//
//  NLDetailRecordsController.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 14/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import SimpleAlert
import Agrume

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
        if record.signaturePath == nil {
            let viewController = SignatureVC()
            let alert = SimpleAlert.Controller(view: viewController.view, style: .ActionSheet)
            viewController.setExplainLabel(record.supervisor!)

            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Destructive) { action in
            })
            
            // Save image
            alert.addAction(SimpleAlert.Action(title: "I approve these visits", style: .OK) { action in
                if viewController.signatureView?.hasSignature == true {
                    let imageData = NSData(data: UIImageJPEGRepresentation(viewController.getSignature(), 0.8)!)

                    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    let writePath = documentsURL.URLByAppendingPathComponent("signature-\(self.record.supervisor!).jpg")
                    imageData.writeToURL(writePath, atomically: true)
                  
                    NLRecordsDataManager.sharedInstance.approveRecord(self.record, signaturePath: String(writePath))
                    self.updateApproveButton()
                }
            })
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let url = NSURL(string: record.signaturePath!)
            let agrume = Agrume(imageURL: url!)
            agrume.showFrom(self)
            
        }
    }
    
    func updateApproveButton() {
        if (record.supervisor != nil && record.signaturePath != nil) {
            approveButton.backgroundColor = UIColor.clearColor()
            approveButton.setImage(UIImage(named: "signedBadge"), forState: .Normal)
            approveButton.frame = CGRectMake(approveButton.frame.origin.x, approveButton.frame.origin.y, 25, 25)
        } else if (record.supervisor == nil) {
            approveButton.hidden = true
        }
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
