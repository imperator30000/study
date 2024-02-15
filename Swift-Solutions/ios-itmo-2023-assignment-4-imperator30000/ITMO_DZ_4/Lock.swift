import Foundation

class RWLock {
    private var rwlock = pthread_rwlock_t()

    init() {
        let initResult = pthread_rwlock_init(&rwlock, nil)
        guard initResult == 0 else {
            fatalError("RWLock initialization failed with error code \(initResult)")
        }
    }

    deinit {
        let destroyResult = pthread_rwlock_destroy(&rwlock)
        guard destroyResult == 0 else {
            fatalError("RWLock destruction failed with error code \(destroyResult)")
        }
    }

    func read<T>(_ operation: () -> T) -> T {
        let lockResult = pthread_rwlock_rdlock(&rwlock)
        guard lockResult == 0 else {
            fatalError("Failed to acquire read lock with error code \(lockResult)")
        }

        defer {
            let unlockResult = pthread_rwlock_unlock(&rwlock)
            guard unlockResult == 0 else {
                fatalError("Failed to release read lock with error code \(unlockResult)")
            }
        }

        return operation()
    }

    func write<T>(_ operation: () -> T) -> T {
        let lockResult = pthread_rwlock_wrlock(&rwlock)
        guard lockResult == 0 else {
            fatalError("Failed to acquire write lock with error code \(lockResult)")
        }

        defer {
            let unlockResult = pthread_rwlock_unlock(&rwlock)
            guard unlockResult == 0 else {
                fatalError("Failed to release write lock with error code \(unlockResult)")
            }
        }

        return operation()
    }
}
