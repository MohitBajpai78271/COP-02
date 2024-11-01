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
    
    func showLoadingView(mapview: MKMapView, timeout: TimeInterval = 15) { // 15 seconds timeout by default
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
    
    func showLoadingView2(tableView: UITableView) { // 15 seconds timeout by default
        containerView = UIView(frame: tableView.bounds)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
    }

    
    func showEmptyStateView(with message: String, in view: UIView){
        print("show is called")
        let emptyStateView = EmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
}

