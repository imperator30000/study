package expression.parser;


public class TaskElement {
    public TaskElementType type;
    public Object value;

    public TaskElement(TaskElementType type, Object value) {
        this.type = type;
        this.value = value;
    }



    @Override
    public String toString() {
        return value.toString();
    }
}
