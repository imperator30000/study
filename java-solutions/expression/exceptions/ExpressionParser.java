package expression.exceptions;


import expression.*;
import expression.parser.TaskElement;
import expression.parser.TaskElementType;
import expression.parser.TripleParser;

import java.util.*;

public class ExpressionParser implements TripleParser {


    static int kur = -1;
    static Set<TaskElementType> BinaryOperations = Set.of(
            TaskElementType.ACTION_ADD,
            TaskElementType.ACTION_SUBTRACT,
            TaskElementType.ACTION_MULTIPLY,
            TaskElementType.ACTION_DIVIDE,
            TaskElementType.ACTION_MAX,
            TaskElementType.ACTION_MIN,
            TaskElementType.ACTION_SET,
            TaskElementType.ACTION_CLEAR);

    static Set<TaskElementType> Operands = Set.of(TaskElementType.VARIABLE, TaskElementType.CONST);
    static Map<String, TaskElementType> actions = new HashMap<>() {{
        put("+", TaskElementType.ACTION_ADD);
        put("-", TaskElementType.ACTION_SUBTRACT);
        put("*", TaskElementType.ACTION_MULTIPLY);
        put("/", TaskElementType.ACTION_DIVIDE);
        put("(", TaskElementType.BRACKET_LEFT);
        put(")", TaskElementType.BRACKET_RIGHT);
        put("x", TaskElementType.VARIABLE);
        put("y", TaskElementType.VARIABLE);
        put("z", TaskElementType.VARIABLE);
        put("min", TaskElementType.ACTION_MIN);
        put("max", TaskElementType.ACTION_MAX);
        put("set", TaskElementType.ACTION_SET);
        put("clear", TaskElementType.ACTION_CLEAR);
    }};


    public static AllExpression priority1(ArrayList<TaskElement> taskElements) {
        AllExpression left = null;
        while (true) {
            kur++;
            if (kur >= taskElements.size()) {
                System.out.println(taskElements);
            }
            TaskElement taskElement = taskElements.get(kur);

            if (taskElement.type == TaskElementType.CONST) {
                return new Const(taskElement.value);
            } else if (taskElement.type == TaskElementType.VARIABLE) {
                return new Variable(String.valueOf(taskElement.value));
            } else if (taskElement.type == TaskElementType.ACTION_UNARY_SUBTRACT) {
                return new CheckedNegate(priority1(taskElements));
            } else if (!BinaryOperations.contains(taskElement.type) && taskElement.type != TaskElementType.BRACKET_RIGHT) {
                if (taskElement.type == TaskElementType.BRACKET_LEFT) {
                    left = priority4(taskElements);

                }
                kur++;
                if (left != null) {
                    return left;
                }
                throw new ParserExceptions("");

            } else {
                throw new ParserExceptions("");
            }
        }

    }

    public static AllExpression priority2(ArrayList<TaskElement> taskElements) {
        AllExpression left = priority1(taskElements);
        while (true) {
            kur++;
            TaskElement taskElement = taskElements.get(kur);
            if (taskElement.type == TaskElementType.ACTION_MULTIPLY) {
                left = new CheckedMultiply(left, priority1(taskElements));
            } else if (taskElement.type == TaskElementType.ACTION_DIVIDE) {
                left = new CheckedDivide(left, priority1(taskElements));
            } else if (BinaryOperations.contains(taskElement.type) || taskElement.type == TaskElementType.END
                    || taskElement.type == TaskElementType.BRACKET_RIGHT) {
                kur--;
                return left;
            } else {
                throw new ParserExceptions(" ");
            }
        }
    }

    public static AllExpression priority3(ArrayList<TaskElement> taskElements) {
        AllExpression left = priority2(taskElements);
        while (true) {
            kur++;
            TaskElement taskElement = taskElements.get(kur);
            if (taskElement.type == TaskElementType.ACTION_ADD) {
                left = new CheckedAdd(left, priority2(taskElements));
            } else if (taskElement.type == TaskElementType.ACTION_SUBTRACT) {
                left = new CheckedSubtract(left, priority2(taskElements));
            } else if (BinaryOperations.contains(taskElement.type) || taskElement.type == TaskElementType.END
                    || taskElement.type == TaskElementType.BRACKET_RIGHT) {
                kur--;
                return left;
            } else {
                throw new ParserExceptions(" ");
            }
        }
    }

    public static AllExpression priority4(ArrayList<TaskElement> taskElements) {

        AllExpression left = priority3(taskElements);
        while (true) {
            kur++;

            TaskElement taskElement = taskElements.get(kur);
            if (taskElement.type == TaskElementType.ACTION_MAX) {
                left = new BinaryMax(left, priority3(taskElements));
            } else if (taskElement.type == TaskElementType.ACTION_MIN) {
                left = new BinaryMin(left, priority3(taskElements));
            } else if (taskElement.type == TaskElementType.ACTION_SET) {
                left = new BinarySet(left, priority3(taskElements));
            } else if (taskElement.type == TaskElementType.ACTION_CLEAR) {
                left = new BinaryClear(left, priority3(taskElements));
            } else if (BinaryOperations.contains(taskElement.type) || taskElement.type == TaskElementType.END
                    || taskElement.type == TaskElementType.BRACKET_RIGHT) {
                kur--;
                return left;
            } else {
                throw new ParserExceptions(" ");
            }
        }
    }


