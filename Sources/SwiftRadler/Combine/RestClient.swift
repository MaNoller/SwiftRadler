import Foundation
import Combine

public enum RestError: Error {
   case jsonEncodingError
   case jsonDecodingError
   case networkError
   case unauthorized
   case apiError(Int, String)
   case canceled
   case unknown
}

public enum HttpMethod: String {
   case get = "GET"
   case post = "POST"
   case put = "PUT"
   case delete = "DELETE"
}

public struct RestClient {
   public typealias Headers = [String : String]
   
   public var printJsonDecoding = false // for debugging
   
   public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .formatted(.iso8601Full)
   public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(.iso8601Full)
   public var refreshTokenHandler: ()->() = {}
   
   private let session: URLSession
   private let defaultHeader: Headers
   
   public init(urlSession: URLSession) {
      self.session = urlSession
      self.defaultHeader = [:]
   }
   
   public init(urlSession: URLSession, headers: Headers) {
      self.session = urlSession
      self.defaultHeader = headers
   }
   
   // -----------------------------------------------------------------------------------------
   //MARK: - Generic Requests
   
   public func modelForRequest<T>(method: HttpMethod, url: URL, additinalHeaders: Headers = [:]) -> AnyPublisher<T, RestError> where T: Codable {
      let request = createRequest(method: method, url: url, header: allHeaders(additinalHeaders))
      return urlDataTask(request: request, session: session)
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .unknown) }
         .map        { printJsonString(data: $0) }
         .decode(type: T.self, decoder: decoder())
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .jsonDecodingError) }
         .eraseToAnyPublisher()
   }

   //specialization when no data is returned
   public func modelForRequest(method: HttpMethod, url: URL, additinalHeaders: Headers = [:]) -> AnyPublisher<Void, RestError> {
      let request = createRequest(method: method, url: url, header: allHeaders(additinalHeaders))
      return urlDataTask(request: request, session: session)
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .unknown) }
         .eraseToAnyPublisher()
   }
   
   public func modelForRequest<T, P>(data: P, method: HttpMethod, url: URL, additinalHeaders: Headers = [:]) -> AnyPublisher<T, RestError> where T: Codable, P: Codable {
      return Just(data)
         .encode(encoder: encoder())
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .jsonEncodingError) }
         .map        { data -> URLRequest in return createRequest(data: data, method: method, url: url, header: allHeaders(additinalHeaders)) }
         .flatMap    { urlDataTask(request: $0, session: session) }
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .unknown) }
         .map        { printJsonString(data: $0) }
         .decode(type: T.self, decoder: decoder())
         .mapError   { error -> RestError in print(error.localizedDescription); return mapErrorIfNeeded(error, to: .jsonDecodingError) }
         .eraseToAnyPublisher()
   }
   
   public func arrayForRequest<T>(method: HttpMethod, url: URL, additinalHeaders: Headers = [:]) -> AnyPublisher<[T], RestError> where T: Codable {
      let request = createRequest(method: method, url: url, header: allHeaders(additinalHeaders))
      return urlDataTask(request: request, session: session)
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .unknown) }
         .map        { printJsonString(data: $0) }
         .decode(type: [T].self, decoder: decoder())
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .jsonDecodingError) }
         .eraseToAnyPublisher()
   }
   
   public func arrayForRequest<T, P>(data: P, method: HttpMethod, url: URL, additinalHeaders: Headers = [:]) -> AnyPublisher<[T], RestError> where T: Codable, P: Codable {
      return Just(data)
         .encode(encoder: encoder())
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .jsonEncodingError) }
         .map        { data -> URLRequest in return createRequest(data: data, method: method, url: url, header: allHeaders(additinalHeaders)) }
         .flatMap    { urlDataTask(request: $0, session: session) }
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .unknown) }
         .map        { printJsonString(data: $0) }
         .decode(type: [T].self, decoder: decoder())
         .mapError   { error -> RestError in return mapErrorIfNeeded(error, to: .jsonDecodingError) }
         .eraseToAnyPublisher()
   }
   
   // -----------------------------------------------------------------------------------------
   //MARK: - Private Functions

   private func allHeaders(_ headers: Headers) -> Headers {
      var out = defaultHeader
      for (k, v) in headers {
          out[k] = v
      }
      return out
   }
   
   private func decoder() -> JSONDecoder {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = dateDecodingStrategy
      return decoder
   }
   
   private func encoder() -> JSONEncoder {
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = dateEncodingStrategy
      return encoder
   }
   
   private func urlDataTask(request: URLRequest, session: URLSession) -> Publishers.TryMap<URLSession.DataTaskPublisher, Data> {
      return session.dataTaskPublisher(for: request)
         .tryMap { output in
            try urlDataTaskErrors(output: output)
            return output.data
         }
   }
   
   private func urlDataTask(request: URLRequest, session: URLSession) -> Publishers.TryMap<URLSession.DataTaskPublisher, Void> {
      return session.dataTaskPublisher(for: request)
         .tryMap { output in
            try urlDataTaskErrors(output: output)
         }
   }
   
   private func urlDataTaskErrors(output: URLSession.DataTaskPublisher.Output) throws {
      guard let response = output.response as? HTTPURLResponse else {
         throw RestError.networkError
      }
      if response.statusCode == 401 {
         DispatchQueue.main.async {
            refreshTokenHandler()
         }
         throw RestError.unauthorized
      } else if response.statusCode == 499 {
         throw RestError.canceled
      } else if response.statusCode < 200 || response.statusCode >= 300 {
         guard let errMsg = String(data: output.data, encoding: .utf8) else {
            throw RestError.networkError
         }
         throw RestError.apiError(response.statusCode, errMsg)
      }
   }
   
   private func createRequest(method: HttpMethod, url: URL, header: Headers) -> URLRequest {
      return createRequestGeneric(data: nil, method: method, url: url, header: header)
   }
   
   private func createRequest(data: Data, method: HttpMethod, url: URL, header: Headers) -> URLRequest {
      return createRequestGeneric(data: data, method: method, url: url, header: header)
   }
   
   private func createRequestGeneric(data: Data?, method: HttpMethod, url: URL, header: Headers) -> URLRequest {
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = method.rawValue
      for (key, value) in header {
         urlRequest.addValue(value, forHTTPHeaderField: key)
      }
      if let data = data {
         urlRequest.httpBody = data
      }
      return urlRequest
   }
   
   private func mapErrorIfNeeded(_ error: Error, to restError: RestError) -> RestError {
      if let error = error as? RestError {
         return error
      }
      print("### ERROR: \(error)")
      //        restError.localizedDescription = error.localizedDescription
      return restError
   }
   
   private func printJsonString(data: Data) -> Data {
      guard printJsonDecoding else { return data }
      do {
         print("--------------------")
         let json = try JSONSerialization.jsonObject(with: data, options: [])
         print(json)
         print("--------------------")
      } catch {
         let str = String(decoding: data, as: UTF8.self)
         print("Failed to decode string: \(str)")
         print("Error: \(error.localizedDescription)")
         print("--------------------")
      }
      return data
   }
}
