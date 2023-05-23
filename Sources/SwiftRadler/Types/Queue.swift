import Foundation

public struct Queue<T> {
   private var list = [T]()
   
   public init() {}
   
   private var last: T? {
      return list.last
   }
   
   public subscript(index: Int) -> T {
      return list[index]
   }
   
   public mutating func push(_ element: T) {
      list.append(element)
   }
   
   public mutating func push(contentsOf elements: [T]) {
      list.append(contentsOf: elements)
   }
   
   public mutating func pop() -> T? {
      return !list.isEmpty
         ? list.removeFirst()
         : nil
   }
   
   public mutating func removeAll() {
      list.removeAll()
   }
}
