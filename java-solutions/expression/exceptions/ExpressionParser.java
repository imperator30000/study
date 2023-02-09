package expression.exceptions;


import expression.*;
import expression.parser.TaskElement;
import expression.parser.TaskElementType;
import expression.parser.TripleParser;

import java.util.*;

public class ExpressionParser implements TripleParser {


    static int kur = -1;
    int count = 0;
    static Set<TaskElementType> BinaryOperations = Set.of(
            TaskElementType.ACTION_ADD,
            TaskElementType.ACTION_SUBTRACT,
            TaskElementType.ACTION_MULTIPLY,
            TaskElementType.ACTION_DIVIDE,
            TaskElementType.ACTION_MAX,
            TaskElementType.ACTION_MIN,
            TaskElementType.ACTION_SET,
            TaskElementType.ACTION_CLEAR);


    static Map<String, TaskElementType> actions = new HashMap<>();

//    "min", TaskElementType.ACTION_MIN,
//            "max", TaskElementType.ACTION_MAX,
//            "set", TaskElementType.ACTION_SET,
//            "clear", TaskElementType.ACTION_CLEAR
//            new HashMap<>() {{
//
//            }};


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
                throw new ParserExceptions("Dot`t search left operand");

            } else {
                throw new ParserExceptions("index " + kur + " : Аn operand or left or unary action parenthesis was expected");
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
                throw new ParserExceptions("index " + kur + " : Аn action was expected");
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
                throw new ParserExceptions("index " + kur + " : Аn action was expected");
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
                throw new ParserExceptions("index " + kur + " : Аn action was expected");
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
        if (x.length() < minMax.length()){
            return;
        }
        if (x.length() == minMax.length()) {
            for (int i = 0; i < x.length(); i++) {
                if (x.charAt(i) > minMax.charAt(i)) {
                    break;
                } else if (x.charAt(i) < minMax.charAt(i)) {
                    return;
                }
            }
        }
        throw new OverflowExceptions(x);
    }

    public static int iter(int i, String task, char l, char r) {
        int finish = i;
        int el;
        while (true) {
            el = task.charAt(finish);
            if (el > r || el < l) {
                finish--;
                break;
            }
            finish++;
            if (finish >= task.length()) {
                finish--;
                break;
            }
        }
        return finish;
    }

    public static ArrayList<TaskElement> lexAnalysis(String task) {
        actions.put("+", TaskElementType.ACTION_ADD);
                actions.put("-", TaskElementType.ACTION_SUBTRACT);
                actions.put("*", TaskElementType.ACTION_MULTIPLY);
                actions.put("/", TaskElementType.ACTION_DIVIDE);
                actions.put("(", TaskElementType.BRACKET_LEFT);
                actions.put(")", TaskElementType.BRACKET_RIGHT);
                actions.put("x", TaskElementType.VARIABLE);
                actions.put("y", TaskElementType.VARIABLE);
                actions.put("z", TaskElementType.VARIABLE);
                actions.put("min", TaskElementType.ACTION_MIN);
                actions.put("max", TaskElementType.ACTION_MAX);
                actions.put("set", TaskElementType.ACTION_SET);
                actions.put("clear", TaskElementType.ACTION_CLEAR);
        int balance = 0;
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
                    int finish = iter(i, task, '0', '9');
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
                    int finish = iter(i, task, 'a', 'z');
                    taskElementType = actions.getOrDefault(task.substring(i, finish + 1), TaskElementType.NONE);
                    if (BinaryOperations.contains(taskElementType) && (i > 0 && task.charAt(i - 1) >= '0' && task.charAt(i - 1) <= '9'
                            || finish < task.length() - 1 && task.charAt(finish + 1) >= '0' && task.charAt(finish + 1) <= '9')) {
                        throw new UnknownSymbolExceptions("You have to put a space between " + task.substring(i, finish + 1) + " and operands");
                    }
                    taskElements.add(new TaskElement<>(taskElementType, task.substring(i, finish + 1)));
                    if (taskElementType == TaskElementType.NONE) {
                        throw new UnknownSymbolExceptions(taskElements.get(taskElements.size() - 1).value.toString());
                    }
                    i = finish;
                } else if (Character.isWhitespace(el)) {
                    wasSpace = true;
                } else {
                    throw new UnknownSymbolExceptions(String.valueOf(el));
                }
            } else {
                wasSpace = false;
                taskElements.add(new TaskElement<>(taskElementType, el));
            }

            i++;
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
        System.out.println(e.parse("-(2)"));
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
//        System.err.println(expression);
        kur = -1;


        ArrayList<TaskElement> list = lexAnalysis(expression);
        AllExpression ans = priority4(list);
//        System.out.println(list);

        return ans;
    }
}
