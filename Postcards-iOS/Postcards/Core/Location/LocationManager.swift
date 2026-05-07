import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var placemark: CLPlacemark?
    @Published var error: Error?
    
    private let locationManager = CLLocationManager()
    var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestSingleLocation() -> AnyPublisher<CLLocation, Error> {
        Deferred { [weak self] in
            Future { promise in
                guard let self = self else {
                    promise(.failure(LocationError.managerDeallocated))
                    return
                }
                self.locationManager.requestLocation()
                self.$currentLocation
                    .compactMap { $0 }
                    .first()
                    .sink(receiveCompletion: { _ in }, receiveValue: { location in
                        promise(.success(location))
                    })
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func reverseGeocode(_ location: CLLocation) -> AnyPublisher<CLPlacemark, Error> {
        Future { promise in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    promise(.failure(error))
                } else if let placemark = placemarks?.first {
                    promise(.success(placemark))
                } else {
                    promise(.failure(LocationError.noPlacemark))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    enum LocationError: Error {
        case managerDeallocated
        case noPlacemark
        case denied
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            self.error = LocationError.denied
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
