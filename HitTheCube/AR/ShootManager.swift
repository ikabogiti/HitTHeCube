import Foundation
import RealityKit

class ShootManager {
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    func shoot() {
        let blob = makeBlob()
        let anchor = AnchorEntity(world: arView.getCameraTransform()?.matrix ?? .init())
        blob.position = [0, -0.2, -0.2]
        DispatchQueue.main.async {
            blob.applyLinearImpulse([0, 0, -15], relativeTo: anchor)
        }
        anchor.addChild(blob)
        arView.scene.addAnchor(anchor)
    }
    
    func makeBlob() -> ModelEntity {
        let radius: Float = 0.1
        let blob = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [UnlitMaterial(color: .yellow)]
        )
        let physicBody = PhysicsBodyComponent(massProperties: .init(mass: 1), mode: .dynamic)
        blob.components.set([physicBody, PhysicsMotionComponent()])
        blob.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateSphere(radius: radius)],
            mode: .trigger,
            filter: .init(group: .playerShell, mask: .sceneUnderstanding.union(.cube))
        )
        blob.name = "Blob"
        blob.components[BlobComponent.self] = BlobComponent()
        return blob
    }
    
    private let arView: ARView
}

