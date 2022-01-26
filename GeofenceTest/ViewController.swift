//
//  ViewController.swift
//  GeofenceTest
//
//  Created by Davi Chaves on 1/26/22.
//

import CoreLocation
import UIKit

class ViewController: UIViewController {
    
    lazy var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status != .authorizedAlways {
            let message = "the app needs to access the device location."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        guard let region = region else {
            print("Monitoring failed for unknown region")
            return
        }
        print("Monitoring failed for region with identifier: \(region.identifier)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}
