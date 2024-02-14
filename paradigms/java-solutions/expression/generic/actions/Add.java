package expression.generic.actions;


import expression.generic.GenericTripleExpression;
import expression.operand.Operand;

public class Add<T> extends BinaryAction<T> {
    public Add(GenericTripleExpression<T> operand1, GenericTripleExpression<T> operand2, Operand<T> operand) {
        super(operand1, operand2, operand);
    }


    @Override
    protected T solve(T x, T y) {
        return operand.add(x, y);
    }




    @Override
    protected String getActionChar() {
        return "+";
    }
}
