import XCTest
@testable import HW_1

final class DequeTests: QueueTests {
    var deque: (any LinkedDequeProtocol<Int>)!
    
    override func setUp() {
        super.setUp()
       deque = Deque<Int>() //  -- Здесь необходимо поставить свою реализацию Deque 
        queue = deque
    }
    
    func testPrepend() {
        deque.prepend(0)
        XCTAssertEqual(deque.count, 1)
        XCTAssertEqual(deque.first, 0)
    }
    
    func testDropFirstAfterPrepend() {
        deque.prepend(0)
        XCTAssertEqual(try deque.dropLast(), 0)
        XCTAssertTrue(deque.isEmpty)
    }
    
    func testSomePrepend() {
        deque.prepend(0)
        deque.prepend(1)
        deque.prepend(2)
        deque.prepend(3)
        XCTAssertEqual(deque.count, 4)
    }
    
    func testSomeDropFirstAfterPrepend() {
        deque.prepend(0)
        deque.prepend(1)
        deque.prepend(2)
        deque.prepend(3)
        XCTAssertEqual(deque.count, 4)
        XCTAssertEqual(try deque.dropLast(), 0)
        XCTAssertEqual(try deque.dropLast(), 1)
        XCTAssertEqual(try deque.dropLast(), 2)
        XCTAssertEqual(try deque.dropLast(), 3)
        XCTAssertEqual(deque.count, 0)
    }
    
    func testPrependCount10() {
        let count = 10
        for _ in 0..<count {
            deque.prepend(Int.random(in: Int.min...Int.max))
        }
        XCTAssertEqual(deque.count, count)
    }
    
    func testPrependCount100() {
        let count = 100
        for _ in 0..<count {
            deque.prepend(Int.random(in: Int.min...Int.max))
        }
        XCTAssertEqual(deque.count, count)
    }
    
    func testPrependCount1000000() {
        let count = 1000000
        for _ in 0..<count {
            deque.prepend(Int.random(in: Int.min...Int.max))
        }
        XCTAssertEqual(deque.count, count)
    }
    
    func testFirstAfterPrepend() {
        for _ in 0...100 {
            let e = Int.random(in: 0...100)
            deque.prepend(e)
            XCTAssertEqual(deque.first, e)
        }
    }
    
    func testSomeDropLastFromDequeWithOneElement() {
        for _ in 0...100 {
            let e = Int.random(in: 0...100)
            deque.prepend(e)
            XCTAssertEqual(try deque.dropLast(), e)
        }
    }
    
    func testLastsAfterPrepend() {
        deque.prepend(-1)
        for _ in 0...100 {
            let e = Int.random(in: 0...100)
            deque.prepend(e)
            XCTAssertEqual(deque.last, -1)
        }
    }
    
    func testClearAfterPrepend() {
        let count = 100
        for i in 0..<count {
            deque.prepend(i)
        }
        XCTAssertEqual(deque.count, count)
        deque.clear()
        XCTAssertEqual(deque.count, 0)
    }
}
