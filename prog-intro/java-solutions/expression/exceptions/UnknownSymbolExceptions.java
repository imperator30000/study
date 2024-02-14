package expression.exceptions;

public class UnknownSymbolExceptions extends ParserExceptions{
    public UnknownSymbolExceptions(String m) {
        super("Unknown symbol exceptions : " + m);
    }
}
