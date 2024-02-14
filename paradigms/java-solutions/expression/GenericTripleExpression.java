package expression;

public interface GenericTripleExpression<T> extends TripleExpression {
    T evaluate(T x, T y, T z);
}
