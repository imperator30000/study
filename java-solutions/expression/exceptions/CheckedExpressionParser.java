package expression.exceptions;


import expression.*;
import expression.parser.TaskElement;
import expression.parser.TaskElementType;
import expression.parser.TripleParser;

import java.util.*;

public class CheckedExpressionParser implements TripleParser {



    static int kur = -1;
    static Map<String, TaskElementType> actions = new HashMap<>(){{
        put("+", TaskElementType.ACTION_ADD);
        put("-", TaskElementType.ACTION_SUBTRACT);
        put("*", TaskElementType.ACTION_MULTIPLY);
        put("/", TaskElementType.ACTION_DIVIDE);
        put("(", TaskElementType.BRACKET_LEFT);
        put(")", TaskElementType.BRACKET_RIGHT);
        put("x", TaskElementType.VARIABLE);
        put("y", TaskElementType.VARIABLE);
        put("z", TaskElementType.VARIABLE);
        put(",", TaskElementType.VIRGULE);
        put("min", TaskElementType.ACTION_MIN);
        put("max", TaskElementType.ACTION_MAX);
        put("set", TaskElementType.ACTION_SET);
        put("clear", TaskElementType.ACTION_CLEAR);
    }};



    static ArrayList<TaskElement> taskElements = new ArrayList<>();


    public static AllExpression goToDawn(int priority, ArrayList<TaskElement> taskElements) {
        AllExpression left = new Const<Integer>(0);
        if (priority > 1){
            left = goToDawn(priority - 1, taskElements);
        }
        while (true) {
            kur++;
            TaskElement taskElement = taskElements.get(kur);
            if (priority == 4){
                if (taskElement.type == TaskElementType.ACTION_MAX) {
                    left = new BinaryMax(left, goToDawn(3, taskElements));
                } else if (taskElement.type == TaskElementType.ACTION_MIN) {
                    left = new BinaryMin(left, goToDawn(3, taskElements));
                } else if (taskElement.type == TaskElementType.ACTION_SET) {
                    left = new BinarySet(left, goToDawn(3, taskElements));
                } else if (taskElement.type == TaskElementType.ACTION_CLEAR) {
                    left = new BinaryClear(left, goToDawn(3, taskElements));
                } else {
                    kur--;
                    return left;
                }
            }
            if (priority == 3) {
                if (taskElement.type == TaskElementType.ACTION_ADD) {
                    left = new CheckedAdd(left, goToDawn(2, taskElements));
                } else if (taskElement.type == TaskElementType.ACTION_SUBTRACT) {
                    left = new CheckedSubtract(left, goToDawn(2, taskElements));
                }  else {
                    kur--;
                    return left;
                }
            } else if (priority == 2) {
                if (taskElement.type == TaskElementType.ACTION_MULTIPLY) {
                    left = new CheckedMultiply(left, goToDawn(1, taskElements));
                } else if (taskElement.type == TaskElementType.ACTION_DIVIDE) {
                    left = new CheckedDivide(left, goToDawn(1, taskElements));
                } else {
                    kur--;
                    return left;
                }
            } else if (priority == 1) {
                if (taskElement.type == TaskElementType.CONST) {
                    return new Const(taskElement.value);
                } else if (taskElement.type == TaskElementType.VARIABLE) {
                    return new Variable(String.valueOf(taskElement.value));
                } else if (taskElement.type == TaskElementType.ACTION_UNARY_SUBTRACT) {
                    return new CheckedUnarySubtract(goToDawn(1, taskElements));
                } else if (taskElement.type == TaskElementType.BRACKET_LEFT) {
                    left = goToDawn(4, taskElements);
                    kur++;
                    return left;
                } else if (taskElement.type == TaskElementType.FUNCTION) {
                    kur++;
                    return chooseFunctions(taskElement, taskElements);
                } else if (taskElement.type == TaskElementType.VIRGULE) {
                    kur--;
                    return left;
                } else {
                    kur--;
                    return left;
                }
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

    public static AllExpression chooseFunctions(TaskElement taskElement, ArrayList<TaskElement> taskElements) {
        AllExpression[] data = new AllExpression[2];
        int i = 0;
        do {
            if (i >= data.length) {
                data = Arrays.copyOf(data, data.length * 2);
            }
            data[i] = goToDawn(1, taskElements);
            kur++;
            i++;
        } while (taskElements.get(kur).type == TaskElementType.VIRGULE);
        if (taskElement.value.equals("log")) {
            return new log(Arrays.copyOf(data, i));

        }
        return new log(Arrays.copyOf(data, i));

    }

    public static ArrayList<TaskElement> lexAnalysis(String task) {
        ArrayList<TaskElement> taskElements = new ArrayList<>();
        boolean wasSpace = false;
        for (int i = 0; i < task.length(); ) {
            char el = task.charAt(i);
            TaskElementType taskElementType = actions.getOrDefault(String.valueOf(el), TaskElementType.NONE);
            taskElementType = itIsUnarySubtract(taskElements, taskElementType);
            if (taskElementType == TaskElementType.ACTION_MULTIPLY && task.charAt(i + 1) == '*') {
                i += 2;
                taskElements.add(new TaskElement<String>(TaskElementType.POW, "**"));
                continue;
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
                        taskElements.set(taskElements.size() - 1, new TaskElement<>(TaskElementType.CONST, Integer.parseInt('-' + task.substring(i, finish + 1))));
                    } else {
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
                    if (taskElements.size() == 0 || taskElements.get(taskElements.size() - 1).type != TaskElementType.CONST &&
                            taskElements.get(taskElements.size() - 1).type != TaskElementType.VARIABLE &&
                            taskElements.get(taskElements.size() - 1).type != TaskElementType.BRACKET_RIGHT) {
                        taskElementType = TaskElementType.FUNCTION;
                    } else {
                        taskElementType = actions.getOrDefault(task.substring(i, finish + 1), TaskElementType.NONE);
                    }

                    taskElements.add(new TaskElement<>(taskElementType, task.substring(i, finish + 1)));
                    i = finish;
                }
            } else {
                taskElements.add(new TaskElement<Character>(taskElementType, el));
            }
            wasSpace = false;
            i++;
            if (taskElementType == TaskElementType.NONE) {
                wasSpace = true;
            }
        }
        taskElements.add(new TaskElement<>(TaskElementType.END, '\n'));
        return taskElements;
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        CheckedExpressionParser e = new CheckedExpressionParser();
        System.err.println(e.parse("100/0").evaluate(1, 1, 1));
    }

    @Override
    public TripleExpression parse(String expression) {
        ArrayList<TaskElement> list = lexAnalysis(expression);
        AllExpression ans = goToDawn(4, list);
        kur = -1;
        return ans;
    }
}
