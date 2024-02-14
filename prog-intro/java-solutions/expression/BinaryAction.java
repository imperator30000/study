package expression;
import java.util.Arrays;
import java.util.Objects;


public abstract class BinaryAction implements AllExpression{
    final AllExpression[] list = new AllExpression[2];
    public BinaryAction(AllExpression operand1, AllExpression operand2){
        this.list[0] = operand1;
        this.list[1] = operand2;
    }
    @Override
    public int evaluate(int x) {
        return solve(this.list[0].evaluate(x), this.list[1].evaluate(x));
    }
    @Override
    public double evaluate(double x) {
        return solve(this.list[0].evaluate(x), this.list[1].evaluate(x));
    }
    @Override
    public int evaluate(int x, int y, int z) {
        return solve(this.list[0].evaluate(x, y, z), this.list[1].evaluate(x, y, z));
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append('(');
        sb.append(list[0].toString());
        sb.append(' ');
        sb.append(this.getActionChar());
        sb.append(' ');
        sb.append(list[1].toString());
        sb.append(')');
        return sb.toString();
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj == null || obj.getClass() != this.getClass()) {
            return false;
        }
        BinaryAction el = (BinaryAction) obj;
        return this.list[0].equals(el.list[0]) && this.list[1].equals(el.list[1]);

    }
    @Override
    public int hashCode() {
        return Objects.hash(Arrays.hashCode(this.list), this.getClass());
    }
    protected abstract int solve(int x, int y);
    protected abstract double solve(double x, double y);
    protected abstract String getActionChar();

    public String toMiniString(){
        return "";
    }
    }
