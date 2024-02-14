package expression.exceptions;

public class DivisionByZeroExceptions extends ExpressionExceptions{
    public DivisionByZeroExceptions(String m) {
        super("division by zero " + m);
    }
}
