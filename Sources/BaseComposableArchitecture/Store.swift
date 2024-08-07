//
//  Store.swift
//
//
//  Created by Amin Amjadi on 24/07/2024.
//

import Foundation
import Combine

/// A convenience type alias for referring to a store of a given reducer's domain.
///
/// Instead of specifying two generics:
///
/// ```swift
/// let store: Store<Feature.State, Feature.Action>
/// ```
///
/// You can specify a single generic:
///
/// ```swift
/// let store: StoreOf<Feature>
/// ```
public typealias StoreOf<R: Reducer> = Store<R.State, R.Action>

fileprivate typealias StoreType = ObservableObject & Dispatching

/// Defines an instance which can dispatch events
public protocol Dispatching {
    associatedtype Action
/// Initializes an effect that immediately emits the action passed in.
    func send(_ action: Action)
}

/// A ``store`` represents the runtime that powers the application. It is the object that you will pass around
/// to views that need to interact with the application.
public final class Store<State, Action>: StoreType {

    private let reducer: any Reducer<State, Action>
    // Turns an effect into one that is capable of being canceled.
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) public var state: State

    required public init<R: Reducer>(initialState: R.State,
                                     reducer: R) where R.State == State, R.Action == Action {
        self.state = initialState
        self.reducer = reducer
    }

    public func send(_ action: Action) {
        let effect = reducer.reduce(into: &state, action: action)
        switch effect.operation {
        case .publisher(let publisher):
            publisher
                .subscribe(on: DispatchQueue.global())
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: send)
                .store(in: &cancellables)
        default:
            break
        }
    }
}
