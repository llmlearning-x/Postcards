import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int, String?)
    case networkError(Error)
    case unauthorized
}

final class APIClient {
    static let shared = APIClient()
    private let baseURL = URL(string: "https://api.postcards.app")!
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Attach auth token if available
        if let token = KeychainService.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw APIError.unauthorized
                default:
                    let message = String(data: data, encoding: .utf8)
                    throw APIError.serverError(httpResponse.statusCode, message)
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    return APIError.decodingError
                } else {
                    return APIError.networkError(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Upload
    func upload(file: URL, endpoint: Endpoint) -> AnyPublisher<MediaUploadResponse, APIError> {
        // Multipart upload implementation
        // TODO: Implement OSS direct upload or server proxy upload
        Empty().eraseToAnyPublisher()
    }
}

// MARK: - Endpoint
struct Endpoint {
    let path: String
    let method: HTTPMethod
    let body: [String: Any]?
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    static func travels() -> Endpoint {
        Endpoint(path: "/api/v1/travels", method: .get, body: nil)
    }
    
    static func createTravel(title: String, destination: String, startDate: Date) -> Endpoint {
        let body: [String: Any] = [
            "title": title,
            "destination": destination,
            "start_date": ISO8601DateFormatter().string(from: startDate)
        ]
        return Endpoint(path: "/api/v1/travels", method: .post, body: body)
    }
    
    static func postcards(travelID: UUID? = nil) -> Endpoint {
        var path = "/api/v1/postcards"
        if let id = travelID {
            path += "?travel_id=\(id.uuidString)"
        }
        return Endpoint(path: path, method: .get, body: nil)
    }
    
    static func createPostcard(travelID: UUID, location: LocationData, note: String?) -> Endpoint {
        var body: [String: Any] = [
            "travel_id": travelID.uuidString,
            "location": [
                "name": location.name,
                "lat": location.lat,
                "lng": location.lng
            ]
        ]
        if let note = note {
            body["note"] = note
        }
        return Endpoint(path: "/api/v1/postcards", method: .post, body: body)
    }
    
    static func userStats() -> Endpoint {
        Endpoint(path: "/api/v1/users/me/stats", method: .get, body: nil)
    }
}

struct LocationData {
    let name: String
    let lat: Double
    let lng: Double
}

struct MediaUploadResponse: Decodable {
    let id: String
    let originalURL: String
    let thumbnailURL: String?
}
