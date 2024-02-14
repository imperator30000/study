package expression.operand;

public class OperandDouble implements Operand<Double>{
    @Override
    public Double add(Double a, Double b) {
        return a + b;
    }

    @Override
    public Double subtract(Double a, Double b) {
        return a - b;
    }

    @Override
    public Double multiply(Double a, Double b) {
        return a * b;
    }

    @Override
    public Double divide(Double a, Double b) {
        return a / b;
    }

    @Override
    public Double unarySubtract(Double a) {
        return -a;
    }


    @Override
    public Double cast(String a) {
        return Double.parseDouble(a);
    }

    @Override
    public Double cast(int a) {
        return cast(String.valueOf(a));
    }


}
