package expression.generic.actions;


public class Const<T> extends Operand<T> {


    public Const(T x, expression.operand.Operand<T> operand) {
        super(x, operand);
    }
}
