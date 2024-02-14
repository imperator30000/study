package expression.exceptions;

import expression.AllExpression;
import expression.UnarySubtract;

public class CheckedNegate extends UnarySubtract {
    public CheckedNegate(AllExpression el) {
        super(el);
    }
    protected int solve(int x){
        if (x != Integer.MIN_VALUE){
            return super.solve(x);
        }
        throw new OverflowExceptions("x == " + x);

    }
}
