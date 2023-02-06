package expression.exceptions;

import expression.AllExpression;
import expression.Multiply;

public class CheckedMultiply extends Multiply {
    public CheckedMultiply(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }
    protected int solve(int x, int y){
        if (x == Integer.MIN_VALUE && y < 0 || y == Integer.MIN_VALUE && x < 0){
            throw new OverflowExceptions(x + super.getActionChar() + y);
        }
        return super.solve(x, y);
    }
}
