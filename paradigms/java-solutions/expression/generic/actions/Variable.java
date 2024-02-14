package expression.generic.actions;


public class Variable<T> extends Operand<T> {
    public Variable(Object x, expression.operand.Operand<T> operand) {
        super(x, operand);
    }
}
