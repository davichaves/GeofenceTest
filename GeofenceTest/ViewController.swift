//
//  ViewController.swift
//  GeofenceTest
//
//  Created by Davi Chaves on 1/26/22.
//

import CoreLocation
import UIKit
import CoreData

class ViewController: UIViewController {
    
    lazy var locationManager = CLLocationManager()
    var geofences: [NSManagedObject] = []
    var geofenceDatabase = GeofenceDatabase()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Geofence")

        do {
            geofences = try managedContext.fetch(fetchRequest)
            if geofences.isEmpty {
                for geofence in geofenceDatabase.geofenceStarters {
                    saveGeofence(id: geofence.id, radius: geofence.radius, latitude: geofence.latitude, longitude: geofence.longitude)
                }
            } else {
                for geofence in geofences {
                    startMonitoring(geofence: geofence as! Geofence)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveGeofence(id: String, radius: Double, latitude: Double, longitude: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Geofence", in: managedContext)!
        let geofence = NSManagedObject(entity: entity, insertInto: managedContext)
        geofence.setValue(id, forKeyPath: "id")
        geofence.setValue(radius, forKeyPath: "radius")
        geofence.setValue(latitude, forKeyPath: "latitude")
        geofence.setValue(longitude, forKeyPath: "longitude")

        do {
            try managedContext.save()
            geofences.append(geofence)
        } catch let error as NSError {
            print("Could not save geofence \(error), \(error.userInfo)")
        }
    }
    
    // MARK: monitoring functions
    func startMonitoring(geofence: Geofence) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let message = "Geofencing is not supported on this device!"
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: geofence.latitude, longitude: geofence.longitude)
        let region = CLCircularRegion(center: coordinate, radius: geofence.radius, identifier: geofence.id ?? "")
        locationManager.startMonitoring(for: region)
    }

    func stopMonitoring(geofence: Geofence) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geofence.id else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
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
