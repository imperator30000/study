package queue;

import java.util.Objects;

public class LinkedQueue extends AbstractQueue {
    // Invariant: n - index of the last element in the queue , n + 1 - queue length
    // Model: a[0] ... a[n]
    // Invariant: for i in 0...n: a[i] != null
    private static class Node {
        private Node next;
        public Object el;

        public Node(Object elNew) {
            el = elNew;
        }

        @Override
        public String toString() {
            return el.toString();
        }
    }

    private Node start, finish;
    // Pred: el != null
    // Post: R: for i in a[0] ... a[n] if a[i] == el R++;
    @Override
    public int count(Object el) {
        Node st = start;
        int c = 0;
        while (st != null){
            if (Objects.equals(st.el, el)){
                c++;
            }
            st = st.next;
        }
        return c;
    }

    //    private int size = 0;
    // Pred: el != null
    // Post: n` = n + 1 && for i in 1..n`: a`[i] = a[i] && a`[n`] = el
    public void enqueue(Object el) {
        assert el != null;
        Node tmp = new Node(el);

        if (size == 0) {
            start = tmp;
        } else {
            finish.next = tmp;
        }
        finish = tmp;
        size++;
//        System.out.println("1" + this);
//        System.out.println("2" + size);
//        System.out.println("3" + el);
//        System.out.println("4" + tmp.el);
//        System.out.println("5" + start);
    }
    // Pred: n > 0
    // Post: R = a[0] && n` = n - 1 && for i in 1..n`: a`[i] = a[i - 1]
    public Object dequeue() {
        Object res = start.el;
        start = start.next;
        size--;
        if (start == null) {
            finish = null;
        }
//        System.out.println(res + "   -----");
        return res;
    }
    // Pred: true
    // Post: R = n + 1
    //    public int size(){
//        return size;
//    }
    // Pred: true
    // Post: n + 1 = 0
    @Override
    protected void clearing() {
        start = null;
        finish = null;
    }
    // Pred: n > 0
    // Post: R = a[0]
    public Object element() {
//        System.out.println(this);
        return start.el;
    }
    // Pred: true
    // Post: R = n + 1 == 0
//    public boolean isEmpty(){
//        return size() == 0;
//    }

    @Override
    public String toString() {
        StringBuilder st = new StringBuilder();
        Node n = start;
        for (int i = 0; i < size; i++) {
            st.append(n.el.toString()).append(" ");
            n = n.next;
        }
        return st.toString();
    }
}
