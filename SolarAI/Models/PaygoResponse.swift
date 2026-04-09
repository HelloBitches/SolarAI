import Foundation

/// POST /password.do 的请求主体
struct PaygoPasswordRequest: Codable {
    let pwd: String?
    let code: String?

    /// - useCompatibility: `false`（默认）→ 下发 `code`；`true`（勾选）→ 下发 `pwd`
    init(value: String, useCompatibility: Bool) {
        if useCompatibility {
            self.pwd = value
            self.code = nil
        } else {
            self.pwd = nil
            self.code = value
        }
    }
}

/// POST /password.do 的响应模型
///
/// status 含义：0=成功 1=失败 2=锁定中
/// 当 status=2 时，remain_lock_time 表示剩余锁定秒数，UI 显示 "Blocked. Wait Xs"
///
/// 注意：协议文档中字段名为 "remain_lock time"（含空格），
/// 需连接真机验证实际 API 返回的字段名是空格还是下划线
struct PaygoPasswordResponse: Codable {
    let status: Int
    let remainLockTime: Int

    enum CodingKeys: String, CodingKey {
        case status
        case remainLockTime = "remain_lock_time"
    }

    /// 0 = 成功, 1 = 失败, 2 = 锁定中
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

/// GET /showInfo.do 的响应
struct PaygoInfoResponse: Codable {
    let status: Int
    let info: String
}