    public static TaskElementType itIsUnarySubtract(List<TaskElement> taskElements, TaskElementType taskElementType) {
        if (taskElementType == TaskElementType.ACTION_SUBTRACT && (taskElements.size() - 1 < 0 ||
                taskElements.get(taskElements.size() - 1).type != TaskElementType.BRACKET_RIGHT &&
                        taskElements.get(taskElements.size() - 1).type != TaskElementType.VARIABLE &&
                        taskElements.get(taskElements.size() - 1).type != TaskElementType.CONST

        )) {
            return TaskElementType.ACTION_UNARY_SUBTRACT;
        }
        return taskElementType;
    }


    public static void slt(String x, String minMax) {
//        if (x.equals(minMax)){
//            return;
//        }
//        if (x.length() < minMax.length()){
//            return;
//        }
        if (x.length() == minMax.length()) {
            for (int i = 0; i < x.length(); i++) {
                if (x.charAt(i) > minMax.charAt(i)) {
                    throw new OverflowExceptions(x);

                } else if (x.charAt(i) < minMax.charAt(i)) {
                    break;
                }
            }
        }
    }

    public static ArrayList<TaskElement> lexAnalysis(String task) {
        int balance = 0;
        int operandsCounter = 0;
        ArrayList<TaskElement> taskElements = new ArrayList<>();
        boolean wasSpace = false;
        for (int i = 0; i < task.length(); ) {
            char el = task.charAt(i);
            TaskElementType taskElementType = actions.getOrDefault(String.valueOf(el), TaskElementType.NONE);
            taskElementType = itIsUnarySubtract(taskElements, taskElementType);
            if (taskElementType == TaskElementType.BRACKET_LEFT) {
                balance++;
            }
            if (taskElementType == TaskElementType.BRACKET_RIGHT) {
                balance--;
            }
            if (taskElementType == TaskElementType.NONE) {
                if (el <= '9' && el >= '0') {
                    taskElementType = TaskElementType.CONST;
                    int finish = i;
                    while (true) {
                        el = task.charAt(finish);
                        if (el > '9' || el < '0') {
                            finish--;
                            break;
                        }
                        finish++;
                        if (finish >= task.length()) {
                            finish--;
                            break;
                        }
                    }
                    if (taskElements.size() > 0 && taskElements.get(taskElements.size() - 1).type == TaskElementType.ACTION_UNARY_SUBTRACT && !wasSpace) {
                        slt(task.substring(i, finish + 1), "2147483648");
                        taskElements.set(taskElements.size() - 1, new TaskElement<>(TaskElementType.CONST, Integer.parseInt('-' + task.substring(i, finish + 1))));
                    } else {
                        slt(task.substring(i, finish + 1), "2147483647");
                        int elem = Integer.parseInt(task.substring(i, finish + 1));
                        taskElements.add(new TaskElement<Integer>(taskElementType, elem));
                    }
                    i = finish;
                } else if (el >= 'a' && el <= 'z') {
                    int finish = i;
                    while (true) {
                        el = task.charAt(finish);
                        if (el > 'z' || el < 'a') {
                            finish--;
                            break;
                        }
                        finish++;
                        if (finish >= task.length()) {
                            finish--;
                            break;
                        }
                    }

                    taskElementType = actions.getOrDefault(task.substring(i, finish + 1), TaskElementType.NONE);
                    if (BinaryOperations.contains(taskElementType) && (i > 0 && task.charAt(i - 1) >= '0' && task.charAt(i - 1) <= '9'
                            || finish < task.length() - 1 && task.charAt(finish + 1) >= '0' && task.charAt(finish + 1) <= '9')){
                        throw new ParserExceptions("");
                    }
                    taskElements.add(new TaskElement<>(taskElementType, task.substring(i, finish + 1)));
                    if (taskElementType == TaskElementType.NONE) {
                        throw new UnknownSymbolExceptions(taskElements.get(taskElements.size() - 1).value.toString());
                    }
                    i = finish;
                } else if (!Character.isWhitespace(el)) {
                    throw new UnknownSymbolExceptions(String.valueOf(el));
                }
            } else {
                taskElements.add(new TaskElement<>(taskElementType, el));
            }
            wasSpace = false;
            i++;
            if (taskElementType == TaskElementType.NONE) {
                wasSpace = true;
            }
        }
        taskElements.add(new TaskElement<>(TaskElementType.END, '\n'));
        if (balance != 0) {
            throw new BracketExceptions("balance == " + balance + " : " + task);
        }
        return taskElements;
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        ExpressionParser e = new ExpressionParser();
//        e.parse("-2147483647 * -1");
        System.out.println(e.parse("x"));
//        for (int i = 0; i < 11; i++) {
//            try {
//                System.out.println(e.parse("y *").evaluate(1046457733, -1830650320, 1598611754));
//
//            } catch (Exception E) {
//                System.out.println(E.getMessage());
//            }
//        }
    }

    @Override
    public TripleExpression parse(String expression) {
//        System.out.println(expression);
        kur = -1;
        ArrayList<TaskElement> list = lexAnalysis(expression);
        AllExpression ans = priority4(list);
//        System.out.println(list);

        return ans;
    }
}
