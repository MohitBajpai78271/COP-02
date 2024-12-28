import UIKit
import CoreMotion
import Alamofire // Or use URLSession

class StepTrackerVC: UIViewController {

    let pedometer = CMPedometer()
    var totalSteps = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        startStepTracking()
    }

    func startStepTracking() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("Step counting not available on this device")
            return
        }

        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let self = self, error == nil, let stepData = data else {
                print("Error tracking steps: \(String(describing: error))")
                return
            }

            // Update total steps
            let steps = stepData.numberOfSteps.intValue
            self.totalSteps = steps
            print("Steps: \(self.totalSteps)")

            // Send steps to the backend
            self.sendStepsToBackend(steps: self.totalSteps)
        }
    }

    func sendStepsToBackend(steps: Int) {
        let url = "\(ApiKeys.baseURL)/"
        let parameters: [String: Any] = [
            "userId": "", // Replace with the actual user ID
            "steps": steps,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Sending data using Alamofire
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: StepResponse.self) { response in
                switch response.result {
                case .success(let stepResponse):
                    print("Successfully sent steps: \(stepResponse.message)")
                case .failure(let error):
                    print("Failed to send steps: \(error.localizedDescription)")
                }
            }
    }

    deinit {
        pedometer.stopUpdates()
    }
}
