import Foundation

enum ProxyEnvironmentKey: String {
  case http = "http_proxy"
  case https = "https_proxy"
  case all = "all_proxy"
}

public enum ProxyType: String, Equatable, CaseIterable {
  case http
  case https
  case socks5
}

public struct ProxyInfo {

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

public struct ProxyEnvironment {
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

    func parse(key: ProxyEnvironmentKey) -> ProxyInfo? {
      if let value = _getenv(key.rawValue) {
        return ProxyInfo(value)
      } else if parseUppercaseKey,
                let value = _getenv(key.rawValue.uppercased()) {
        return ProxyInfo(value)
      }
      return nil
    }

    http = parse(key: .http)
    https = parse(key: .https)
    all = parse(key: .all)
  }
}
