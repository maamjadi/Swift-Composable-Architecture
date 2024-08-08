# The Composable Architecture

[![IDE](https://img.shields.io/badge/Xcode-15-blue.svg)](https://developer.apple.com/xcode/)
[![Swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpointfreeco%2Fswift-composable-architecture%2Fbadge%3Ftype%3Dswift-versions)](https://swift.org)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpointfreeco%2Fswift-composable-architecture%2Fbadge%3Ftype%3Dplatforms)](https://developer.apple.com)

The Base Composable Architecture (TCA, for short) is a library heavily inspired by [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) for building applications in a consistent
and understandable way, with composition, testing, and ergonomics in mind while being considerably lighter than the original library and offering the complete flexibility for it to get more easily adopted cross wide variety of projects.
<br><br>
This library allows developers to integrate their preferred third-party tools for optimal performance without being restricted to predefined tools. For example for handling Dependency Injection ([Factory](https://github.com/hmlongco/Factory) for DI).<br>
It can be used in SwiftUI, UIKit, and more, and on any Apple platform (iOS, macOS, visionOS, tvOS, and watchOS).

* [What is the Composable Architecture?](#what-is-the-composable-architecture)
* [Usage](#usage)
* [TCA Template Installation](#tca-template-installation)
* [Installation](#installation)
* [Example](#example)
<br>

## What is the Composable Architecture?

This library provides a few core tools that can be used to build applications of varying purpose and 
complexity. It provides compelling stories that you can follow to solve many problems you encounter 
day-to-day when building applications, such as:

* **State management**
  <br> How to manage the state of your application using simple value types, and share state across 
  many screens so that mutations in one screen can be immediately observed in another screen.

* **Composition**
  <br> How to break down large features into smaller components that can be extracted to their own, 
  isolated modules and be easily glued back together to form the feature.

* **Side effects**
  <br> How to let certain parts of the application talk to the outside world in the most testable 
  and understandable way possible.

* **Testing**
  <br> How to not only test a feature built in the architecture, but also write integration tests 
  for features that have been composed of many parts, and write end-to-end tests to understand how 
  side effects influence your application. This allows you to make strong guarantees that your 
  business logic is running in the way you expect.

* **Ergonomics**
  <br> How to accomplish all of the above in a simple API with as few concepts and moving parts as 
  possible.
<br>

## Usage

To build a feature using the Composable Architecture you define some types and values that model 
your domain:

* **State**: A type that describes the data your feature needs to perform its logic and render its 
UI.
* **Action**: A type that represents all of the actions that can happen in your feature, such as 
user actions, notifications, event sources and more.
* **Reducer**: A function that describes how to evolve the current state of the app to the next 
state given an action. The reducer is also responsible for returning any effects that should be 
run, such as API requests, which can be done by returning an `Effect` value.
* **Store**: The runtime that actually drives your feature. You send all user actions to the store 
so that the store can run the reducer and effects, and you can observe state changes in the store 
so that you can update UI.

The benefits of doing this are that you will instantly unlock testability of your feature, and you 
will be able to break large, complex features into smaller domains that can be glued together.
<br>

![Diagram](https://github.com/user-attachments/assets/a35b9fb3-aec7-4457-9ecd-9eb40af04521)

<br>

## TCA Template Installation
This library includes a custom Xcode template that simplifies feature development with TCA. The template automatically generates the necessary `View` and `Reducer` files, complete with boilerplate code and implementation comments.


All the Xcode custom template files are located in ~/Library/Developer/Xcode/Templates/ and grouped into sections by folder name. Create a folder with name `Custom Templates` manually or by running the following command from the terminal:

```
mkdir ~/Library/Developer/Xcode/Templates/Custom Templates
```
<br>
Now drag and drop the `TCA.xctemplate` that included with the repo under the `XcodeTemplate` folder to the `Custom Templates` directory. Now the TCA template can be selected from File Templates.
<img width="719" alt="image" src="https://github.com/user-attachments/assets/0ec0bc7d-dcaf-4274-9f1d-b870f2cb87a1">
<br>
Select `Next` and enter the name of your Feature on this page.
<img width="722" alt="image" src="https://github.com/user-attachments/assets/8e2b34fd-da2d-408c-9f4a-96181b96e7cb">
<br>
After selecting `Next` again, make sure to enter the same value (for the feature file) as you've entered on the previous step. 
<img width="793" alt="image" src="https://github.com/user-attachments/assets/c81d1ef3-8a56-4850-ae98-4cab8e428797">
<br>
Now you'll see the two new files added to your project.
<br>

## Installation

You can add **BaseComposableArchitecture** to an Xcode project by adding it as a package dependency.

  1. From the **File** menu, select **Add Package Dependencies...**
  2. Enter "[https://github.com/maamjadi/Swift-Composable-Architecture](https://github.com/maamjadi/Swift-Composable-Architecture)" into the package 
     repository URL text field
  3. Depending on how your project is structured:
      - If you have a single application target that needs access to the library, then add 
        **BaseComposableArchitecture** directly to your application.
      - If you want to use this library from multiple Xcode targets, or mix Xcode targets and SPM 
        targets, you must create a shared framework that depends on **BaseComposableArchitecture** and 
        then depend on that framework in all of your targets..
<br>

## Example

As a basic example, consider a UI that shows a number along with "+" and "−" buttons that increment 
and decrement the number. To make things interesting, suppose there is also a button that when 
tapped makes an API request to fetch a random fact about that number and displays it in the view.

To implement this feature we create a new type that will house the domain and behavior of the 
feature, and it will inherite the `Reducer` protocol:

```swift
import BaseComposableArchitecture

struct FeatureReducer: Reducer {
}
```

In here we need to define a type for the feature's state, which consists of an integer for the 
current count, as well as an optional string that represents the fact being presented:

```swift
struct FeatureReducer: Reducer {

  struct State: Equatable {
    var count = 0
    var numberFact: String?
  }
}
```

We also need to define a type for the feature's actions. There are the obvious actions, such as 
tapping the decrement button, increment button, or fact button. But there are also some slightly 
non-obvious ones, such as the action that occurs when we receive a response from the fact API 
request:

```swift
struct Feature: Reducer {

  struct State: Equatable { /* ... */ }
  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
    case numberFactButtonTapped
    case numberFactResponse(Result<Data, Error>)
    case numberFact(String)
  }
}
```

And then we implement the `body` property, which is responsible for composing the actual logic and 
behavior for the feature. In it we can use the `Reduce` reducer to describe how to change the
current state to the next state, and what effects need to be executed. Some actions don't need to
execute effects, and they can return `.none` to represent that:

```swift

import Factory

struct Feature: Reducer {

  struct State: Equatable { /* ... */ }
  enum Action { /* ... */ }

  @LazyInjected(\.authenticationClient) var networkClient

  var body: some Reducer<Self> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
        return .none

      case let .numberFactResponse(.failure(error)):
        state.numberFact = nil
        return .none

      case let .numberFactResponse(.success(data)):
        state.numberFact = String(decoding: data, as: UTF8.self)
        return .none

      case .incrementButtonTapped:
        state.count += 1
        return .none

      case .numberFactButtonTapped:
        return .run { [count = state.count] send in
          guard let url = URL(string: "http://numbersapi.com/\(count)/trivia") else { 
            await send(.twoFactorResponse(.failure(Error.urlConversion)))
            return
          }

          await send(
            .twoFactorResponse(
              await Result { try await self.networkClient.get(from: url) }
            )
          )
        }
      }
    }
  }
}
```

And then finally we define the view that displays the feature. It holds onto a `StoreOf<Feature>` 
so that it can observe all changes to the state and re-render, and we can send all user actions to 
the store so that state changes:

```swift
struct FeatureView: View {
  @ObservedObject var store: StoreOf<FeatureReducer>

  init(store: StoreOf<FeatureReducer>) {
    self.store = store
  }

  var body: some View {
    Form {
      Section {
        Text("\(store.count)")
        Button("Decrement") { store.send(.decrementButtonTapped) }
        Button("Increment") { store.send(.incrementButtonTapped) }
      }

      Section {
        Button("Number fact") { store.send(.numberFactButtonTapped) }
      }
      
      if let fact = store.numberFact {
        Text(fact)
      }
    }
  }
}
```

It is also straightforward to have a UIKit controller driven off of this store. You can observe
state changes in the store in `viewDidLoad`, and then populate the UI components with data from
the store. The code is a bit longer than the SwiftUI version, so we have collapsed it here:

<details>
  <summary>Click to expand!</summary>

  ```swift
  import BaseComposableArchitecture

  class FeatureViewController: UIViewController {
    let store: StoreOf<FeatureReducer>

    init(store: StoreOf<FeatureReducer>) {
      self.store = store
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
      super.viewDidLoad()

      let countLabel = UILabel()
      let decrementButton = UIButton()
      let incrementButton = UIButton()
      let factLabel = UILabel()
      
      // Omitted: Add subviews and set up constraints...
      
      observe { [weak self] in
        guard let self else { return }
        
        countLabel.text = "\(self.store.text)"
        factLabel.text = self.store.numberFact
      }
    }

    @objc private func incrementButtonTapped() {
      store.send(.incrementButtonTapped)
    }
    @objc private func decrementButtonTapped() {
      store.send(.decrementButtonTapped)
    }
    @objc private func factButtonTapped() {
      store.send(.numberFactButtonTapped)
    }
  }
  ```
</details>

Once we are ready to display this view, for example in the app's entry point, we can construct a 
store. This can be done by specifying the initial state to start the application in, as well as 
the reducer that will power the application:

```swift
import BaseComposableArchitecture

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      FeatureView(
        store: Store(initialState: FeatureReducer.State(), reducer: FeatureReducer())
      )
    }
  }
}
```

And that is enough to get something on the screen to play around with. It's definitely a few more 
steps than if you were to do this in a vanilla SwiftUI way, but there are a few benefits. It gives 
us a consistent manner to apply state mutations, instead of scattering logic in some observable 
objects and in various action closures of UI components. It also gives us a concise way of 
expressing side effects. And we can immediately test this logic, including the effects, without 
doing much additional work.
<br>

## Other libraries

The Composable Architecture was built on a foundation of ideas started by other libraries, in 
particular [Elm](https://elm-lang.org) and [Redux](https://redux.js.org/).
<br>
For optimal results, it is recommended to use this library in conjunction with the [Factory](https://github.com/hmlongco/Factory) Dependency Injection library.
<br>

## Acknowledgments

* [The Composable Architecture Advance](https://github.com/pointfreeco/swift-composable-architecture)
* [App Architecture Workshop](https://github.com/gorillalogic/App-Architecture-Workshop/tree/master)
* [iOS Project Best Practices and Tools](https://medium.com/@piotr.gorzelany/ios-project-best-practices-and-tools-c46135b8116d)
* [Development, Staging and Production Configs in Xcode](https://medium.com/better-programming/how-to-create-development-staging-and-production-configs-in-xcode-ec58b2cc1df4)
* [iOS Build Management using Custom Build Scheme](https://www.talentica.com/blogs/ios-build-management-using-custom-build-scheme/)

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
