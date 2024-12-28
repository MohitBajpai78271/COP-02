import UIKit
import MapKit

fileprivate var containerView: UIView!

extension UIViewController {
    private struct AssociatedKeys {
        static var loadingWorkItem: UInt8 = 0
    }
    
    private var loadingWorkItem: DispatchWorkItem? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadingWorkItem) as? DispatchWorkItem
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.loadingWorkItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private struct LoadingViewConstants {
         static var containerView: UIView?
        static var loadingTimeoutWorkItem: DispatchWorkItem?
     }
    
    func showLoadingView(mapview: MKMapView, timeout: TimeInterval = 10) { // 15 seconds timeout by default
        containerView = UIView(frame: mapview.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            containerView.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.dismissLoadingView()
        }
        
        loadingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: workItem)
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.loadingWorkItem?.cancel()
            self.loadingWorkItem = nil
            containerView?.removeFromSuperview()
            containerView = nil
        }
    }
    
    func showLoadingView2(tableView: UITableView) {
          // Ensure no duplicate loading views
          guard LoadingViewConstants.containerView == nil else { return }
          
          // Create and configure the container view
          let containerView = UIView(frame: tableView.bounds)
          containerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
          view.addSubview(containerView)
          LoadingViewConstants.containerView = containerView

          // Add and configure the activity indicator
          let activityIndicator = UIActivityIndicatorView(style: .large)
          activityIndicator.translatesAutoresizingMaskIntoConstraints = false
          containerView.addSubview(activityIndicator)
          
          NSLayoutConstraint.activate([
              activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
              activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
          ])
          
          activityIndicator.startAnimating()
          
          // Schedule a 3-second timeout to dismiss the loading view automatically
          let timeoutWorkItem = DispatchWorkItem { [weak self] in
              self?.dismissLoadingView2()
          }
          
          LoadingViewConstants.loadingTimeoutWorkItem = timeoutWorkItem
          DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: timeoutWorkItem)
      }
     
    func dismissLoadingView2() {
        // Cancel the timeout work item if it’s still pending
        LoadingViewConstants.loadingTimeoutWorkItem?.cancel()
        LoadingViewConstants.loadingTimeoutWorkItem = nil
        
        // Remove the loading view
        LoadingViewConstants.containerView?.removeFromSuperview()
        LoadingViewConstants.containerView = nil
    }
    
    
    func showToast(message: String, duration: TimeInterval) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toastLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }

    
    func showEmptyStateView(with message: String, in view: UIView){
        print("show is called")
        let emptyStateView = EmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
}

