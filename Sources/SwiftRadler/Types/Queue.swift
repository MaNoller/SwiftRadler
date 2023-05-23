import Foundation

struct Queue<T> {
   var list = [T]()
   
   var last: T? {
      return list.last
   }
   
   subscript(index: Int) -> T {
      return list[index]
   }
   
   mutating func push(_ element: T) {
      list.append(element)
   }
   
   mutating func push(contentsOf elements: [T]) {
      list.append(contentsOf: elements)
   }
   
   mutating func pop() -> T? {
      return !list.isEmpty
         ? list.removeFirst()
         : nil
   }
   
   mutating func removeAll() {
      list.removeAll()
   }
}
