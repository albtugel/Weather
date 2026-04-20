import Foundation

final class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }

            switch httpResponse.statusCode {
            case 200..<300:
                break
            case 400..<500:
                throw NetworkError.clientError(statusCode: httpResponse.statusCode)
            case 500..<600:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw NetworkError.unknown(URLError(.badServerResponse))
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as URLError {
            throw map(error)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    private func map(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet:
            return .noConnection
        case .timedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }
}
