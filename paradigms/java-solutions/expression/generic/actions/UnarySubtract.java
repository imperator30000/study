package expression.generic.actions;

import expression.AllExpression;
import expression.generic.GenericTripleExpression;
import expression.operand.Operand;

public class UnarySubtract<T> extends UnaryActions<T> {


    public UnarySubtract(GenericTripleExpression<T> el, Operand<T> operand) {
        super(el, operand);
    }
    @Override
    protected T solve(T x) {
        return operand.unarySubtract(x);
    }

    @Override
    public String toString() {
        return "-" + super.toString();
    }


}
