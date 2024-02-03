import Foundation
import RealityKit
import UIKit

struct CubeComponent: Component {
    let target: Entity
    var health: Int = 1
    var color: UIColor {
        switch type {
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        }
    }
    
    var damage: Int {
        switch type {
        case .red:
            return 3
        case .blue:
            return 2
        case .green:
            return 1
        }
    }
    
    init(target: Entity) {
        self.target = target
        self.type = [.red, .green, .blue].randomElement()!
    }
    
    private enum CubeType {
        case red
        case blue
        case green
    }
    
    private let type: CubeType
}

class CubeSystem: System {
        
    required init(scene: Scene) {}
    
    private static let query = EntityQuery(where: .has(CubeComponent.self) && .has(CubeAnimationComponent.self))
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let cubeAnimationComponent = entity.getComponent(CubeAnimationComponent.self) else {
                fatalError()
            }
            guard !cubeAnimationComponent.isDestroy else {
                return
            }
            
            guard let anchor = entity.anchor else {
                fatalError()
            }
            guard let cubeComponent = entity.getComponent(CubeComponent.self) else {
                fatalError()
            }

            let target = cubeComponent.target
            let targetPosition = cubeComponent.target.position(relativeTo: nil)
            let position = anchor.transformMatrix(relativeTo: nil).transform.translation
            
            if cubeComponent.health <= 0 && !cubeAnimationComponent.isDestroy {
                entity.components[CubeAnimationComponent.self] = CubeAnimationComponent(currentAnimation: .destroy(start: Date()))
            }
            let speed = 0.7
            let deltaTime = context.deltaTime
            let distance = Float(speed * deltaTime)
            
            anchor.look(at: targetPosition, from: position, relativeTo: nil)
            let newPosition = anchor.transformMatrix(relativeTo: target).transform.translation.reduceVector(by: distance)
            anchor.setPosition(newPosition, relativeTo: target)
        }
    }
    
}
