# CDC Interview Project Development Summary Document


### Fix correct typo 'falg' to 'flag' in FeatureFlagProvider

**Changes I made:**
The original FeatureFlagProvider had an obvious spelling error where all method parameters were written as 'falg' instead of 'flag'.

**Rationale behind implementation decisions:**
In enterprise-level development, API naming consistency and correctness are quite important.

---

### Fix implement thread-safe dependency injection container

**Changes I made:**
Rewrote the Dependency class, added NSLock to ensure thread safety, implemented double-checked locking pattern to avoid deadlocks, and added an internal initializer to support creating independent dependency container instances during testing. Also created a unit test to verify multi-threading safety.

**Rationale behind implementation decisions:**
The original implementation had no synchronization mechanism and would encounter race conditions in multi-threaded environments. Secondly, although there was a `static let shared`, there was also a public `init()`, which violated the singleton pattern design principle, so I made it private. I chose NSLock over DispatchQueue because NSLock has lower performance overhead and is more direct and efficient for this simple mutual exclusion access scenario. The double-checked locking pattern implementation was to solve a potential deadlock problem - if factory methods internally also need to resolve other dependencies, and I'm still holding the lock when calling factory methods, it would cause deadlock. By releasing the lock before calling factory methods, then re-acquiring the lock for a second check, it ensures thread safety while avoiding deadlock. Adding the internal initializer was to support unit testing, as I place great importance on unit tests.

---

### Setup clean architecture folder structure

**Changes I made:**
Before working on the overall requirements, I wanted to reorganize the entire project according to Clean Architecture principles. Created many folders for layering.

**Rationale behind implementation decisions:**
I chose to implement Clean Architecture based on years of development experience. The original project file structure was unclear and would lead to several problems: First, poor maintainability - when project scale grows, developers find it hard to quickly locate files that need modification; second, unclear responsibilities with no clear boundaries to distinguish code at different levels; third, difficult team collaboration, prone to merge conflicts and understanding deviations during multi-person development. Clean Architecture's layered design solves these problems: Application layer handles app startup and configuration, Domain layer contains business logic and entities, Data layer handles data retrieval and storage, Presentation layer handles UI display. This layering not only improves code readability and maintainability, but more importantly establishes clear dependency relationships - outer layers depend on inner layers, inner layers don't depend on outer layers, making each layer independently testable and modifiable. The decision to delete Main.storyboard was because modern iOS development tends toward pure code UI construction, which avoids Storyboard merge conflict issues during team collaboration, while also making version control and code review easier.

---

### Refactor the data layer architecture

Then I made a quite important architectural refactoring commit - I refactored the data layer architecture.

## **Complete Architecture Refactoring Analysis**

### **1. Data Source Abstraction Layer**

**DataSourceProtocol Design:**
I created a generic protocol `DataSourceProtocol` with the core method `fetchData<T: Decodable>(forDataType:) async throws -> T`. This design has several key decisions: using generics allows one protocol to handle arbitrary types of data parsing; AnyObject constraint ensures the protocol can only be implemented by classes, facilitating dependency injection management.

**RxSwift Compatibility Extension:**
Then I added the `fetchDataSingle` extension method to be compatible with existing RxSwift code. This method uses `Single.create` to wrap async/await operations into RxSwift Single, includes weak reference protection to avoid retain cycles, supports task cancellation mechanism, and configures thread scheduling strategy for background execution with main thread callbacks.

### **2. Resource Type System**

**DataSourceResource Enum Architecture:**
I designed a complete resource type system containing usdPrices and allPrices resource types. Each resource has a series of convenience properties. This design eliminates string hardcoding, provides compile-time type safety, and has good extensibility.

### **3. Local Data Source**

**LocalDataSourceProvider Core Features:**
I implemented a fully-featured local data source provider, including network delay simulation functionality (configured through DataSourceConfiguration.networkDelaySimulation), layered error handling (different error types have different handling strategies), conditional logging (automatically enabled in Debug mode), and runtime resource validation. These features make local testing closer to real network environments while providing clear error messages and debugging support.

### **4. Complete Repository Pattern Implementation**

**MarketsRepositoryProtocol Design:**
I created business-semantic Repository protocol where method names directly reflect business intent rather than technical implementation details. The `asSingle` generic method in protocol extensions can convert arbitrary async operations to RxSwift Single, improving code reusability. MarketsRepository implementation uses strategy pattern to select different data sources based on NetworkProviderType and is responsible for converting raw data to business objects.

### **5. Thorough UseCase Layer Refactoring**

**Before and After Comparison:**
The original UseCase contained lots of hardcoded file reading and parsing logic with serious code duplication. The refactored implementation receives MarketsRepositoryProtocol through dependency injection, UseCase only focuses on business logic, and error handling logic is uniformly pushed down to the Repository layer.

### **6. Test Infrastructure Establishment**

