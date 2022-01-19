//
//  WeatherDetails.swift
//  A2
//
//  Created by Ankush Karkar on 17/11/21.
//

import Foundation

struct WeatherDetails {
    var lat:Double?
    var lon:Double?
    var DailyWeather:[WeatherItem]?
    
    init(with json: [String: Any]?) {
        guard let json = json else { return }
        lat = json["lat"] as? Double
        lon = json["lon"] as? Double
        guard let dailyJson = json["daily"] as? [[String : Any]] else { return }
        DailyWeather=[]
        for j in dailyJson{
            DailyWeather?.append(WeatherItem(with: j))
        }
    }
}

struct WeatherItem {
    var dt:String?
    var temp:String?
    var feelsLike:String?
    var weatherType:String?
    var weatherDesc:String?
    var icon:String?
    var tempCol:TempCollection?
    var feelsLikeCol:TempCollection?
    var windSpeed:String?
    var humidity:String?
    var imgUrl:URL?
    let baseUrl = "https://openweathermap.org/img/wn/"
    let iconExt = "png"
    let iconSufix = "@2x"
    
    init(with json: [String: Any]?) {
        guard let json = json else { return }
        let date = Date(timeIntervalSince1970: (json["dt"] as? Double)!)
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
        let sdate = dateFormatter.string(from: date)
        dt = sdate
        temp = convertTemp(json["temp"] as? Double)
        feelsLike = convertTemp(json["feels_like"] as? Double)
        tempCol=TempCollection(with: json["temp"] as? [String : Any])
        feelsLikeCol=TempCollection(with: json["feels_like"] as? [String : Any])
        windSpeed = String(format:"Wind: %.0f km/h",(json["wind_speed"] as? Double)!)
        humidity = "Humidity: \(String(describing: json["humidity"] as! Int))%"
        guard let weatherJson = json["weather"] as? [[String : Any]] else { return }
        weatherType = weatherJson[0]["main"] as? String
        weatherDesc = weatherJson[0]["description"] as? String
        icon = weatherJson[0]["icon"] as? String
        imgUrl=URL(string:baseUrl+icon!+iconSufix+"."+iconExt)!
        
    }
}

struct TempCollection {
    var day:Double?
    var min:Double?
    var max:Double?
    var night:Double?
    var eve:Double?
    var morn:Double?
    
    init(with json: [String: Any]?) {
      guard let json = json else { return }
        day = json["day"] as? Double
      min = json["min"] as? Double
      max = json["max"] as? Double
      night = json["eve"] as? Double
      eve = json["night"] as? Double
      morn = json["morn"] as? Double
    }
}

func convertTemp(_ temp:Double?)->String?{
    if(temp==nil){
        return nil
    }
    let measurementInKelvin = Measurement(value:temp!, unit: UnitTemperature.kelvin)
    let measurementInCelcius = measurementInKelvin.converted(to: .celsius)
    let mFormatter = MeasurementFormatter()
    mFormatter.unitStyle = .short
    mFormatter.numberFormatter.maximumFractionDigits = 0
    mFormatter.unitOptions = .temperatureWithoutUnit
    return mFormatter.string(from:measurementInCelcius)
}
