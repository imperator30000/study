package expression.generic;

public interface GenericTripleExpression<T> {
    T evaluate(int x, int y, int z);
}
