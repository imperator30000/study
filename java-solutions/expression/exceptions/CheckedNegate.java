package expression.exceptions;

import expression.AllExpression;
import expression.UnarySubtract;

public class CheckedNegate extends UnarySubtract {
    public CheckedNegate(AllExpression el) {
        super(el);
    }
    protected int solve(int x){
        if (x == Integer.MIN_VALUE){
            throw new OverflowExceptions("x == " + x);
        }
        return super.solve(x);
    }
}
