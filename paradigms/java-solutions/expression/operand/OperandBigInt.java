package expression.operand;

import java.math.BigInteger;

public class OperandBigInt implements Operand<BigInteger> {
    @Override
    public BigInteger add(BigInteger a, BigInteger b) {
        return a.add(b);
    }

    @Override
    public BigInteger subtract(BigInteger a, BigInteger b) {
        return a.subtract(b);
    }

    @Override
    public BigInteger multiply(BigInteger a, BigInteger b) {
        return a.multiply(b);
    }

    @Override
    public BigInteger divide(BigInteger a, BigInteger b) {
        return a.divide(b);
    }

    @Override
    public BigInteger unarySubtract(BigInteger a) {
        return a.negate();
    }


    @Override
    public BigInteger cast(String a) {
        return new BigInteger(a);
    }

    @Override
    public BigInteger cast(int a) {
        return cast(String.valueOf(a));
    }

}
