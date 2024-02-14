"use strict";
const vars = {"x": 0, "y": 1, "z": 2};
function Const(value) {
    this.value = value
}
Const.prototype.evaluate = function (...items) {
    return this.value;
};
Const.prototype.toString = function () {
    return `${this.value}`
};
Const.prototype.prefix = Const.prototype.toString
function Variable(value) {
    this.value = value
}
Variable.prototype.evaluate = function (...items) {
    return items[vars[this.value]]
}
Variable.prototype.toString = Const.prototype.toString
Variable.prototype.prefix = Const.prototype.toString
function Action(...values) {
    this.values = values;
}
Action.prototype.evaluate = function (...items) {
    return this.f(...this.values.map(ai => ai.evaluate(...items)));
};
Action.prototype.toString = function () {
    return [...this.values, this.get_sign].join(" ");
}
Action.prototype.prefix = function () {
    let res = "(".concat(this.get_sign).concat(" ")
    return res.concat([...this.values.map(ai => ai.prefix())].join(" ")).concat(")");
}
function fabricActions(f, get_sign) {
    function SubAction(...args){
        Action.call(this, ...args);
    }
    SubAction.prototype = Object.create(Action.prototype);
    SubAction.prototype.constructor = SubAction;
    SubAction.prototype.f = f
    SubAction.prototype.get_sign = get_sign
    return function (...args) {
        return new SubAction(...args);
    }
}
const Add = fabricActions((a, b) => a + b, "+")
const Subtract = fabricActions((a, b) => a - b, "-")
const Multiply = fabricActions((a, b) => a * b, "*")
const Divide = fabricActions((a, b) => a / b, "/")
const Power = fabricActions(Math.pow, "pow")
const Log = fabricActions((a, b) => Math.log(Math.abs(b)) / Math.log(Math.abs(a)), "log")
const Min3 = fabricActions(Math.min, "min3")
const Min5 = fabricActions(Math.min, "min5")
const Max3 = fabricActions(Math.max, "min3")
const Max5 = fabricActions(Math.max, "min5")
const Negate = fabricActions((a) => -a, "negate")
const Sinh = fabricActions(Math.sinh, "sinh")
const Sin = fabricActions(Math.sin, "sin")
const Cosh = fabricActions(Math.cosh, "cosh")
const Cos = fabricActions(Math.cos, "cos")
const Exp = fabricActions(Math.exp, "exp")
const Ln = fabricActions(Math.log, "ln")
const sum = (...args) => args.reduce((acc, val) => acc + val, 0);
const mean = (...args) => sum(...args) / args.length;
const variance = (...args) => {
    const a = mean(...args);
    return mean(...args.map(val => (val - a) ** 2));
}
const Variance = fabricActions(variance, "variance")
const Avg = fabricActions(mean, "avg")
const Mean = fabricActions(mean, "mean")
const Sum = fabricActions(sum, "sum")
const parse = (expression) => parser(expression.trim().split(/\s+/))
const actions_num = {
    "negate": [1, Negate],
    "sinh": [1, Sinh],
    "sin": [1, Sin],
    "cosh": [1, Cosh],
    "cos": [1, Cos],
    "exp": [1, Exp],
    "ln": [1, Ln],
    "+": [2, Add],
    "-": [2, Subtract],
    "*": [2, Multiply],
    "/": [2, Divide],
    "pow": [2, Power],
    "log": [2, Log],
    "max3": [3, Max3],
    "min3": [3, Min3],
    "max5": [5, Max5],
    "min5": [5, Min5],
    "mean": [Infinity, Mean],
    "avg": [Infinity, Avg],
    "sum": [Infinity, Sum],
    "variance": [Infinity, Variance]
}
const get_actions = (expression, operands) => actions_num[operands][1](...Array.from({length: actions_num[operands][0]}, () => parser(expression)).reverse());
const parser = expression => {
    const item = expression.pop()
    if (item in actions_num) return get_actions(expression, item)
    if (item in vars) return new Variable(item)
    return new Const(Number(item))
}
function ParserException(message) {
    this.message = message
}
ParserException.prototype = Object.create(Error.prototype);
ParserException.prototype.name = "ParserException: ";
ParserException.prototype.constructor = ParserException;
const parsePrefix = (expression) => {
    ind = -1
    if (expression.length === 0) throw new ParserException("empty")
    let exp = expression.replaceAll(")", " ) ").replaceAll("(", " ( ").trim().split(/\s+/)
    let ans = parsePrefixRec(exp, "Operand")
    if (exp.length !== ind + 1) throw new ParserException("Excessive info")
    return ans
}
let ind = -1
const makeMassage = (expression) => `expression: "${ind > 30 ? "... ":""}${expression.slice((Math.max(0 , ind - 30)), ind).join(" ")}"  -----> "${expression[ind]}" <----- ${ind !== expression.length ? " ...":""}\n`
const parsePrefixRec = (expression, mind) => {
    ind++
    if (expression[ind] === "(" && mind === "Operand") return parsePrefixRec(expression, "Action")
    if (expression[ind] in vars && mind === "Operand") return new Variable(expression[ind])
    if (expression[ind] in actions_num  && mind === "Action") {
        const action = actions_num[expression[ind]]
        let values = []
        let i = 0
        for (; expression[ind + 1] !== ")" && expression !== ind + 1; i++) values.push(parsePrefixRec(expression, "Operand"));
        if (expression[++ind] !== ")") throw new ParserException(makeMassage(expression) + `Missing ) (token index ${ind})\``)
        if (action[0] !== Infinity && i !== action[0]) throw new ParserException(makeMassage(expression) + `Unknown count operands "${expression[ind]}" (token index ${ind})`)
        return new action[1](...values)
    }
    if (!isNaN(expression[ind]) && mind === "Operand") return new Const(Number(expression[ind]))
    throw new ParserException(makeMassage(expression) + `Unknown ${mind} "` + expression[ind] + ` (token" index ${ind})`)
}
// console.log(parsePrefix("(sum x)").prefix())