import Combine
import RealityKit

class CubeSpawnManager {
    
    init(arView: ARView, target: Entity) {
        self.arView = arView
        self.target = target
        cancellable = ModelEntity.loadModelAsync(named: "pumpkin.usdz")
            .sink { error in
                print(error)
            } receiveValue: { [weak self] model in
                model.transform.rotation = simd_quatf(
                    angle: .pi / 2, axis: [0, 1, 0]
                )
                model.generateCollisionShapes(recursive: true)
                model.collision?.mode = .trigger
                model.collision?.filter = CollisionFilter(
                    group: .cube,
                    mask: .player.union(.playerShell)
                )
                self?.model = model
            }

    }
    
    func spawn() -> Entity? {
        guard let cube = makeCube() else {
            return nil
        }
        let position = arView.getRandomPositionInFOV(minDistance: 1, maxDistance: 5)
        guard let position else {
            return nil
        }
        let anchor = AnchorEntity(world: position)
        anchor.addChild(cube)
        arView.scene.addAnchor(anchor)
        return cube
    }
    
    private func makeCube() -> ModelEntity?{
        guard let model else {
            return nil
        }
        let cubeComponent = CubeComponent(target: target)
        let cube = model.clone(recursive: true)
        cube.components.set(CubeAnimationComponent(currentAnimation: nil))
        cube.components.set(cubeComponent)
        cube.name = "Cube"
        return cube
    }
    
    private let arView: ARView
    private let target: Entity
    private var model: ModelEntity?
    private var cancellable: AnyCancellable?
}
