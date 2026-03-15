import Foundation

/// Request body for POST /password.do
struct PaygoPasswordRequest: Codable {
    let pwd: String?
    let code: String?

    init(value: String, useCompatibility: Bool) {
        if useCompatibility {
            self.pwd = nil
            self.code = value
        } else {
            self.pwd = value
            self.code = nil
        }
    }
}

/// Response from POST /password.do
struct PaygoPasswordResponse: Codable {
    let status: Int
    let remainLockTime: Int

    enum CodingKeys: String, CodingKey {
        case status
        case remainLockTime = "remain_lock_time"
    }

    /// 0 = OK, 1 = fail, 2 = blocking
    var resultType: PaygoResult {
        switch status {
        case 0: return .success
        case 1: return .wrongCode
        case 2: return .blocked(remainingSeconds: remainLockTime)
        default: return .wrongCode
        }
    }
}

enum PaygoResult {
    case success
    case wrongCode
    case blocked(remainingSeconds: Int)
}

/// Response from GET /showInfo.do
struct PaygoInfoResponse: Codable {
    let status: Int
    let info: String
}
