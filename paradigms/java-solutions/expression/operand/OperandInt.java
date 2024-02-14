package expression.operand;

public class OperandInt implements Operand<Integer>{
    @Override
    public Integer add(Integer a, Integer b) {
        return a + b;
    }

    @Override
    public Integer subtract(Integer a, Integer b) {
        return a - b;
    }

    @Override
    public Integer multiply(Integer a, Integer b) {
        return a * b;
    }

    @Override
    public Integer divide(Integer a, Integer b) {
        return a / b;
    }

    @Override
    public Integer unarySubtract(Integer a) {
        return -a;
    }



    @Override
    public Integer cast(String a) {
        return Integer.parseInt(a);
    }

    @Override
    public Integer cast(int a) {
        return cast(String.valueOf(a));
    }

}
