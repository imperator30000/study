package expression.operand;

public class OperandShort implements Operand<Short>{
    @Override
    public Short add(Short a, Short b) {
        return(short) ((int) a + (int) b);
    }

    @Override
    public Short subtract(Short a, Short b) {
        return(short) ((int) a - (int) b);    }

    @Override
    public Short multiply(Short a, Short b) {
        return(short) ((int) a * (int) b);

    }

    @Override
    public Short divide(Short a, Short b) {
        return(short) ((int) a / (int) b);
    }

    @Override
    public Short unarySubtract(Short a) {
        return (short) - (int) a;
    }


    @Override
    public Short cast(String a) {
        return cast(Integer.parseInt(a));
    }

    @Override
    public Short cast(int a) {
        return (short) a;
    }
}
