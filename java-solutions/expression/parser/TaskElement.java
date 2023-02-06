package expression.parser;


public class TaskElement<T> {
    public TaskElementType type;
    public T value;

    public TaskElement(TaskElementType type, T value) {
        this.type = type;
        this.value = value;
    }



    @Override
    public String toString() {
        return value.toString();
    }
}
