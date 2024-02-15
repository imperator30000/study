import Foundation

let ff = ThreadSafeArray<Int>()
//var dd = [1]
//dd.append(1)
ff.append(1)
ff.append(2)
ff.append(3)
ff.append(4)

ff.reverse()
//print(ff.dropFirst())
//
//let sd = ff[0]
let a = Task(priority: 12, name:"a")
let b = Task(priority: 2, name: "b")
let c = Task(priority: 11, name:"c")
let d = Task(priority: 3, name:"d")
let e = Task(priority: 10, name:"e")
let f = Task(priority: 1, name:"f")
let g = Task(priority: 10, name:"g")

b.addDependency(g)
c.addDependency(a)
c.addDependency(d)
d.addDependency(b)
e.addDependency(d)
e.addDependency(f)
f.addDependency(a)
f.addDependency(g)


//let a = Task(priority: 10, name:"a")
//let b = Task(priority: 2, name: "b")
//let c = Task(priority: 10, name:"c")
//a.addDependency(c)
//b.addDependency(a)
//c.addDependency(b)

let disp = TaskManager()
disp.add(a)
disp.add(b)
disp.add(c)
disp.add(d)
disp.add(e)
disp.add(f)
disp.add(g)


disp.run()
