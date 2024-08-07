//___FILEHEADER___

import SwiftUI

struct ___FILEBASENAME___: View {

    // MARK: - Internal Variables

    @ObservedObject var store: StoreOf<___VARIABLE_featureName:identifier___Reducer>

    // MARK: - Initializer

    init(store: StoreOf<___VARIABLE_featureName:identifier___Reducer>) {
        self.store = store
        // Do any additional initialization here.
    }

    // MARK: - body

    var body: some View {
        // Create your view here.
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

// MARK: - Preview

#Preview {
    ___FILEBASENAME___(store: Store(initialState: ___VARIABLE_featureName:identifier___Reducer.State(), reducer: ___VARIABLE_featureName:identifier___Reducer()))
}
