import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(Int)
    case requestFailed(Error)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingFailed(let error): return "Decoding failed: \(error.localizedDescription)"
        case .serverError(let code): return "Server error: \(code)"
        case .requestFailed(let error): return "Request failed: \(error.localizedDescription)"
        case .timeout: return "Request timed out"
        }
    }
}

/// Handles all HTTP communication with the inverter device at 192.168.4.1:8080
final class NetworkService {

    static let shared = NetworkService()

    private let session: URLSession
    private let baseURL: String

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 15
        config.waitsForConnectivity = false
        self.session = URLSession(configuration: config)
        self.baseURL = AppConfig.baseURL
    }

    // MARK: - Generic Request

    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                let nsError = error as NSError
                if nsError.code == NSURLErrorTimedOut {
                    DispatchQueue.main.async { completion(.failure(.timeout)) }
                } else {
                    DispatchQueue.main.async { completion(.failure(.requestFailed(error))) }
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.failure(.serverError(httpResponse.statusCode))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingFailed(error))) }
            }
        }
        task.resume()
    }

    // MARK: - API Methods

    func fetchGeneral(completion: @escaping (Result<GeneralResponse, NetworkError>) -> Void) {
        request(endpoint: APIEndpoint.general, completion: completion)
    }

    func fetchDeviceStatus(completion: @escaping (Result<DeviceStatusResponse, NetworkError>) -> Void) {
        request(endpoint: APIEndpoint.deviceStatus, completion: completion)
    }

    func fetchFaultyAlert(completion: @escaping (Result<FaultyAlertResponse, NetworkError>) -> Void) {
        request(endpoint: APIEndpoint.faultyAlert, completion: completion)
    }

    func submitPaygoPassword(
        code: String,
        useCompatibility: Bool,
        completion: @escaping (Result<PaygoPasswordResponse, NetworkError>) -> Void
    ) {
        let requestBody = PaygoPasswordRequest(value: code, useCompatibility: useCompatibility)
        guard let bodyData = try? JSONEncoder().encode(requestBody) else {
            completion(.failure(.invalidURL))
            return
        }
        request(endpoint: APIEndpoint.password, method: "POST", body: bodyData, completion: completion)
    }

    func fetchPaygoInfo(completion: @escaping (Result<PaygoInfoResponse, NetworkError>) -> Void) {
        request(endpoint: APIEndpoint.showInfo, completion: completion)
    }
}
