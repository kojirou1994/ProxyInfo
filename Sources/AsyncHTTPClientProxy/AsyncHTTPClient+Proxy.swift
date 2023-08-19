import AsyncHTTPClient
import ProxyInfo

extension ProxyInfo {
  var toProxy: HTTPClient.Configuration.Proxy {
    switch type {
    case .socks4, .socks4Hostname, .socks5, .socks5Hostname:
      return .socksServer(host: host, port: port)
    case .http, .https:
      return .server(host: host, port: port)
    }
  }
}

extension HTTPClient.Configuration.Proxy {
  public static func environment(_ values: ProxyEnvironment) -> Self? {
    if let all = values.all {
      return all.toProxy
    } else if let http = values.http {
      return http.toProxy
    } else if let https = values.https {
      return https.toProxy
    }
    return nil
  }
}
