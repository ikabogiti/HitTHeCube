import SwiftUI
import SwiftData
import UIKit
import RealityKit

class ContentViewModel: ObservableObject {
    
    let coordinator = GameCoordinator()
    
    @Published var time: Int = 0
    @Published var heath: Int = 0
    @Published var gameStatus: GameManager.GameStatus = .ended
    @Published var blobShot: Int = 0
    @Published var cubeSpawned: Int = 0
    
    
    init() {
        coordinator.gameManager.cubeSpawnedPublisher
            .assign(to: &$cubeSpawned)
        
        coordinator.gameManager.shootBlobPublisher
            .assign(to: &$blobShot)
        
        coordinator.gameManager.timePublisher
            .map { Int($0) }
            .assign(to: &$time)
        
        coordinator.gameManager.playerHealthPublisher
            .assign(to: &$heath)

        coordinator.gameManager.gameStatusPublisher
            .assign(to: &$gameStatus)
    }
    
    func buttonTapped() {
        if gameStatus == .ended {
            coordinator.startGame()
        } else {
            coordinator.shoot()
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var buttonText: String {
        if viewModel.gameStatus == .ended {
            return "Start"
        } else {
            return "Shoot"
        }
    }
    
    var body: some View {
        ZStack {
            ARViewRepresentable(coordinator: viewModel.coordinator)
            VStack {
                HStack {
                    VStack {
                        Text("Health: \(viewModel.heath)")
                        Text("Blob Shot: \(viewModel.blobShot)")
                    }
                    Spacer()
                    VStack {
                        Text("Cube Spawned: \(viewModel.cubeSpawned)")
                    }
                }
                .overlay(
                    Text(String(viewModel.time))
                )
                Spacer()
                Button {
                    viewModel.buttonTapped()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
                        Text(buttonText)
                            .foregroundColor(.white)
                    }
                    .frame(width: 150, height: 75)
                }
            }
        }
    }

}

struct ARViewRepresentable: UIViewRepresentable {
    
    typealias Coordinator = GameCoordinator
    
    let coordinator: GameCoordinator
    
    init(coordinator: GameCoordinator) {
        self.coordinator = coordinator
    }
    
    func makeUIView(context: Context) -> UIView {
#if !targetEnvironment(simulator)
        return context.coordinator.arView
#else
        let view = UIView()
        view.backgroundColor = .green.withAlphaComponent(0.5)
        return view
#endif
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    typealias UIViewType = UIView
    
    func makeCoordinator() -> Coordinator {
        return coordinator
    }
}

#Preview {
    ContentView()
}

