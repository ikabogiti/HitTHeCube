import ARKit
import Combine
import RealityKit

class GameCoordinator {
    
    lazy var shootManager = ShootManager(arView: arView)
    
    let arView: ARView
    
    let sessionDelegateAdapter = ARSessionDelegateAdapter()
    
    lazy var gameManager = GameManager(arView: arView, target: playerAnchor)
    
    var cancellables: Set<AnyCancellable> = []
    
    let playerAnchor = AnchorEntity(.camera)
    
    init(arView: ARView = ARView()) {
        self.arView = arView
        self.arView.session.delegate = sessionDelegateAdapter
        startupActions()
        setupPipelines()
        gameManager.startGame()
    }
    
    func startGame() {
        gameManager.startGame()
    }

    private func startupActions()  {
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.worldAlignment = .gravity
        configuration.frameSemantics = .personSegmentationWithDepth
        arView.environment.sceneUnderstanding.options.insert([.collision, .physics])
        #if DEBUG
        self.arView.debugOptions.insert(
            [.showSceneUnderstanding, .showWorldOrigin, .showFeaturePoints]
        )
        #endif
        self.arView.session.run(configuration)
        arView.scene.addAnchor(playerAnchor)
    }
    
    private func setupPipelines() {
        sessionDelegateAdapter.didUpdateFramePublisher
            .throttle(for: .seconds(0.5), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                gameManager.spawn()
            }
            .store(in: &cancellables)
    }
    
    func shoot() {
        shootManager.shoot()
        gameManager.didShoot()
    }
}
