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
        clinicalSettingsGraph(CGRectMake(CGRectGetWidth(self.frame)*(0.5-0.45), 20, CGRectGetWidth(self.frame)*0.95, 200))
        ageRangesGraph(CGRectMake(CGRectGetWidth(self.frame)*(0.5-0.45), 220, CGRectGetWidth(self.frame)*0.95, 250))
        print(NLStatsManager.sharedInstance.statsForAgeRanges())
    }
    
    func clinicalSettingsGraph(frame: CGRect) {
        let (xValues, yValues) = NLStatsManager.sharedInstance.statsForClinicalSettings()
        drawBarGraphWithData(yValues.reverse(), xValues: xValues.reverse(), frame: frame, description:  "Records per setting", colors: UIColor.graphColors().reverse())
    }
    
    func ageRangesGraph(frame: CGRect) {
        let (xValues, yValues) = NLStatsManager.sharedInstance.statsForAgeRanges()
        drawBarGraphWithData(yValues.reverse(), xValues: xValues.reverse(), frame: frame, description:  "Visits per age range", colors: nil)
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
        //settingsBarChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .EaseInBack)
        self.addSubview(settingsBarChart)
    }

}
