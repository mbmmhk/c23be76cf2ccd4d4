
import Foundation

// This implementation provides thread safety while maintaining full backward compatibility
// with existing synchronous code that calls register() and resolve() methods.
final class Dependency {
    static let shared = Dependency()

    // Thread-safe storage using NSLock for synchronization
    private let lock = NSLock()
    private var registerMap: [ObjectIdentifier: (Dependency) -> Any]
    private var resolveMap: [ObjectIdentifier: Any]

    // Private initializer to enforce singleton pattern
    private init() {
        self.registerMap = [:]
        self.resolveMap = [:]
    }

    // MARK: - Testing Support
    // Internal initializer for testing - allows creating isolated instances with custom storage
    // This follows dependency injection principles and is more elegant than boolean flags
    internal init(registerMap: [ObjectIdentifier: (Dependency) -> Any] = [:],
                  resolveMap: [ObjectIdentifier: Any] = [:]) {
        self.registerMap = registerMap
        self.resolveMap = resolveMap
    }

    // MARK: - Registration Methods

    func register<T>(_ type: T.Type, block: @escaping (Dependency) -> T) {
        lock.lock()
        defer { lock.unlock() }
        registerMap[ObjectIdentifier(type)] = block
    }

    // MARK: - Resolution Methods

    func resolve<T>(_ type: T.Type) -> T? {
        let key = ObjectIdentifier(type)

        // Try to read existing instance
        lock.lock()
        if let existing = resolveMap[key] as? T {
            lock.unlock()
            return existing
        }

        // Look up the factory for the given type
        guard let factory = registerMap[key] else {
            lock.unlock()
            return nil
        }

        // Release lock before calling factory to avoid deadlock
        lock.unlock()

        // Create new instance using the factory
        guard let newService = factory(self) as? T else {
            return nil
        }

        // Re-acquire lock to store the instance
        lock.lock()
        // Double-check pattern: another thread might have created the instance
        if let existing = resolveMap[key] as? T {
            lock.unlock()
            return existing
        }

        // Store the instance for future use (singleton pattern)
        resolveMap[key] = newService
        lock.unlock()

        return newService
    }
}
