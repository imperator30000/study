import Foundation

class Task: Hashable {
    let id = UUID()
    var name: String
    var priority: Int
    var dependencies: [Task] = []

    init(priority: Int, name: String) {
        self.priority = priority
        self.name = name
    }

    func addDependency(_ task: Task) {
        dependencies.append(task)
    }

    func execute() {
        print(name)
    }

    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


class TaskManager {
    private var tasks = ThreadSafeArray<Task>()
    private let lock = RWLock()
    func add(_ task: Task) -> Void {
        tasks.append(task)
    }
    func run() {
        lock.write {
            tasks.sort {$0.priority >= $1.priority}
            let sortedTasks = topologicalSort(tasks)
            sortedTasks.forEach { $0.execute() }
        }
        
    }
    private func topologicalSort(_ tasks: ThreadSafeArray<Task>) -> ThreadSafeArray<Task> {
        var visited = Set<Task>()
        var currentlyInStack = Set<Task>()
        var result = ThreadSafeArray<Task>()

        for task in tasks {
            if !visited.contains(task) {
                if topologicalSortVisit(task, &visited, &currentlyInStack, &result) {
                    fatalError("Error dependencies cycle")
                }
            }
        }

        return result
    }

    private func topologicalSortVisit(_ task: Task, _ visited: inout Set<Task>, _ currentlyInStack: inout Set<Task>, _ result: inout ThreadSafeArray<Task>) -> Bool {
        if currentlyInStack.contains(task) {
            return true
        }

        if visited.contains(task) {
            return false
        }

        visited.insert(task)
        currentlyInStack.insert(task)

        for dependency in task.dependencies {
            if topologicalSortVisit(dependency, &visited, &currentlyInStack, &result) {
                return true
            }
        }

        currentlyInStack.remove(task)
        result.append(task)
        return false
    }

}
