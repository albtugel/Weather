import Foundation

enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case invalidURL
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .noConnection:            return "Нет подключения к интернету"
        case .timeout:                 return "Время запроса истекло"
        case .clientError(let code):   return "Ошибка клиента: \(code)"
        case .serverError(let code):   return "Ошибка сервера: \(code)"
        case .decodingFailed(let e):   return "Ошибка декодирования: \(e.localizedDescription)"
        case .invalidURL:              return "Некорректный URL"
        case .unknown(let e):          return "Неизвестная ошибка: \(e.localizedDescription)"
        }
    }
}
