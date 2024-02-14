"use strict";
const vars = {
    "x": 0,
    "y": 1,
    "z": 2
}
const action = f => (...args) => (...val) => f(...args.map(ai => ai(...val)))
const subtract = action((a, b) => a - b);
const add = action((a, b) => a + b);
const multiply = action((a, b) => a * b);
const divide = action((a, b) => a / b);
const negate = action(a => -a);
const sin = action(a => Math.sin(a))
const cos = action(a => Math.cos(a))
const cnst = (a) => (...val) => a;
const one = cnst(1)
const two = cnst(2)


const variable = (a) => (...val) => val[vars[a]]
const myexpr = add(subtract(multiply(variable("x") , variable("x")), multiply(variable("x"), cnst(2))), cnst(1))
for (let i = 0; i < 11; i++){
    console.log(myexpr(i, 2, 3))
}