//
//  WeatherDetailsViewController.swift
//  A2
//
//  Created by Ankush Karkar on 22/11/21.
//

import UIKit
import Charts

class WeatherDetailsViewController: UIViewController{

    var wDetails:WeatherItem?
    var city:String?
    var axisFormatDelegate: IAxisValueFormatter?
    var tempXStrings:[String]!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tempXStrings = ["Morning","Day","Evening","Night","Min","Max"]
        axisFormatDelegate = self
        cityNameLabel.text = city ?? ""
        weatherImageView.imageFrom(url: (wDetails?.imgUrl)!)
        weatherNameLabel.text = wDetails?.weatherType
        tempLabel.text = "\(String(describing: (wDetails?.temp ?? convertTemp(wDetails?.tempCol?.max))!)) C"
        windSpeedLabel.text = wDetails?.windSpeed!
        humidityLabel.text = wDetails?.humidity!
        setChartValues()
    }
    
    func setChartValues(){
        let entries  = [
            BarChartDataEntry(x: 0, y: getTempInDouble((wDetails?.tempCol?.morn)!), data: tempXStrings),
            BarChartDataEntry(x: 1, y: getTempInDouble((wDetails?.tempCol?.day)!), data: tempXStrings),
            BarChartDataEntry(x: 2, y: getTempInDouble((wDetails?.tempCol?.eve)!), data: tempXStrings),
            BarChartDataEntry(x: 3, y: getTempInDouble((wDetails?.tempCol?.night)!), data: tempXStrings),
            BarChartDataEntry(x: 4, y: getTempInDouble((wDetails?.tempCol?.min)!), data: tempXStrings),
            BarChartDataEntry(x: 5, y: getTempInDouble((wDetails?.tempCol?.max)!), data: tempXStrings),
        ]
        
        let set = BarChartDataSet(entries: entries, label: "Temperature distribution")
        set.colors = ChartColorTemplates.colorful()
        let data = BarChartData(dataSet: set)
        let xAxisValue = barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChartView.data=data
        
    }
    
    func getTempInDouble(_ temp:Double)->Double{
        let measurementInKelvin = Measurement(value:temp, unit: UnitTemperature.kelvin)
        let measurementInCelcius = measurementInKelvin.converted(to: .celsius)
        let mFormatter = MeasurementFormatter()
        mFormatter.unitStyle = .short
        mFormatter.numberFormatter.maximumFractionDigits = 0
        mFormatter.unitOptions = .temperatureWithoutUnit
        return measurementInCelcius.value.rounded()
    }
}

extension WeatherDetailsViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    return tempXStrings[Int(value)]
    }
}
