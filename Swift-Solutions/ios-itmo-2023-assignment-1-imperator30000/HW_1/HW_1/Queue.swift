//
//  Queue.swift
//  HW_1
//
//  Created by Тюленев Вадим on 26.09.2023.
//

import Foundation


public enum QueueError: Error {
    case emptyQueue
    case invalidIndex
}

class LinkedListNode<Elelment> {
    var value: Elelment
    weak var next: LinkedListNode?
    var previous: LinkedListNode?
    
    init(_ value: Elelment) {
        self.value = value
    }
}

class Queue<Element>: LinkedQueueProtocol {
    
    var count: Int = 0
    private var head: LinkedListNode<Element>?
    private var tail: LinkedListNode<Element>?
    private func searchBeforeIndex(at index: Int) -> LinkedListNode<Element>?{
        var before = head
        for _ in 0..<index - 1{
            before = before?.next
        }
        return before
    }
    func insert(_ element: Element, at index: Int) throws {
        guard index <= count else {
            throw QueueError.invalidIndex
        }
        
        if isEmpty {
            append(element)
            return
        }
        
        if index == 0 {
            let newNode = LinkedListNode<Element>(element)
            newNode.next = head
            head?.previous = newNode
            head = newNode
        } else {
            let before = (index == count) ? tail : searchBeforeIndex(at: index)
            let newNode = LinkedListNode<Element>(element)
            let after = before?.next
            before?.next = newNode
            newNode.next = after
            newNode.previous = before
            after?.previous = newNode
            if index == count {
                tail = newNode
            }
        }
        
        count += 1
    }

    func remove(at index: Int) throws -> Element {
        guard index < count else {
            throw QueueError.invalidIndex
        }
        
        if index == 0 {
            return try self.dropFirst()
        }
        
        let before = (index == count - 1) ? tail?.previous : searchBeforeIndex(at: index)
        
        guard let cur = before?.next else {
            throw QueueError.invalidIndex
        }
        
        let after = cur.next
        before?.next = after
        after?.previous = before
        cur.next = nil
        cur.previous = nil
        
        if index == count - 1 {
            tail = before
        }
        
        count -= 1
        return cur.value
    }

    func makeIterator() -> AnyIterator<Element> {
        var current = head
        return AnyIterator {
            defer { current = current?.next }
            return current?.value
        }
    }
    var isEmpty: Bool {
        return count == 0
    }
    
    var first: Element? {
        return head?.value
    }
    
    var last: Element? {
        return tail?.value
    }
    
    func append(_ element: Element) {
        let newNode = LinkedListNode(element)
        if isEmpty {
            head = newNode
            tail = newNode
        } else {
            tail?.next = newNode
            newNode.previous = tail
            tail = newNode
        }
        count += 1
    }
    
    func dropFirst() throws -> Element {
        guard let oldHead = head else {
            throw QueueError.invalidIndex
        }
        head = oldHead.next
        
        if head == nil {
            tail = nil
        } else{
            head?.previous = nil
        }
        count -= 1
        return oldHead.value
    }
    
    
    func clear() {
        head = nil
        tail = nil
        count = 0
    }
}
