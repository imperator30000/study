package expression.operand;

public class OperandByte implements Operand<Byte>{
    @Override
    public Byte add(Byte a, Byte b) {
        return(byte) ((int) a + (int) b);
    }

    @Override
    public Byte subtract(Byte a, Byte b) {
        return(byte) ((int) a - (int) b);    }

    @Override
    public Byte multiply(Byte a, Byte b) {
        return(byte) ((int) a * (int) b);

    }

    @Override
    public Byte divide(Byte a, Byte b) {
        return(byte) ((int) a / (int) b);
    }

    @Override
    public Byte unarySubtract(Byte a) {
        return (byte) - (int) a;
    }


    @Override
    public Byte cast(String a) {
        return Byte.parseByte(a);
    }

    @Override
    public Byte cast(int a) {
        return cast(String.valueOf(a));
    }

}
