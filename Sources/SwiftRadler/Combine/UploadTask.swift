import Foundation
import Combine

enum UploadResponse {
   case progress(percentage: Double)
   case response(data: Data?)
}

class UploadTask: NSObject, URLSessionDelegate {

   let progress: PassthroughSubject<(id: Int, progress: Double), Never> = .init()
   lazy var session: URLSession = {
      .init(configuration: .default, delegate: self, delegateQueue: nil)
   }()
   
   func upload(session: URLSession, request: URLRequest, fileURL: URL) -> AnyPublisher<UploadResponse, Error> {
      let subject: PassthroughSubject<UploadResponse, Error> = .init()
      let task: URLSessionUploadTask = session
         .uploadTask(with: request, fromFile: fileURL) { data, response, error in
         if let error = error {
            subject.send(completion: .failure(error))
            return
         }
         if (response as? HTTPURLResponse)?.statusCode == 200 {
               subject.send(.response(data: data))
            return
         }
         subject.send(.response(data: nil))
      }
      task.resume()
      return progress
               .filter{ $0.id == task.taskIdentifier }
               .setFailureType(to: Error.self)
               .map { .progress(percentage: $0.progress) }
               .merge(with: subject)
               .eraseToAnyPublisher()
   }
   
   func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64,
                   totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
      progress.send((id: task.taskIdentifier, progress: task.progress.fractionCompleted))
   }
}
