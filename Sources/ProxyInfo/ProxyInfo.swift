import Foundation

public enum ProxyType: String, Equatable, CaseIterable, Sendable {
  case http
  case https
  case socks4
  case socks4Hostname = "socks4a"
  case socks5
  case socks5Hostname = "socks5h"
}

public struct ProxyInfo: Sendable {

  public let type: ProxyType
  public let host: String
  public let port: Int

  public init(type: ProxyType, host: String, port: Int) {
    self.type = type
    self.host = host
    self.port = port
  }

  public init?(_ str: String) {
    guard let url = URLComponents(string: str),
          let host = url.host,
          let port = url.port,
          let scheme = url.scheme,
          let type = ProxyType(rawValue: scheme.lowercased())
    else {
      return nil
    }

    self.type = type
    self.host = host
    self.port = port
  }
}

public struct ProxyEnvironment: Sendable {
  public let http: ProxyInfo?
  public let https: ProxyInfo?
  public let all: ProxyInfo?

  public init(environment: [String: String]? = ProcessInfo.processInfo.environment,
              parseUppercaseKey: Bool) {

    func _getenv(_ key: String) -> String? {
      if let environment = environment {
        return environment[key]
      }
      if let cstr = getenv(key) {
        return .init(cString: cstr)
      }
      return nil
    }

    func parse(key: String, uppercased: String) -> ProxyInfo? {
      if let value = _getenv(key) {
        return ProxyInfo(value)
      } else if parseUppercaseKey,
                let value = _getenv(uppercased) {
        return ProxyInfo(value)
      }
      return nil
    }

    http = parse(key: "http_proxy", uppercased: "HTTP_PROXY")
    https = parse(key: "https_proxy", uppercased: "HTTPS_PROXY")
    all = parse(key: "all_proxy", uppercased: "ALL_PROXY")
  }

  /// there is no any proxy info
  public var isEmpty: Bool {
    http == nil && https == nil && all == nil
  }
}
