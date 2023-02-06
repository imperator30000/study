package expression;

public class log extends Function{
    public log(AllExpression ... v){
        super(v);
    }
    @Override
    protected int solve(int... v) {
        return (int) (Math.log10(v[1])/Math.log10(v[0]));
    }

    @Override
    public String toString() {
        return "log" + super.toString();
    }
}