**Comprehensive Test Coverage:**
I created comprehensive unit tests for each component. The test architecture includes Mock object support, RxTest integration for precise control of async operation timing, and coverage of various boundary conditions and exception scenarios.

## **Deep Rationale for Architecture Decisions**

**Repository Pattern Choice:** Achieved separation of concerns by separating data access logic from business logic, improved testability by easily replacing with Mock implementations, enhanced extensibility where adding new data sources doesn't require modifying business logic, and reserved space for future caching strategies.

**Dual API Support Strategy:** Supports progressive migration allowing existing RxSwift code to transition smoothly, adapts to different technical preferences among team developers, leverages respective advantages in different scenarios - async/await has better performance while RxSwift is more powerful in complex data flow processing.

---

### Optimize FeatureFlagProvider with thread safety and protocol improvements

**Changes I made:**
Next I refactored FeatureFlagProvider, mainly making several changes. First I created FeatureFlagProviderProtocol protocol defining some methods. Then I made FeatureFlagProvider implement this protocol and added NSLock to ensure thread safety, using NSLock and defer unlock in both getValue and update methods to protect data access. I also added distinctUntilChanged() in the observeFlagValue method to avoid duplicate event emissions and improve performance.

**Rationale behind implementation decisions:**
The original implementation had several serious problems. First was lack of protocol abstraction, making unit testing difficult and unable to easily create mock objects. Second was thread safety issues that could cause data races in multi-threaded environments. Adding distinctUntilChanged() was a performance optimization decision to avoid unnecessary UI updates. Making flagsRelay private was to ensure encapsulation - external code can only access feature flags through defined interfaces, better controlling data consistency and integrity.

---

### Refactor USDPriceUseCase and AllPriceUseCase into MarketsPriceUseCase

**Changes I made:**
Then I started refactoring UseCases. I deleted USDPriceUseCase.swift and AllPriceUseCase.swift files and created a new MarketsPriceUseCase.swift to uniformly handle all price-related business logic.

**Rationale behind implementation decisions:**
I found that the original USDPriceUseCase and AllPriceUseCase were almost identical, only calling different repository methods, violating the DRY principle. The original design required registering two different UseCases in the dependency injection container, and consumers needed to know which UseCase to use, increasing cognitive burden. By unifying into one MarketsPriceUseCase, I achieved several important improvements: first, simplified the dependency graph - now only need to register one protocol implementation; second, improved code cohesion with all price-related business logic centralized in one place; third, reduced testing complexity - now only need to maintain one test file.

---

### Implement SwiftUI crypto list with reactive search

**Changes I made:**
Since the architecture layer was optimized well enough, I started working on business implementation. First I renamed SwiftUIListViewController.swift because it didn't conform to SwiftUI naming conventions, and created three brand new SwiftUI files to build a fully functional cryptocurrency list interface. CryptoListView.swift is the main view containing search box, loading state indicator, list, and error message display. CryptoListItemView.swift is the individual list item component supporting cryptocurrency name display, USD/EUR prices, and tag display functionality. Added functionality where tags are sorted alphabetically and displayed as small tags with blue background (because I saw this field in the json file ^_^), and includes 4 different SwiftUI Previews to show various display states. CryptoListViewModel.swift is the core ViewModel implementing complex reactive logic: uses @Published properties to manage UI state, handles search text changes through RxSwift's BehaviorRelay, uses Driver pattern to listen for feature flag changes and automatically switch data sources (USD-only or USD+EUR), and implements search filtering functionality and alphabetical tag sorting logic. Extended NumberFormatter adding thread-safe formatter, intelligent precision control, multi-currency support, and performance-optimized caching mechanism. Also wrote related Unit Tests.

**Rationale behind implementation decisions:**
The original SwiftUIListViewController was just a simple list display lacking basic features like search, loading states, error handling. My redesigned architecture solved several key problems: First, completeness of user experience - the new interface includes loading states, error handling, search functionality and other essential features of modern applications. Second, elegant handling of reactive data flow - through RxSwift's Driver pattern, when users switch feature flags, the interface automatically reloads corresponding data sources without manual refresh. Third, componentized design - CryptoListItemView is designed as a reusable component supporting multiple display states with good development experience through SwiftUI Preview.

The original CryptoFormatter only had basic formatting functionality with simple code structure:
- Only one `format(value:decimalPlaces:)` method
- Used fixed en_US locale
- No thread safety protection  
- No currency formatting support

Then I significantly transformed CryptoFormatter.
I added a dedicated serial queue `formatterQueue` to protect all formatting operations, because CryptoFormatter is not thread-safe and could have race conditions in multi-threaded environments. Through `DispatchQueue.sync` ensures all formatting operations execute serially in the same queue.

Next I implemented dynamic precision adjustment based on value ranges: for prices greater than 1, display 2 decimal places; for prices between 0.01-1, display 2-4 decimal places; for prices less than 0.01, display up to 8 decimal places. This ensures cryptocurrencies of different value ranges can display with appropriate precision, neither losing important information nor showing too many meaningless zeros. (I remember digital currencies should be done this way, not entirely sure ^ ^)

