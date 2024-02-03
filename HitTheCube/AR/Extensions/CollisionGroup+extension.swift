import RealityKit

extension CollisionGroup {
    static let player = CollisionGroup(rawValue: playerColliderMask)
    static let playerShell = CollisionGroup(rawValue: playerShellMask)
    static let cube = CollisionGroup(rawValue: cubeMask)
}

private let playerColliderMask: UInt32 = 1
private let playerShellMask: UInt32 = 1 << 1
private let cubeMask: UInt32 = 1 << 3
