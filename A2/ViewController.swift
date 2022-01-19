//
//  ViewController.swift
//  A2
//
//  Created by Ankush Karkar on 16/11/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    var locationManager:CLLocationManager!
    let apiId = "c874896c9c14f85c13a65911bccdde97"
    let url = "https://api.openweathermap.org/data/2.5/onecall?"
    let iconUrl = "https://openweathermap.org/img/wn/"
    let iconExt = "png"
    let iconSufix = "@2x"
    var allWeatherDetails:WeatherDetails?
    
    var location: CLLocation?

    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?

    // here I am declaring the iVars for city and country to access them later

    var city: String?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        getWeatherData(latitude: 19.076, longitude: 72.878)
        tableView.delegate=self
        tableView.dataSource=self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        let lat = userLocation.coordinate.latitude
        let lon = userLocation.coordinate.longitude
        
        getWeatherData(latitude: lat, longitude: lon)
    }

    func getWeatherData(latitude: Double, longitude: Double)
    {
        locationManager.getPlace(for: CLLocation(latitude: latitude, longitude: longitude)) { placemark in
            guard let placemark = placemark else { return }
            self.city = placemark.locality
            self.title = self.city
        }
        let session = URLSession.shared
        let query = "lat=\(latitude)&lon=\(longitude)&exclude=hourly,minutely&appid=\(apiId)"
        let queryUrl = URL(string: url + query)!
        let apiCall = session.dataTask(with: queryUrl){data, response, error in
            if error != nil || data == nil {
                print("Error!")
            }
            
            let r = response as? HTTPURLResponse
                   guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode)else{
                       print("Error!! \(String(describing: r?.statusCode))")
                       return
                   }
                   
                   guard let mime = response.mimeType, mime == "application/json" else{
                       print("MIME Error!!: \(String(describing:r?.mimeType))")
                       return
                   }
                   
                   do{
                       let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                    self.allWeatherDetails = WeatherDetails(with: json)
                    DispatchQueue.main.async {
                            self.tableView.reloadData()
                          }
                       
                   }catch{
                       print("Error!!")
                       return
                   }
                   
                   
               }
               
               apiCall.resume()
           }

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        let controller = storyboard.instantiateViewController(withIdentifier: "wDetails") as! WeatherDetailsViewController
        controller.wDetails = allWeatherDetails?.DailyWeather?[indexPath.row]
        controller.city = city
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allWeatherDetails?.DailyWeather?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as? CustomTableViewCell else{
            return UITableViewCell()
        }
        let selectedVal = allWeatherDetails?.DailyWeather?[indexPath.row]
        cell.wImage.imageFrom(url: (selectedVal?.imgUrl)!)
        if(indexPath.row==0){
            cell.wDay.text = "Current"
        }else{
            cell.wDay.text = selectedVal?.dt
        }

        cell.wName.text = selectedVal?.weatherType
        cell.wTemp.text = "\((selectedVal?.temp ?? convertTemp(selectedVal?.tempCol?.max))!) C"
        return cell
    }
    

}

extension CLLocationManager {
    
    
    func getPlace(for location: CLLocation,
                  completion: @escaping (CLPlacemark?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            guard error == nil else {
                print("Error \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("Error \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
}
