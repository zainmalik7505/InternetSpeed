//
//  ViewController.swift
//  InternetSpeed
//
//  Created by Nayatel Creatives on 29/01/2025.
//

import UIKit
import CoreLocation
import SpeedcheckerSDK
import MBCircularProgressBar

class ViewController: UIViewController {

    private var internetTest: InternetSpeedTest?
    private var locationManager = CLLocationManager()
    

    @IBOutlet var lblDownloadSpeed: UILabel!
    @IBOutlet var lblLatency: UILabel!
    
    @IBOutlet var lblUploading: UILabel!
    
    @IBOutlet var progressBarView: MBCircularProgressBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        requestLocationAuthorization()
        
        progressBarView.maxValue = 100
        progressBarView.value = 0
        progressBarView.progressAngle = 100
        progressBarView.progressCapType = 2  // Round cap
        progressBarView.emptyLineWidth = 5
        progressBarView.progressLineWidth = 8
        progressBarView.emptyLineStrokeColor = UIColor.lightGray
        progressBarView.progressColor = UIColor.systemBlue

    }

    @IBAction func runSpeedTestTouched(_ sender: UIButton) {
        sender.isEnabled = false

        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            startSpeedTest()
            sender.isEnabled = true
        } else {
            print("Location access required for free version of SpeedChecker")
            sender.isEnabled = true
        }
    }

    func startSpeedTest() {
        DispatchQueue.main.async {
            self.progressBarView.value = 0
            self.lblDownloadSpeed.text = "0.00 Mbps"
            self.lblUploading.text = "0.00 Mbps"
        }
        
        internetTest = InternetSpeedTest(delegate: self)
        internetTest?.startFreeTest() { (error) in
            if error != .ok {
                print("Error starting test: \(error.rawValue)")
            } else {
                print("Test started successfully")
            }
        }
    }

//    func requestLocationAuthorization() {
//        DispatchQueue.global().async {
//            guard CLLocationManager.locationServicesEnabled() else {
//                return
//            }
//            DispatchQueue.main.async { [weak self] in
//                self?.locationManager.delegate = self
//                if CLLocationManager.authorizationStatus() == .notDetermined {
//                    self?.locationManager.requestWhenInUseAuthorization()
//                    self?.locationManager.requestAlwaysAuthorization()
//                } else if CLLocationManager.authorizationStatus() == .denied {
//                    print("Location access denied")
//                } else {
//                    self?.startSpeedTest()  // Call this method to start the speed test
//                }
//            }
//        }
//    }
    func requestLocationAuthorization() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location access denied")
        case .authorizedWhenInUse, .authorizedAlways:
            print("Access Granted")
        @unknown default:
            print("Unknown authorization status")
        }
    }

}

extension ViewController: InternetSpeedTestDelegate {
    func internetTestError(error: SpeedTestError) {
        print("Error: \(error.rawValue)")
    }

    func internetTestFinish(result: SpeedTestResult) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.progressBarView.value = 100
            }
            self.lblDownloadSpeed.text = "\(result.downloadSpeed.mbps) Mbps"
            self.lblLatency.text = "\(result.latencyInMs) ms"
            self.lblUploading.text = "\(result.uploadSpeed.mbps) Mbps"
        }

    }
    

    func internetTestReceived(servers: [SpeedTestServer]) {

    }

    func internetTestSelected(server: SpeedTestServer, latency: Int, jitter: Int) {
        print("Latency: \(latency)")
        print("Jitter: \(jitter)")
    }

    func internetTestDownloadStart() {
        
    }

    func internetTestDownloadFinish() {
        
    }

    // Continuously
    func internetTestDownload(progress: Double, speed: SpeedTestSpeed) {
        print("Download: \(speed.descriptionInMbps)")
        
        let progressValue = progress * 100
        let speedMbps = speed.mbps

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.progressBarView.value = CGFloat(speedMbps)
                self.lblDownloadSpeed.text = String(format: "%.2f Mbps", speedMbps)
                self.progressBarView.unitString = "Mbps"

            }
        }
        
    }

    func internetTestUploadStart() {
        
        
    }

    func internetTestUploadFinish() {
    }

    func internetTestUpload(progress: Double, speed: SpeedTestSpeed) {
        print("Upload: \(speed.descriptionInMbps)")
        
        let progressValue = progress * 100
        let speedMbps = speed.mbps

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.progressBarView.value = CGFloat(speedMbps)
                self.lblUploading.text = String(format: "%.2f Mbps", speedMbps)
                self.progressBarView.unitString = "Mbps"

            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
}



