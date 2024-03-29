package expression.exceptions;

import expression.Add;
import expression.AllExpression;

public class CheckedAdd extends Add {

    public CheckedAdd(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }

    protected int solve(int x, int y){
        if (!(x > Integer.MAX_VALUE - y && y > 0 || x < Integer.MIN_VALUE - y && y < 0)){
            return super.solve(x, y);
        }
        throw new OverflowExceptions(x + super.getActionChar() + y);

    }
}
