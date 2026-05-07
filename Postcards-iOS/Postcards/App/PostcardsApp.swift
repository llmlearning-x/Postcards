import SwiftUI
import SwiftData

#if os(iOS)
@main
@MainActor
struct PostcardsApp: App {
    private let useInMemoryStore = ProcessInfo.processInfo.arguments.contains("UITEST_IN_MEMORY_STORE")
    private let modelContainer: ModelContainer

    init() {
        let useInMemoryStore = ProcessInfo.processInfo.arguments.contains("UITEST_IN_MEMORY_STORE")
        self.modelContainer = Self.makeModelContainer(inMemory: useInMemoryStore)
        if !useInMemoryStore {
            MockBackendSeeder.seedIfNeeded(in: modelContainer.mainContext)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }

    private static func makeModelContainer(inMemory: Bool) -> ModelContainer {
        let schema = Schema([Travel.self, Postcard.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create model container: \(error.localizedDescription)")
        }
    }
}
#endif
