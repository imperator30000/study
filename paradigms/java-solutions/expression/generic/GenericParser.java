package expression.generic;

@FunctionalInterface
public interface GenericParser<T> {
    GenericTripleExpression<T> parse(String expression) throws Exception;
}
