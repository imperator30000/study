import XCTest
@testable import HW_1
class QueueTests: XCTestCase {
    var queue: (any LinkedQueueProtocol<Int>)!
    
    override func setUp() {
        super.setUp()
       queue = Queue<Int>() //  -- Здесь необходимо поставить свою реализацию Queue
    }

    func testCreateEmpty() {
        XCTAssertTrue(queue.isEmpty)
    }
    
    func testCreateEmptyBasedOnCount() {
        XCTAssertTrue(queue.isEmpty)
        XCTAssertTrue(queue.count == 0)
        queue.append(0)
        XCTAssertFalse(queue.isEmpty)
        XCTAssertFalse(queue.count == 0)
    }
    
    func testAppend() {
        queue.append(0)
        XCTAssertEqual(queue.count, 1)
        XCTAssertEqual(queue.first, 0)
    }
    
    func testDropFirst() {
        queue.append(0)
        XCTAssertEqual(try queue.dropFirst(), 0)
        XCTAssertTrue(queue.isEmpty)
    }
    
    func testSomeAppend() {
        queue.append(0)
        queue.append(1)
        queue.append(2)
        queue.append(3)
        XCTAssertEqual(queue.count, 4)
    }
    
    func testSomeDropFirst() {
        queue.append(0)
        queue.append(1)
        queue.append(2)
        queue.append(3)
        XCTAssertEqual(queue.count, 4)
        XCTAssertEqual(try queue.dropFirst(), 0)
        XCTAssertEqual(try queue.dropFirst(), 1)
        XCTAssertEqual(try queue.dropFirst(), 2)
        XCTAssertEqual(try queue.dropFirst(), 3)
        XCTAssertEqual(queue.count, 0)
    }
    
    func testCount10() {
        let count = 10
        for _ in 0..<count {
            queue.append(Int.random(in: Int.min...Int.max))
        }
        XCTAssertEqual(queue.count, count)
    }
    
    func testCount100() {
        let count = 100
        for _ in 0..<count {
            queue.append(Int.random(in: Int.min...Int.max))
        }
        XCTAssertEqual(queue.count, count)
    }
    
    func testCount1000000() {
        let count = 1000000
        for _ in 0..<count {
            queue.append(Int.random(in: Int.min...Int.max))
        }
        XCTAssertEqual(queue.count, count)
    }
    
    func testFirst() {
        queue.append(-1)
        for _ in 0...100 {
            let e = Int.random(in: 0...100)
            queue.append(e)
            XCTAssertEqual(queue.first, -1)
        }
    }
    
    func testSomeDropFirstFromQueueWithOneElement() {
        for _ in 0...100 {
            let e = Int.random(in: 0...100)
            queue.append(e)
            XCTAssertEqual(try queue.dropFirst(), e)
        }
    }
    
    func testLasts() {
        for _ in 0...100 {
            let e = Int.random(in: 0...100)
            queue.append(e)
            XCTAssertEqual(queue.last, e)
        }
    }
    
    func testClear() {
        let count = 100
        for i in 0..<count {
            queue.append(i)
        }
        XCTAssertEqual(queue.count, count)
        queue.clear()
        XCTAssertEqual(queue.count, 0)
    }
    
    func testClearOnEmpty() {
        queue.clear()
        XCTAssertEqual(queue.count, 0)
    }
    
    func testInsert() {
        XCTAssertNoThrow(try queue.insert(0, at: 0))
        XCTAssertNoThrow(try queue.insert(2, at: 1))
        XCTAssertNoThrow(try queue.insert(1, at: 1))
        
        XCTAssertEqual(queue.count, 3)
        
        XCTAssertEqual(try queue.dropFirst(), 0)
        XCTAssertEqual(try queue.dropFirst(), 1)
        XCTAssertEqual(try queue.dropFirst(), 2)
    }
    
    func testRemove() {
        for e in 0..<10 {
            queue.append(e)
        }
        XCTAssertNoThrow(try queue.remove(at: 9))
        XCTAssertNoThrow(try queue.remove(at: 7))
        XCTAssertNoThrow(try queue.remove(at: 5))
        XCTAssertNoThrow(try queue.remove(at: 3))
        XCTAssertNoThrow(try queue.remove(at: 1))
        
        XCTAssertEqual(queue.count, 5)
        
        XCTAssertEqual(try queue.dropFirst(), 0)
        XCTAssertEqual(try queue.dropFirst(), 2)
        XCTAssertEqual(try queue.dropFirst(), 4)
        XCTAssertEqual(try queue.dropFirst(), 6)
        XCTAssertEqual(try queue.dropFirst(), 8)
    }
    
    func testAllCollection() {
        var example: [Int] = []
        for i in 0...10 {
            example.append(i)
            queue.append(i)
        }
        
        for e in queue {
            let ex = example.removeFirst()
            XCTAssertEqual(ex, e)
        }
    }
    
    func testRemoveFromMiddleOfCollection() {
        var example: [Int] = []
        for i in 0...10 {
            example.append(i)
            queue.append(i)
        }
        
        for _ in 0...3 {
            example.remove(at: 5)
            try! queue.remove(at: 5)
        }
        
        for e in queue {
            let ex = example.removeFirst()
            XCTAssertEqual(ex, e)
        }
    }
    
    func testInsertAtMiddleOfCollection() {
        var example: [Int] = []
        for i in 0...10 {
            example.append(i)
            queue.append(i)
        }
        
        for i in 1...3 {
            example.insert(-i, at: 5)
            try! queue.insert(-i, at: 5)
        }
        
        for e in queue {
            let ex = example.removeFirst()
            XCTAssertEqual(ex, e)
        }
    }

    func testIterateThroughEmpty() {
        for _ in queue {
            XCTFail("Go inside empty loop")
        }
    }
}



