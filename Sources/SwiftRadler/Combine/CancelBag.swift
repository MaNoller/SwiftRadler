import Combine

public class CancelBag {
    var subscriptions = Set<AnyCancellable>()
   
   public init() {}
   
    public func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
}

extension AnyCancellable {
    
    public func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
