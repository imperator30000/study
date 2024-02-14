package expression.operand;

public interface Operand<T> {
    T add(T a, T b);
    T subtract(T a, T b);
    T multiply(T a, T b);
    T divide(T a, T b);
    T unarySubtract(T a);
    T cast (String a);
    T cast (int a);

}
