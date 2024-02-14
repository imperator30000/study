package queue;

import java.util.Arrays;

import static java.lang.Math.abs;

// Invariant: n - index of the last element in the queue , n + 1 - queue length
// Model: a[0] ... a[n]
// Invariant: for i in 0...n: a[i] != null
public class ArrayQueueADT {
    private int start = 0;
    private int finish = -1;
    private final int sizeCQ = 2;
    private Object[] elements = new Object[sizeCQ];

    public static void main(String[] args) {
//        enqueue(7);
//        System.out.println(Arrays.toString(elements));
//        enqueue(9);
//        System.out.println(Arrays.toString(elements));
//        enqueue(6);
//        System.out.println(Arrays.toString(elements));
//        enqueue(8);
//        System.out.println(Arrays.toString(elements));
//        dequeue();
//        System.out.println(Arrays.toString(elements));
//        dequeue();
//        System.out.println(Arrays.toString(elements));
//        dequeue();
//        System.out.println(Arrays.toString(elements));



    }
    // Pred: ArrayQueueADT == class(queue) && el != null
    // Post: n` = n + 1 && for i in 1..n`: a`[i] = a[i] && a`[n`] = el

    public static void enqueue(ArrayQueueADT queue , Object el) {
        assert el != null;
        if (size(queue) == queue.elements.length) {
            Object[] subArray = new Object[queue.elements.length * 2];
            System.arraycopy(queue.elements, queue.start, subArray, 0, queue.elements.length - queue.start);
            if (queue.finish < queue.start) {
                System.arraycopy(queue.elements, 0, subArray, queue.elements.length - queue.start, queue.finish + 1);
                queue.finish += queue.elements.length - queue.start;
            }
            queue.start = 0;
            queue.elements = subArray;
        }
        queue.finish = (queue.finish + 1) % queue.elements.length;
        queue.elements[queue.finish] = el;
    }
    // Pred: ArrayQueueADT == class(queue) && n > 0
    // Post: R = a[0] && n` = n - 1 && for i in 1..n`: a`[i] = a[i - 1]
    public static Object dequeue(ArrayQueueADT queue ) {
        assert !isEmpty(queue);
        Object res = queue.elements[queue.start];
        queue.elements[queue.start] = null;
        queue.start = (queue.start + 1) % queue.elements.length;
        if (queue.elements[queue.finish] == null){
            queue.finish = -1;
            queue.start = 0;
        }
        return res;
    }
    // Pred: ArrayQueueADT == class(queue)
    // Post: R = n + 1
    public static int size(ArrayQueueADT queue ) {
        if(abs(queue.finish) >= queue.start){
            return queue.finish - queue.start + 1;
        }
        return queue.finish - queue.start + queue.elements.length + 1;
    }
    // Pred: ArrayQueueADT == class(queue)
    // Post: R = n + 1 == 0
    public static boolean isEmpty(ArrayQueueADT queue) {
        return size(queue) == 0;
    }
    // Pred: ArrayQueueADT == class(queue)
    // Post: n + 1 = 0
    public static void clear(ArrayQueueADT queue) {
        queue.elements = new Object[queue.sizeCQ];
        queue.start = 0;
        queue.finish = -1;
    }
    // Pred: ArrayQueueADT == class(queue) && n > 0
    // Post: R = a[0]
    public static Object element(ArrayQueueADT queue ) {
        assert !isEmpty(queue);
        return queue.elements[queue.start];
    }
    // Pred: ArrayQueueADT == class(queue) && el != null
    // Post: if el in a : a[R] = el && for j in R ... n : a[j] != el else: R = -1
    public static int lastIndexOf(ArrayQueueADT queue , Object el) {
        for (int i = (queue.finish + queue.elements.length) % queue.elements.length; i >= queue.start; i--) {
            if (queue.elements[i] == el) {
                return i;
            }
        }
        return -1;
    }
    // Pred: ArrayQueueADT == class(queue)
    // Post: R = [a[0] , ... , a[n]]
    public static String toStr(ArrayQueueADT queue){
        Object[] ans = new Object[size(queue)];
        if (queue.finish == -1){
            return "[]";
        }
        if (queue.start <= queue.finish){
            if (queue.finish + 1 - queue.start >= 0) {
                System.arraycopy(queue.elements, queue.start, ans, 0, queue.finish + 1 - queue.start);
            }
        }else {
            if (queue.elements.length - queue.start >= 0) {
                System.arraycopy(queue.elements, queue.start, ans, 0, queue.elements.length - queue.start);
            }
            if (queue.finish + 1 >= 0) {
                System.arraycopy(queue.elements, 0, ans, queue.elements.length - queue.start, queue.finish + 1);
            }
        }

        return Arrays.toString(ans);
    }
}
