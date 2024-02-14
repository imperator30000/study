package expression.generic.actions;

import expression.generic.GenericTripleExpression;

import java.util.Objects;

public abstract class Operand<T> implements GenericTripleExpression<T> {
    private final Object x;
    private final expression.operand.Operand<T> operand;


    public Operand(Object x, expression.operand.Operand<T> operand) {
        this.x = x;
        this.operand = operand;
    }



    @Override
    public String toString() {
        return String.valueOf(this.x);
    }


    @Override
    public T evaluate(int x, int y, int z) {
        if (this.x.equals("x")) {
            return operand.cast(x);
        }
        if (this.x.equals("y")) {
            return operand.cast(y);
        }
        if (this.x.equals("z")) {
            return operand.cast(z);
        }
        return operand.cast(this.x.toString());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Operand<?> operand = (Operand<?>) o;
        return Objects.equals(x, operand.x);
    }

    @Override
    public int hashCode() {
        return Objects.hash(x);
    }

}
