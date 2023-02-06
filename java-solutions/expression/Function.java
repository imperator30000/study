package expression;

import expression.parser.TaskElement;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public abstract class Function implements AllExpression{
    AllExpression[] expressions;
    public Function(AllExpression ... v){
        this.expressions = v;
    }
    @Override
    public double evaluate(double x) {
        return 0;
    }

    @Override
    public int evaluate(int x) {
        int[] ans = new int[this.expressions.length];
        for (int i = 0; i < this.expressions.length;i++){
            ans[i] = this.expressions[i].evaluate(x);
        }
        return solve(ans);
    }

    @Override
    public int evaluate(int x, int y, int z) {
        int[] ans = new int[this.expressions.length];
        for (int i = 0; i < this.expressions.length;i++){
            ans[i] = this.expressions[i].evaluate(x, y, z);
        }
        return solve(ans);
    }

    @Override
    public String toString() {
        StringBuilder sb= new StringBuilder("(");
        sb.append(this.expressions[0].toString());

        for (int i = 1; i < this.expressions.length; i++){
            sb.append(", ");
            sb.append(this.expressions[i].toString());
        }
        sb.append(')');
        return sb.toString();
    }
    public String toMiniString(){
        return "";
    }

    protected abstract int solve(int ... v);
}