Then I used lazy var to create three cached formatter instances (usdFormatter, eurFormatter, decimalFormatter), avoiding performance overhead of repeatedly creating NumberFormatter objects. Each formatter is pre-configured with corresponding currency code, locale, and rounding mode.

Then used CurrencyType enum to support different currency types, each currency has its own code, locale, and fallback value. This design makes adding new currency types very simple.

Each formatting method provides fallback values, ensuring that when formatting fails, it won't return nil or crash, but displays reasonable default values like "$0.00" or "€0.00".

---

### Refactor improve SettingViewModel safety and enhance UI with comprehensive tests

**Changes I made:**
Started refactoring the settings page! I renamed SettingViewController.swift. The original interface only had a simple Toggle control. My redesigned SettingView uses complete SwiftUI Form structure: includes detailed title and description text, footer explanation text. I renamed the original SettingModel to SettingViewModel to conform to naming conventions. Most importantly, removed dangerous force unwrapping operations, changed to use guard let and fatalError to ensure dependency injection safety. Added Unit Tests.

**Rationale behind implementation decisions:**
This refactoring solved code safety issues: the original use of force unwrapping `Dependency.shared.resolve(FeatureFlagProviderProtocol.self)!` was very dangerous - if dependencies weren't properly registered, the app would crash directly without meaningful error messages. I changed to use guard let and fatalError combination, not only maintaining the Fail Fast principle but also providing clear error messages to help developers quickly locate problems. Third was test coverage issue: originally had no tests, I created comprehensive unit tests including normal initialization, dependency injection failure, feature flag reading and setting scenarios. MockFeatureFlagProvider implementation makes tests controllable and repeatable.

---

### Feat implement Coordinator pattern with SwiftUI navigation architecture

**Changes I made:**
Then I started working on detailView. Because it's UIKit and SwiftUI mixed programming, navigation had some issues, so I thoroughly refactored the app's navigation architecture, implementing complete Coordinator pattern. First I modified SceneDelegate.swift, removed original hardcoded tab page creation logic, changed to use AppCoordinator to manage entire app startup and navigation. I created three Coordinators: AppCoordinator as root coordinator managing UITabBarController and two child coordinators; CryptoListCoordinator managing cryptocurrency list navigation flow, including showDetail method to handle navigation to detail pages; SettingsCoordinator managing settings page navigation. I modified CryptoListView, removed NavigationView wrapper (because now managed by UINavigationController), added coordinator property and tap gesture to trigger navigation, and used contentShape to increase tap area (Apple's recommended practice). I created complete detail page functionality: DetailView displays cryptocurrency detailed information, DetailViewModel monitors feature flag changes through RxSwift to dynamically update price display format. I also created comprehensive tests for new components: AppCoordinatorTests and DetailViewModelTests, ensuring correctness of navigation logic and business logic.

**Rationale behind implementation decisions:**
This refactoring solved several fundamental problems of the original architecture. First was navigation logic coupling issue: the original SceneDelegate directly created and configured all pages, violating single responsibility principle - when needing to modify navigation flow, SceneDelegate had to be modified. By introducing Coordinator pattern, I separated navigation logic from app startup logic, each Coordinator only responsible for navigation management in its own domain. Second was SwiftUI navigation complexity issue: SwiftUI's NavigationView has some limitations in complex navigation scenarios, especially integration with UITabBarController. We adopted SwiftUI + UIKit hybrid architecture: using UIKit's UITabBarController and UINavigationController to manage navigation containers, using SwiftUI to build page content, maintaining both navigation stability and flexibility while enjoying SwiftUI's development efficiency. Third was testability issue: original navigation logic was scattered everywhere, very difficult to unit test. Now each Coordinator can be tested independently, I can verify navigation logic correctness without starting the entire UI. DetailViewModel's design reflects reactive programming advantages: when users switch feature flags in settings page, already opened detail pages automatically update price display format, this real-time response provides better user experience. The greatest value of this architecture is its extensibility: when needing to add new pages or modify navigation flow, only need to modify corresponding Coordinator without touching other components.

---

### Refactor Model.swift with a protocol to unify interfaces

**Changes I made:**
Noticed that `USDPrice.Price` and `AllPrice.Price` looked pretty similar, so I created a `CryptoPriceItem` protocol for them to implement - now they have a unified interface. Also cleaned up the `Tag` enum by removing those hardcoded strings (Swift can figure them out automatically) and added `CaseIterable`. Threw in some convenience properties like `tagStrings` and direct price access with `usd`, `eur` properties.

**Rationale behind implementation decisions:**
The original code had duplication - two price structs that were very similar but no shared interface, plus unnecessary hardcoding in the enum. Using a protocol to unify the interface makes the code more reusable, and it's fully backward compatible so won't break existing stuff.

---
