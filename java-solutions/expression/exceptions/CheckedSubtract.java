package expression.exceptions;

import expression.AllExpression;
import expression.Subtract;

public class CheckedSubtract extends Subtract {
    public CheckedSubtract(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }
    protected int solve(int x, int y){
        if (x > Integer.MAX_VALUE + y && y < 0 || x < Integer.MIN_VALUE + y && y > 0){
            throw new OverflowExceptions(x + super.getActionChar() + y);
        }
        return super.solve(x, y);
    }
}
