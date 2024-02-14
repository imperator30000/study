package expression.operand;

public class OperandLong implements Operand<Long>{
    @Override
    public Long add(Long a, Long b) {
        return a + b;
    }

    @Override
    public Long subtract(Long a, Long b) {
        return a - b;
    }

    @Override
    public Long multiply(Long a, Long b) {
        return a * b;
    }

    @Override
    public Long divide(Long a, Long b) {
        return a / b;
    }

    @Override
    public Long unarySubtract(Long a) {
        return -a;
    }


    @Override
    public Long cast(String a) {
        return Long.parseLong(a);
    }

    @Override
    public Long cast(int a) {
        return cast(String.valueOf(a));
    }


}
