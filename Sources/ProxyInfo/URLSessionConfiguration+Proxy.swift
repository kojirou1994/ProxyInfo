import Foundation

#if os(macOS)
extension URLSessionConfiguration {

  public func disableProxy() {
    if connectionProxyDictionary == nil {
      connectionProxyDictionary = .init()
    }
    connectionProxyDictionary?[kCFNetworkProxiesHTTPEnable] = false
    connectionProxyDictionary?[kCFNetworkProxiesHTTPSEnable] = false
    connectionProxyDictionary?[kCFNetworkProxiesSOCKSEnable] = false
  }

  public func set(proxyInfo: ProxyInfo, for proxyType: ProxyType? = nil) {
    if connectionProxyDictionary == nil {
      connectionProxyDictionary = .init()
    }
    switch proxyType ?? proxyInfo.type {
    case .http:
      connectionProxyDictionary?[kCFNetworkProxiesHTTPEnable] = true
      connectionProxyDictionary?[kCFNetworkProxiesHTTPProxy] = proxyInfo.host
      connectionProxyDictionary?[kCFNetworkProxiesHTTPPort] = proxyInfo.port
    case .https:
      connectionProxyDictionary?[kCFNetworkProxiesHTTPSEnable] = true
      connectionProxyDictionary?[kCFNetworkProxiesHTTPSProxy] = proxyInfo.host
      connectionProxyDictionary?[kCFNetworkProxiesHTTPSPort] = proxyInfo.port
    case .socks4, .socks4Hostname, .socks5, .socks5Hostname:
      connectionProxyDictionary?[kCFNetworkProxiesSOCKSEnable] = true
      connectionProxyDictionary?[kCFNetworkProxiesSOCKSProxy] = proxyInfo.host
      connectionProxyDictionary?[kCFNetworkProxiesSOCKSPort] = proxyInfo.port
    }
  }

  public func setProxy(environment: [String: String] = ProcessInfo.processInfo.environment, parseUppercaseKey: Bool = false) {
    setProxy(values: .init(environment: environment, parseUppercaseKey: parseUppercaseKey))
  }

  public func setProxy(values: ProxyEnvironment) {
    if let all = values.all {
      switch all.type {
      case .socks5:
        set(proxyInfo: all)
      default:
        set(proxyInfo: all, for: .http)
        set(proxyInfo: all, for: .https)
      }
    } else {
      values.http.map {set(proxyInfo: $0, for: $0.type == .socks5 ? .socks5 : .http)}
      values.https.map {set(proxyInfo: $0, for: $0.type == .socks5 ? .socks5 : .https)}
    }
  }

}
#endif
