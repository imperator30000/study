package expression.generic.actions;


import expression.DoubleExpression;
import expression.Expression;
import expression.ToMiniString;
import expression.TripleExpression;

public interface AllExpression<T> extends Expression, TripleExpression, DoubleExpression, ToMiniString {
    T evaluate(T x);
}
