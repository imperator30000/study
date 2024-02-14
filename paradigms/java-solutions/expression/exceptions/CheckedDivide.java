package expression.exceptions;

import expression.AllExpression;
import expression.Divide;

public class CheckedDivide extends Divide {

    public CheckedDivide(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }

    protected int solve(int x, int y) {
        if (y == 0) {
            throw new DivisionByZeroExceptions(x + super.getActionChar() + y);
        }
//        if (x == 0){
//            throw new DivisionByZeroExceptions("x == 0");
//        }

        if (!(x == Integer.MIN_VALUE && y == -1)) {
            return super.solve(x, y);
        }
        throw new OverflowExceptions(x + super.getActionChar() + y);

    }
}
