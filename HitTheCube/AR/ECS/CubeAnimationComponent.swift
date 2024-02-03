import Foundation
import RealityKit
import UIKit

struct CubeAnimationComponent: Component {
    
    let currentAnimation: Animation?
    
    var isDestroy: Bool {
        if case .destroy(_) = currentAnimation {
            return true
        } else {
            return false
        }
    }
    
    enum Animation {
        case destroy(start: Date)
    }
}

class CubeAnimationSystem: System {
    
    private static let query: EntityQuery = .init(where: .has(CubeAnimationComponent.self) && .has(CubeComponent.self))
    
    static var dependencies: [SystemDependency] = [.after(CubeSystem.self)]
    
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let cube = entity as? ModelEntity else {
                fatalError()
            }
            guard let animationComponent = cube.getComponent(CubeAnimationComponent.self) else {
                fatalError()
            }
            guard let cubeComponent = cube.getComponent(CubeComponent.self) else {
                fatalError()
            }
            guard let currentAnimation = animationComponent.currentAnimation else {
                return
            }
            switch currentAnimation {
            case .destroy(let startDate):
                makeDestroyAnimation(for: cube, color: cubeComponent.color, startDate: startDate)
            }
        }
    }
    
    func makeDestroyAnimation(for cube: ModelEntity, color: UIColor, startDate: Date) {
        let timeSinceStarted = Date().timeIntervalSince(startDate)
        let animationDuration = 0.3
        guard timeSinceStarted < animationDuration else {
            cube.anchor?.removeFromParent()
            return
        }
        cube.model?.materials = [UnlitMaterial(color: color.withAlphaComponent(animationDuration - timeSinceStarted))]
    }
}
