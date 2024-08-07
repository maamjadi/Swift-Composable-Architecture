//
//  Effect.swift
//
//
//  Created by Amin Amjadi on 24/07/2024.
//

import Foundation
import Combine

/// A convenience type alias for referring to an effect of a given reducer's domain.
///
/// Instead of specifying the action:
///
/// ```swift
/// let effect: Effect<Feature.Action>
/// ```
///
/// You can specify the reducer:
///
/// ```swift
/// let effect: EffectOf<Feature>
/// ```
public typealias EffectOf<R: Reducer> = Effect<R.Action>

public struct Effect<Action> {
    @usableFromInline
    enum Operation {
        case none
        case publisher(AnyPublisher<Action, Never>)
        case run(TaskPriority? = nil, @Sendable (_ send: Send<Action>) async -> Void)
    }

    @usableFromInline
    let operation: Operation

    @usableFromInline
    init(operation: Operation) {
        self.operation = operation
    }
}

// MARK: - Creating Effects

extension Effect {
    /// An effect that does nothing and completes immediately. Useful for situations where you must
    /// return an effect, but you don't need to do anything.
    @inlinable
    public static var none: Self {
        Self(operation: .none)
    }

    /// Initializes an effect that immediately emits the action passed in.
    ///
    /// > Note: We do not recommend using `Effect.send` to share logic. Instead, limit usage to
    /// > child-parent communication, where a child may want to emit a "delegate" action for a parent
    /// > to listen to.
    ///
    /// - Parameter action: The action that is immediately emitted by the effect.
    public static func send(_ action: Action) -> Self {
        Self(operation: .publisher(Just(action).eraseToAnyPublisher()))
    }

    /// Wraps an asynchronous unit of work that can emit actions any number of times in an effect.
    ///
    /// Then you could attach to it in a `run` effect by using `for await` and sending each action of
    /// the stream back into the system:
    ///
    /// ```swift
    /// case .startButtonTapped:
    ///   return .run { send in
    ///     for await event in self.events() {
    ///       send(.event(event))
    ///     }
    ///   }
    /// ```
    ///
    /// See ``Send`` for more information on how to use the `send` argument passed to `run`'s closure.
    ///
    /// The closure provided to ``run(priority:operation:catch:)`` is allowed to
    /// throw, but any non-cancellation errors thrown will cause a runtime warning when run in the
    /// simulator or on a device, and will cause a test failure in tests. To catch non-cancellation
    /// errors use the `catch` trailing closure.
    ///
    /// - Parameters:
    ///   - priority: Priority of the underlying task. If `nil`, the priority will come from
    ///     `Task.currentPriority`.
    ///   - operation: The operation to execute.
    ///   - catch: An error handler, invoked if the operation throws an error other than
    ///     `CancellationError`.
    /// - Returns: An effect wrapping the given asynchronous work.
    public static func run(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable (_ send: Send<Action>) async throws -> Void,
        catch handler: (@Sendable (_ error: Error, _ send: Send<Action>) async -> Void)? = nil
    ) -> Self {
        Self(
            operation: .run(priority) { send in
                do {
                    try await operation(send)
                } catch is CancellationError {
                    return
                } catch {
                    guard let handler else {
                        assertionFailure(
            """
            \(error.localizedDescription)

            All non-cancellation errors must be explicitly handled via the "catch" parameter \
            on "Effect.run", or via a "do" block.
            """
                        )
                        return
                    }
                    await handler(error, send)
                }
            }
        )
    }
}

/// A type that can send actions back into the system when used from
/// ``Effect/run(priority:operation:catch:fileID:line:)``.
///
/// This type implements [`callAsFunction`][callAsFunction] so that you invoke it as a function
/// rather than calling methods on it:
///
/// ```swift
/// return .run { send in
///   send(.started)
///   defer { send(.finished) }
///   for await event in self.events {
///     send(.event(event))
///   }
/// }
/// ```
///
/// See ``Effect/run(priority:operation:catch:fileID:line:)`` for more information on how to
/// use this value to construct effects that can emit any number of times in an asynchronous
/// context.
///
/// [callAsFunction]: https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID622
@MainActor
public struct Send<Action>: Sendable {
    let send: @MainActor @Sendable (Action) -> Void

    public init(send: @escaping @MainActor @Sendable (Action) -> Void) {
        self.send = send
    }

    /// Sends an action back into the system from an effect.
    ///
    /// - Parameter action: An action.
    public func callAsFunction(_ action: Action) {
        guard !Task.isCancelled else { return }
        self.send(action)
    }
}
