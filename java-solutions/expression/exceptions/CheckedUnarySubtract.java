package expression.exceptions;

import expression.AllExpression;
import expression.UnarySubtract;

public class CheckedUnarySubtract extends UnarySubtract {
    public CheckedUnarySubtract(AllExpression el) {
        super(el);
    }
    protected int solve(int x){
        if (x == Integer.MIN_VALUE){
            throw new OverflowExceptions("x = 2147483648");
        }
        return super.solve(x);
    };
}
