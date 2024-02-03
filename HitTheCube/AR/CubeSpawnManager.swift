import RealityKit

class CubeSpawnManager {
    
    init(arView: ARView, target: Entity) {
        self.arView = arView
        self.target = target
    }
    
    func spawn() -> Entity? {
        let cube = makeCube()
        let position = arView.getRandomPositionInFOV(minDistance: 1, maxDistance: 5)
        guard let position else {
            return nil
        }
        let anchor = AnchorEntity(world: position)
        anchor.addChild(cube)
        arView.scene.addAnchor(anchor)
        return cube
    }
    
    private func makeCube() -> ModelEntity {
        let size: Float = 0.2
        let cubeComponent = CubeComponent(target: target)
        let cube = ModelEntity(mesh: .generateBox(size: size), materials: [UnlitMaterial(color: cubeComponent.color)])
        cube.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateBox(size: [size, size, size])],
            mode: .trigger,
            filter: CollisionFilter(group: .cube, mask: .player.union(.playerShell))
        )
        cube.components.set(CubeAnimationComponent(currentAnimation: nil))
        cube.components.set(cubeComponent)
        cube.name = "Cube"
        return cube
    }
    
    private let arView: ARView
    private let target: Entity
}

