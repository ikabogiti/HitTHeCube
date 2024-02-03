import Combine
import Foundation
import RealityKit

class GameManager {
    
    public let playerHealthPublisher = CurrentValueSubject<Int, Never>(0)
    public let timePublisher = CurrentValueSubject<TimeInterval, Never>(0)
    public let shootBlobPublisher = CurrentValueSubject<Int, Never>(0)
    public let cubeSpawnedPublisher = CurrentValueSubject<Int, Never>(0)
    public let gameStatusPublisher = CurrentValueSubject<GameStatus, Never>(.ended)
    
    init(arView: ARView, target: Entity) {
        self.cubeSpawnManager = CubeSpawnManager(arView: arView, target: target)
        self.arView = arView
        self.target = target
    }
    
    func startGame() {
        setupPlayerEntity()
        startDate = Date()
        gameStatusPublisher.send(.started)
        target.components[PlayerComponent.self] = PlayerComponent(health: 10)
        playerHealthPublisher.send(10)
        timePublisher.send(0)
        shootBlobPublisher.send(0)
        gameStatusPublisher.send(.started)
    }
    
    func spawn() {
        guard gameIsActive else {
            return
        }
        timePublisher.send(Date().timeIntervalSince(startDate!))
        cleanOldest()
        guard canSpawn() else {
            return
        }
        guard let cube = cubeSpawnManager.spawn() else {
            return
        }
        cubes[cube] = Date()
        cubeSpawnedPublisher.send(cubeSpawnedPublisher.value + 1)
        subscribeToCollision(on: cube)
    }
    
    func didShoot() {
        shootBlobPublisher.send(shootBlobPublisher.value + 1)
    }
    
    private func canSpawn() -> Bool {
        return cubes.count < 10
    }
    
    private func cleanOldest() {
        guard cubes.count >= 10 else {
            return
        }
        let toRemove = Set(cubes.filter { Date().timeIntervalSince($0.value) > 10 }.keys)
        let animationStarted = Set(cubes.keys.filter { ($0.components[CubeAnimationComponent.self] as? CubeAnimationComponent)?.isDestroy ?? false })
        toRemove.subtracting(animationStarted).forEach {
            $0.components[CubeAnimationComponent.self] = CubeAnimationComponent(
                currentAnimation: .destroy(start: Date())
            )
        }
        toRemove.union(animationStarted).forEach { cubes[$0] = nil }
    }
    
    private func subscribeToCollision(on cube: Entity) {
        arView.scene.subscribe(to: CollisionEvents.Began.self, on: cube) { [weak self] collision in
            guard let self else {
                return
            }
            guard var cubeComponent = collision.entityA.getComponent(CubeComponent.self) else {
                fatalError()
            }
            if var playerComponent = collision.entityB.getComponent(PlayerComponent.self) {
                playerComponent.health -= cubeComponent.damage
                collision.entityB.components[PlayerComponent.self] = playerComponent
                if playerComponent.health <= 0 {
                    self.endGame()
                }
                self.playerHealthPublisher.send(playerComponent.health)
                DispatchQueue.main.async {
                    collision.entityA.anchor?.removeFromParent()
                }
            } else if let blobComponent = collision.entityB.getComponent(BlobComponent.self) {
                collision.entityB.anchor?.removeFromParent()
                cubeComponent.health -= blobComponent.damage
                collision.entityA.components[CubeComponent.self] = cubeComponent
            }
        }
        .storeWhileEntityActive(cube)
    }
    
    private func endGame() {
        self.startDate = nil
        clearScene()
        gameStatusPublisher.send(.ended)
    }
    
    private func clearScene() {
        cubes.keys.forEach { cube in
            DispatchQueue.main.async {
                cube.anchor?.removeFromParent()
            }
        }
        cubes.removeAll()
        currentPlayerEntity?.removeFromParent()
    }
    
    
    private func setupPlayerEntity() {
        let playerEntity = Entity()
        playerEntity.name = "Player"
        playerEntity.components[PlayerComponent.self] = PlayerComponent(health: 10)
        playerEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateSphere(radius: 0.1)], filter: .init(group: .player, mask: .cube))
        target.addChild(playerEntity)
        currentPlayerEntity = playerEntity
    }

    private let cubeSpawnManager: CubeSpawnManager
    private let arView: ARView
    private let target: Entity
    private var cubes: [Entity: Date] = [:]
    private var startDate: Date?
    private var gameIsActive: Bool { startDate != nil }
    private var currentPlayerEntity: Entity?
    
    enum GameStatus {
        case started
        case ended
    }
}
