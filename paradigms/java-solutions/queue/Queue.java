package queue;

public interface Queue {
    public int size();
    public abstract void enqueue(Object el);
    public abstract Object dequeue();
    public boolean isEmpty();
    public void clear();
    public abstract Object element();
}
