package expression.operand;

public class OperandFloat implements Operand<Float>{
    @Override
    public Float add(Float a, Float b) {
        return a + b;
    }

    @Override
    public Float subtract(Float a, Float b) {
        return a - b;
    }

    @Override
    public Float multiply(Float a, Float b) {
        return a * b;
    }

    @Override
    public Float divide(Float a, Float b) {
        return a / b;
    }

    @Override
    public Float unarySubtract(Float a) {
        return -a;
    }


    @Override
    public Float cast(String a) {
        return Float.parseFloat(a);
    }

    @Override
    public Float cast(int a) {
        return cast(String.valueOf(a));
    }

}
