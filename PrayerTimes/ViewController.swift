//
//  ViewController.swift
//  PrayerTimes
//
//  Created by Daniya on 12/04/2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
        
        
    }


    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        let urlCustomMethod = URL(string: "https://api.aladhan.com/v1/timings?latitude=\(locValue.latitude)&\(locValue.longitude)&method=99&methodSettings=18.0,null,15.0")!
        
        let urlMWL = URL(string: "https://api.aladhan.com/v1/timings?latitude=\(locValue.latitude)&\(locValue.longitude)&method=3")!
        
        let jsonDecoder = JSONDecoder()
        
        URLSession.shared.dataTask(with: urlMWL) { data, response, error in
            
            let dataString = String(decoding: data!, as: UTF8.self)
            print(dataString)
            
            guard let data = data else {return}
            
            let prayerTime = try! jsonDecoder.decode(PrayerData.self, from: data)
            
            DispatchQueue.main.async {
                self.textLabel.text = """
                \(prayerTime.data.meta.method.name): Farj - \(prayerTime.data.meta.method.params.fajr), Isha - \(prayerTime.data.meta.method.params.isha)
                \(prayerTime.data.timings.fajr)
                \(prayerTime.data.timings.sunrise)
                \(prayerTime.data.timings.dhuhr)
                \(prayerTime.data.timings.asr)
                \(prayerTime.data.timings.maghrib)
                \(prayerTime.data.timings.isha)
                """
            }
            
        }.resume()
    }
    
}

