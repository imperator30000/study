package queue;

// Invariant: n - index of the last element in the queue , n + 1 - queue length
// Model: a[0] ... a[n]
// Invariant: for i in 0...n: a[i] != null
public abstract class AbstractQueue implements Queue{
    public int size = 0;
    // Pred: el != null
    // Post: R: for i in a[0] ... a[n] if a[i] == el R++;
    public abstract int count(Object el);
    // Pred: el != null
    // Post: n` = n + 1 && for i in 1..n`: a`[i] = a[i] && a`[n`] = el
    public abstract void enqueue(Object el);

    // Pred: n > 0
    // Post: R = a[0] && n` = n - 1 && for i in 1..n`: a`[i] = a[i - 1]
    public abstract Object dequeue();

    // Pred: true
    // Post: R = n + 1
    public int size() {
        return size;
    }

    // Pred: true
    // Post: R = n + 1 == 0
    public boolean isEmpty() {
        return size() == 0;
    }

    // Pred: true
    // Post: n + 1 = 0
    public void clear(){
        size = 0;
        clearing();
    };
    protected abstract void clearing();

    // Pred: n > 0
    // Post: R = a[0]
    public abstract Object element();

}
