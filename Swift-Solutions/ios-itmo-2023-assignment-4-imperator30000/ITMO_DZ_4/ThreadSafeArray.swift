import Foundation

class ThreadSafeArray<T>  {
    private var array: [T] = []
    private let lock = RWLock()
    required init(_ elements: [T] = []) {
        array = elements
    }
}

extension ThreadSafeArray: RandomAccessCollection {
    typealias Index = Int
    typealias Element = T

    var startIndex: Index { return array.startIndex }
    var endIndex: Index { return array.endIndex }

    subscript(index: Index) -> Element {
        get { lock.read {array[index]} }
        set { lock.write {array[index] = newValue } }
        
    }

    func index(after i: Index) -> Index {
        return  lock.read { array.index(after: i) }
    }
}

extension ThreadSafeArray {
    func append(_ newElement: Element) {
        lock.write { array.append(newElement) }
    }
    func sort(by areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
       lock.write {
           array.sort(by: areInIncreasingOrder)
       }
    }
    func reverse() {
        lock.write {
            array.reverse()
        }
    }
}
