import Foundation

public protocol LinkedDequeProtocol<Element>: LinkedQueueProtocol {
    // O(1)
    mutating func prepend(_ element: Element)

    @discardableResult
    mutating func dropLast() throws -> Element
}
