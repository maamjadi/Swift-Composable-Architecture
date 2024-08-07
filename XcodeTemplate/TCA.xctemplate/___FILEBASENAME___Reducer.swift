//___FILEHEADER___

import Foundation

struct ___FILEBASENAME___: Reducer {

    // MARK: - State

    struct State: Equatable {
        // State attributes should be declared here.
    }

    // MARK: - Action

    enum Action: Sendable {
        // View, Navigation and Logic Actions that can be taken from
        // ___VARIABLE_featureName:identifier___View or ___FILEBASENAME___ should be declared here.
    }

    // MARK: - body

    var body: some ReducerOf<Self> {
        Reduce({ state, action in
//            switch action {
//                ...
//            }
            return .none
        })
    }
}
