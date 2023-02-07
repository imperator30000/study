package expression.exceptions;

import expression.AllExpression;
import expression.Multiply;

public class CheckedMultiply extends Multiply {
    public CheckedMultiply(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }

    protected int solve(int x, int y) {
        int cur = x * y;
        if (x != 0 && cur / x != y || y != 0 && cur / y != x) {
            throw new OverflowExceptions(x + super.getActionChar() + y);
        }
        return super.solve(x, y);
    }


}
