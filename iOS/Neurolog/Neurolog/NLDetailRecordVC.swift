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

class NLDetailRecordVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var addNavBarButton: UIBarButtonItem!
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var lecturerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var supervisorLabel: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var dateVerticalDistance: NSLayoutConstraint!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var bigApproveBottom: NSLayoutConstraint!
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
    }
    
    func loadUI() {
        // Fill top labels
        setAttributed(settingLabel, title: "Setting: ", text: record.setting, size: 19)

        if record.setting == "Teaching" {
            setAttributed(lecturerLabel, title: "Lecturer: ", text: record.teachingInfo!.lecturer, size: 16)
            setAttributed(topicLabel, title: "Topic: ", text: record.teachingInfo!.topic, size: 16)
            setAttributed(titleLabel, title: "Title: ", text: record.teachingInfo!.title, size: 16)
            dateVerticalDistance.constant = CGRectGetMaxY(topicLabel.frame) - CGRectGetMaxY(settingLabel.frame) + 12
        } else {
            lecturerLabel.removeFromSuperview()
            topicLabel.removeFromSuperview()
            titleLabel.removeFromSuperview()
            dateVerticalDistance.constant = 8
        }
        
        setAttributed(locationLabel, title: "Location: ", text: record.location, size: 19)
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .MediumStyle
        setAttributed(dateLabel, title: "Date: ", text: timeFormatter.stringFromDate(record.date), size: 19)
        
        if let supervisor = record.supervisor {
            setAttributed(supervisorLabel, title: "Supervisor: ", text: supervisor, size: 19)
        } else {
            setAttributed(supervisorLabel, title: "Supervisor: ", text: "none", size: 19)
        }
        
        updateApproveButton(false)
        addNavBarButton.enabled = record.setting != "Teaching"
    }
    
    func setAttributed(label: UILabel!, title: String, text: String, size: CGFloat) {
        var titleAttrib = [String : NSObject]()
        titleAttrib[NSFontAttributeName] = UIFont.systemFontOfSize(size, weight: UIFontWeightRegular)
        titleAttrib[NSForegroundColorAttributeName] = UIColor.blackColor()
        
        var textAttrib = [String : NSObject]()
        textAttrib[NSFontAttributeName] = UIFont.systemFontOfSize(size-3, weight: UIFontWeightLight)
        textAttrib[NSForegroundColorAttributeName] = UIColor.blackColor()
        
        let title = NSMutableAttributedString(string: title, attributes: titleAttrib)
        title.appendAttributedString(NSAttributedString(string: text, attributes: textAttrib))
        label.attributedText = title
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete", handler:{action, indexpath in
            UIAlertController.showAlertInViewController(self,
                withTitle: "Are you sure?",
                message: "You won't be able to recover this case.",
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: "Delete",
                otherButtonTitles: [],
                tapBlock: {(controller, action, buttonIndex) in
                    if (buttonIndex == controller.destructiveButtonIndex) {
                        NLVisitsManager.sharedInstance.deleteVisitFromRecord(self.record.visits[indexPath.row], record: self.record)
                        self.table.reloadData()
                    }
                    else if (buttonIndex == controller.cancelButtonIndex) {
                        self.table.setEditing(false, animated: true)
                    }
            })
        })
        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit", handler:{action, indexpath in
            self.performSegueWithIdentifier("NLEditVisit", sender: self.record.visits[indexPath.row])
        })
        
        return [deleteRowAction, editRowAction];
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
                    let writePath = documentsURL.URLByAppendingPathComponent("signature-\(self.record.supervisor!)-\(NSDate()).jpg")
                    imageData.writeToURL(writePath, atomically: true)
                  
                    NLRecordsManager.sharedInstance.approveRecord(self.record, signaturePath: String(writePath))
                    
                    self.updateApproveButton(true)
                }
            })

            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let url = NSURL(string: record.signaturePath!)
            let agrume = Agrume(imageURL: url!)
            agrume.showFrom(self)
        }
    }
    
    func updateApproveButton(animated: Bool) {
        if (record.supervisor != nil) {
            if record.signaturePath != nil {
                approveButton.backgroundColor = UIColor.clearColor()
                approveButton.setImage(UIImage(named: "signedBadge"), forState: .Normal)
                approveButton.frame = CGRectMake(approveButton.frame.origin.x, approveButton.frame.origin.y, 25, 25)
                bigApproveBottom.constant = -50
                approveButton.center = CGPointMake(approveButton.center.x, supervisorLabel.center.y)
                approveButton.hidden = false                
            } else {
                approveButton.hidden = true
            }
        }
        else {
            approveButton.hidden = true
            bigApproveBottom.constant = -50
        }
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let addRecord = segue.destinationViewController as? NLAddRecordVC {
            addRecord.editingRecord = self.record
            addRecord.didDismissWithRecord = { (record) -> Void in
                self.record = record
                self.loadUI()
            }
            let recordPC = addRecord.popoverPresentationController
            recordPC?.delegate = self
        }
        else if segue.identifier == "NLAddVisitSegue" {
            let dest = segue.destinationViewController as! NLAddVisitVC
            dest.record = record
        }
        else if let editVisit = segue.destinationViewController as? NLAddVisitVC {
            editVisit.edittingVisit = sender as? Visit
            editVisit.record = record
            editVisit.didDismiss = { () -> Void in
                self.table.reloadData()
            }
            let visitVC = editVisit.popoverPresentationController
            visitVC?.delegate = self
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
