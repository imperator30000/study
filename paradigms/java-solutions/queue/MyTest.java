package queue;

import java.util.Random;

public class MyTest {
    private static final ArrayQueueADT arrayQueueADT = new ArrayQueueADT();
    private static final LinkedQueue arrayQueue = new LinkedQueue();

    public static void main(String[] args) {
        System.out.println("enqueueSizeTest");
        enqueueSizeTest();
        System.out.println("dequeueSizeElementTest");
        dequeueSizeElementTest();
        System.out.println("dequeueEnqueueSizeElementRandomTest");
        dequeueEnqueueSizeElementRandomTest();
        System.out.println("clearIsEmptyTest");
        clearIsEmptyTest();

    }

    public static void enqueueSizeTest() {
        for (int i = 0; i < 100; i++) {
            ArrayQueueModule.enqueue(i);
            ArrayQueueADT.enqueue(arrayQueueADT, i);
            arrayQueue.enqueue(i);
            if (ArrayQueueModule.size() != i + 1) {
                System.out.println("ArrayQueueModule : size():  expected " + i + 1 + " actual" + ArrayQueueModule.size());
            }
            if (ArrayQueueADT.size(arrayQueueADT) != i + 1) {
                System.out.println("ArrayQueueADT : size():  expected " + i + 1 + " actual" + ArrayQueueADT.size(arrayQueueADT));
            }
            if (arrayQueue.size() != i + 1) {
                System.out.println("ArrayQueue : size():  expected " + i + 1 + " actual" + arrayQueue.size());
            }
        }
    }

    public static void dequeueSizeElementTest() {
        for (int i = 99; i >= 0; i--) {
            Object ob1_ = ArrayQueueModule.element();
            Object ob1 = ArrayQueueModule.dequeue();
            Object ob2_ = ArrayQueueADT.element(arrayQueueADT);
            Object ob2 = ArrayQueueADT.dequeue(arrayQueueADT);
            Object ob3_ = arrayQueue.element();
            Object ob3 = arrayQueue.dequeue();
            if (ob1 != ob1_) {
                System.out.println("ArrayQueueModule : element() = " + ob1_ + " dequeue() = " + ob1);
            }
            if (ob2 != ob2_) {
                System.out.println("ArrayQueueADT : element() = " + ob2_ + " dequeue() = " + ob2);
            }
            if (ob3 != ob3_) {
                System.out.println("ArrayQueue : element() = " + ob3_ + " dequeue() = " + ob3);
            }

            if (ArrayQueueModule.size() != i) {
                System.out.println("ArrayQueueModule : size():  expected " + i + " actual" + ArrayQueueModule.size());
            }
            if (ArrayQueueADT.size(arrayQueueADT) != i) {
                System.out.println("ArrayQueueADT : size():  expected " + i + " actual" + ArrayQueueADT.size(arrayQueueADT));
            }
            if (arrayQueue.size() != i) {
                System.out.println("ArrayQueue : size():  expected " + i + " actual" + arrayQueue.size());
            }

        }
    }

    public static void dequeueEnqueueSizeElementRandomTest() {
        Random random = new Random();
        boolean nextAction = true;
        int size = 0;
        for (int i = 0; i < 2048; i++) {
            if (i % 16 == 0 || i % 7 == 0) {
                nextAction = random.nextBoolean();
            }
//            System.out.println(size);
            if (nextAction || size == 0) {
                ArrayQueueModule.enqueue(i);
                ArrayQueueADT.enqueue(arrayQueueADT, i);
                arrayQueue.enqueue(i);
                size++;
            } else {
                Object ob1_ = ArrayQueueModule.element();
                Object ob1 = ArrayQueueModule.dequeue();
                Object ob2_ = ArrayQueueADT.element(arrayQueueADT);
                Object ob2 = ArrayQueueADT.dequeue(arrayQueueADT);
                Object ob3_ = arrayQueue.element();
                Object ob3 = arrayQueue.dequeue();
                if (ob1 != ob1_) {
                    System.out.println("ArrayQueueModule : element() = " + ob1_ + " dequeue() = " + ob1);
                }
                if (ob2 != ob2_) {
                    System.out.println("ArrayQueueADT : element() = " + ob2_ + " dequeue() = " + ob2);
                }
                if (ob3 != ob3_) {
                    System.out.println("ArrayQueue : element() = " + ob3_ + " dequeue() = " + ob3);
                }
                size--;
            }
            if (ArrayQueueModule.size() != size) {
                System.out.println("ArrayQueueModule : size():  expected " + size + " actual" + ArrayQueueModule.size());
            }
            if (ArrayQueueADT.size(arrayQueueADT) != size) {
                System.out.println("ArrayQueueADT : size():  expected " + size + " actual" + ArrayQueueADT.size(arrayQueueADT));
            }
            if (arrayQueue.size() != size) {
                System.out.println("ArrayQueue : size():  expected " + size + " actual" + arrayQueue.size());
            }
        }
    }

    public static void clearIsEmptyTest() {
        for (int i = 0; i < 10; i++) {
            ArrayQueueModule.enqueue(i);
            ArrayQueueADT.enqueue(arrayQueueADT, i);
            arrayQueue.enqueue(i);
        }
        ArrayQueueModule.clear();
        ArrayQueueADT.clear(arrayQueueADT);
        arrayQueue.clear();
        if (!ArrayQueueModule.isEmpty()) {
            System.out.println("ArrayQueueModule : isEmpty() : size == " + ArrayQueueModule.size());
        }
        if (!ArrayQueueADT.isEmpty(arrayQueueADT)) {
            System.out.println("ArrayQueueADT : isEmpty() : size == " + ArrayQueueADT.size(arrayQueueADT));
        }
        if (!arrayQueue.isEmpty()) {
            System.out.println("ArrayQueue : isEmpty() : size == " + arrayQueue.size());
        }
    }
}
