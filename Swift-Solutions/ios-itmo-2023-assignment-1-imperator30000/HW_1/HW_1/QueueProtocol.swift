import Foundation

public protocol LinkedQueueProtocol<Element>: Sequence {
    // O(1)
    mutating func append(_ element: Element)

    @discardableResult
    mutating func dropFirst() throws -> Element

    var count: Int { get }
    
    var isEmpty: Bool { get }
    
    mutating func clear()

    var first: Element? { get }
    
    var last: Element? { get }
    
    // O(n)
    mutating func insert(_ element: Element, at index: Int) throws

    @discardableResult
    mutating func remove(at index: Int) throws -> Element
}
