package expression;

import java.util.Objects;

public abstract class Operand<T> implements AllExpression {
    private final T x;


    public Operand(T x) {
        this.x = x;
    }

    @Override
    public int evaluate(int x) {
        if (this.x.equals( "x")) {
            return x;
        }
            return (int) this.x;

    }
    @Override
    public double evaluate(double x) {
        if (this.x.equals( "x")) {
            return x;
        }
            return (double) this.x;
    }

    @Override
    public String toString() {
        return String.valueOf(this.x);
    }

    @Override
    public int evaluate(int x, int y, int z) {
        if (this.x.equals( "x")) {
            return x;
        }
        if (this.x.equals( "y")) {
            return y;
        }
        if (this.x.equals( "z")) {
            return z;
        }
        return (int) this.x;
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

    @Override
    public String toMiniString() {
        return "";
    }
}
