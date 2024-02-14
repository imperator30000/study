package expression.exceptions;

public class ExpressionExceptions extends RuntimeException{
    public ExpressionExceptions(String m){
        super("Expression exceptions : " + m);
    }
}
