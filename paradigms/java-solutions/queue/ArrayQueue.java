package queue;

import java.util.Arrays;
import java.util.Objects;

import static java.lang.Math.abs;
// Invariant: n - index of the last element in the queue , n + 1 - queue length
// Model: a[0] ... a[n]
// Invariant: for i in 0...n: a[i] != null

public class ArrayQueue extends AbstractQueue {
    private int start = 0 /*size = 0*/;
    private int finish = -1;
    private final int sizeCQ = 1;
    private Object[] elements = new Object[sizeCQ];

    public void main(String[] args) {
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
//        System.out.println(start);
//        System.out.println(finish);
//        enqueue(7);
//        System.out.println(Arrays.toString(elements));


    }
    // Pred: el != null
    // Post: R: for i in a[0] ... a[n] if a[i] == el R++;
    @Override
    public int count(Object el) {
        if (finish == -1) {
            return 0;
        }
        int c = 0;
        if (start <= finish) {
            for(int i = start; i <= finish;i++){
                if(Objects.equals(elements[i], el)){
                    c++;
                }
            }

        } else {
            for (int i = 0; i <= finish; i++){
                if(Objects.equals(elements[i], el)){
                    c++;
                }
            }
            for (int i = start; i < elements.length; i++){
                if(Objects.equals(elements[i], el)){
                    c++;
                }
            }
        }
        return c;
    }

    // Pred: el != null
    // Post: n` = n + 1 && for i in 1..n`: a`[i] = a[i] && a`[n`] = el
    public void enqueue(Object el) {
        assert el != null;
        if (size() == elements.length) {
            Object[] subArray = new Object[elements.length * 2];
            System.arraycopy(elements, start, subArray, 0, elements.length - start);
            if (finish < start) {
                System.arraycopy(elements, 0, subArray, elements.length - start, finish + 1);
                finish += elements.length - start;
            }
            start = 0;
            elements = subArray;
        }
        size++;
        finish = (finish + 1) % elements.length;
        elements[finish] = el;
    }

    // Pred: n > 0
    // Post: R = a[0] && n` = n - 1 && for i in 1..n`: a`[i] = a[i - 1]
    public Object dequeue() {
        assert !isEmpty();
        Object res = elements[start];
        elements[start] = null;
        start = (start + 1) % elements.length;
        if (elements[finish] == null) {
            finish = -1;
            start = 0;
        }
        size--;
        return res;
    }

    // Pred: true
    // Post: R = n + 1
//    public int size() {
////        if (abs(finish) >= start) {
////            return finish - start + 1;
////        }
////        return finish - start + elements.length + 1;
//        return size;
//    }

    // Pred: true
    // Post: R = n + 1 == 0
//    public boolean isEmpty() {
//        return size() == 0;
//    }

    // Pred: true
    // Post: n + 1 = 0
    @Override
    protected void clearing() {
        elements = new Object[sizeCQ];
        start = 0;
        finish = -1;
    }

    // Pred: n > 0
    // Post: R = a[0]
    public Object element() {
        assert !isEmpty();
        return elements[start];
    }

    // Pred: true
    // Post: R = [a[0] , ... , a[n]]
    public String toStr() {
        Object[] ans = new Object[size()];
        if (finish == -1) {
            return "[]";
        }
        if (start <= finish) {
            if (finish + 1 - start >= 0) {
                System.arraycopy(elements, start, ans, 0, finish + 1 - start);
            }
        } else {
            if (elements.length - start >= 0)
                System.arraycopy(elements, start, ans, 0, elements.length - start);
            if (finish + 1 >= 0) {
                System.arraycopy(elements, 0, ans, elements.length - start, finish + 1);
            }
        }

        return Arrays.toString(ans);
    }
}
