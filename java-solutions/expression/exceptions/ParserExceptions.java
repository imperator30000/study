package expression.exceptions;

public class ParserExceptions extends RuntimeException{
    public ParserExceptions(String m){
        super("ParserExceptions : " + m);
    }
}
