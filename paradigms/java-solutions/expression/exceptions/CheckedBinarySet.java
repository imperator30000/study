package expression.exceptions;

import expression.AllExpression;
import expression.BinarySet;

public class CheckedBinarySet extends BinarySet {

    public CheckedBinarySet(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }

    protected int solve(int x, int y){
        if (y < 31){
            return super.solve(x, y);

        }
        throw new OverflowExceptions("y == " + y);

    }
}
