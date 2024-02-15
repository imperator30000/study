//
//  Deque.swift
//  HW_1
//
//  Created by Тюленев Вадим on 27.09.2023.
//

import Foundation

struct Deque<Element>: LinkedDequeProtocol{
    
    private var queue = Queue<Element>()
    func clear() {queue.clear() }
    func prepend(_ element: Element){try? insert(element, at: 0)}
    func dropLast() throws -> Element{
        
        let drop = try remove(at: count - 1)
        if last == nil {
            clear()
        }
        return drop
    }
    func makeIterator()-> AnyIterator<Element> {return queue.makeIterator()}
    var count: Int {queue.count}
    func insert(_ element: Element, at index: Int) throws {try queue.insert(element, at: index)}
    func remove(at index: Int) throws -> Element {try queue.remove(at: index)}
    var isEmpty: Bool {queue.isEmpty}
    var first: Element? {queue.first}
    var last: Element? {queue.last}
    func append(_ element: Element) {queue.append(element)}
    func dropFirst() throws -> Element {try queue.dropFirst()}
    
}
