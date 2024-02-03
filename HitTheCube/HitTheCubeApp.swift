import SwiftUI
import SwiftData

@main
struct HitTheCubeApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    CubeAnimationSystem.registerSystem()
                    CubeAnimationComponent.registerComponent()
                    CubeComponent.registerComponent()
                    CubeSystem.registerSystem()
                    PlayerComponent.registerComponent()
                }
        }
    }
}
