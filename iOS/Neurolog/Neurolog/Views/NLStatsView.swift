//
//  StatsView.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 20/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import Charts

class NLStatsView: UIView {
    
    override func awakeFromNib() {
    }
    
    func displayGraphs() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        let settingLabel = UILabel(frame: CGRectMake(20, 15, 250, 20))
        settingLabel.text = "Records per clinical setting:"
        settingLabel.font = UIFont.systemFontOfSize(16)
        self.addSubview(settingLabel)
        
        clinicalSettingsGraph(CGRectMake(CGRectGetWidth(self.frame)*(0.5-0.45), 40, CGRectGetWidth(self.frame)*0.95, 180))
        
        let ageLabel = UILabel(frame: CGRectMake(20, 230, 250, 20))
        ageLabel.text = "Cases per age range:"
        ageLabel.font = UIFont.systemFontOfSize(16)
        self.addSubview(ageLabel)
        
        ageRangesGraph(CGRectMake(CGRectGetWidth(self.frame)*(0.5-0.45), 260, CGRectGetWidth(self.frame)*0.95, 250))
        
        
        let topicLabel = UILabel(frame: CGRectMake(20, 520, 250, 20))
        topicLabel.text = "Cases per topic:"
        topicLabel.font = UIFont.systemFontOfSize(16)
        self.addSubview(topicLabel)
        
        visitTopicsGraph(CGRectMake(CGRectGetWidth(self.frame)*(0.5-0.45), 540, CGRectGetWidth(self.frame)*0.95, 300))
    }
    
    func clinicalSettingsGraph(frame: CGRect) {
        let (xValues, yValues) = NLStatsManager.sharedInstance.statsForClinicalSettings()
        drawBarGraphWithData(yValues.reverse(), xValues: xValues.reverse(), frame: frame, description:  "Records per setting", colors: UIColor.graphColors().reverse())
    }
    
    
    func ageRangesGraph(frame: CGRect) {
        let (xValues, yValues) = NLStatsManager.sharedInstance.statsForAgeRanges()
        drawBarGraphWithData(yValues.reverse(), xValues: xValues.reverse(), frame: frame, description:  "Visits per age range", colors: nil)
    }
    
    
    func visitTopicsGraph(frame: CGRect) {
        let (xValues, yValues) = NLStatsManager.sharedInstance.statsForTopics(NSDate(timeIntervalSince1970: 0), to: NSDate())
        drawBarGraphWithData(yValues.reverse(), xValues: xValues.reverse(), frame: frame, description:  "Cases per topic", colors: nil)
    }
    
    
    func drawBarGraphWithData(yValues: [Int], xValues: [String], frame: CGRect, description: String, colors: [UIColor]?) {
        var dataEntries: [BarChartDataEntry] = []
        for (index, value) in yValues.enumerate() {
            let dataEntry = BarChartDataEntry(value: Double(value), xIndex: index)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.valueFormatter = NSNumberFormatter()
        if colors != nil {
            chartDataSet.setColors(colors!, alpha: 1)
        } else {
            chartDataSet.setColor(UIColor.appLightBlue())
        }
        
        let settingsBarChart = HorizontalBarChartView(frame: frame)
        let chartData = BarChartData(xVals: xValues, dataSet: chartDataSet)
        settingsBarChart.clipsToBounds = false
        settingsBarChart.data = chartData
        settingsBarChart.xAxis
        settingsBarChart.descriptionText = ""
        settingsBarChart.legend.enabled = false
        settingsBarChart.xAxis.drawGridLinesEnabled = false
        settingsBarChart.xAxis.labelPosition = .Bottom
        settingsBarChart.xAxis.drawAxisLineEnabled = false
        settingsBarChart.xAxis.labelFont = UIFont.systemFontOfSize(11, weight: UIFontWeightLight)
        settingsBarChart.rightAxis.enabled = false
        settingsBarChart.leftAxis.enabled = false
        settingsBarChart.leftAxis.drawAxisLineEnabled = false
        settingsBarChart.leftAxis.valueFormatter = NSNumberFormatter()
        settingsBarChart.pinchZoomEnabled = false
        //settingsBarChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .EaseInBack)
        self.addSubview(settingsBarChart)
    }

}
