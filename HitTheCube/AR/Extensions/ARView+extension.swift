import Foundation
import RealityKit
import UIKit

extension ARView {
    
    func addBox(to positon: SIMD3<Float>, size: Float = 0.3, color: UIColor = .red) {
        let anchor = AnchorEntity(world: positon)
        let model = ModelEntity(mesh: .generateBox(size: size), materials: [SimpleMaterial(color: color, isMetallic: false)])
        anchor.addChild(model)
        self.scene.addAnchor(anchor)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            anchor.removeFromParent()
        }
    }
    
    func getRandomPositionInFOV(minDistance: Float, maxDistance: Float) -> SIMD3<Float>? {
        guard let cameraTransform = self.getCameraTransform() else {
            return nil
        }
        guard minDistance < maxDistance else {
            return nil
        }
        let yAngle = cameraTransform.yAngleFromSinCos()
        let yQuat = simd_quatf(angle: yAngle, axis: [0, 1, 0])
        let direction = yQuat.act(SIMD3<Float>(x: 0, y: 0, z: -1))
        let raycast = self.scene.raycast(
            origin: cameraTransform.translation,
            direction: direction,
            mask: .all.subtracting(.player)
        )
        var distance = raycast.first?.distance ?? maxDistance
        distance = distance > maxDistance ? maxDistance : distance
        guard distance >= minDistance else {
            return nil
        }
        
        
        for _ in 0...4 {
            let position = yQuat.act(getRandomPosition(in: minDistance...maxDistance))
            let positionForReturn = position + cameraTransform.translation
            let isVisivle = checkForVisibility(position: positionForReturn)
            if isVisivle {
                return positionForReturn
            }
        }
        return nil

    }

    private func getRandomPosition(in depthRange: ClosedRange<Float>) -> SIMD3<Float> {
        let z = Float.random(in: (-depthRange.upperBound)...(-depthRange.lowerBound))
        let y = Float.random(in: -0.5...0.5)
        let x = Float.random(in: (-depthRange.lowerBound / 2)...(depthRange.lowerBound / 2))
        return [x, y, z]
    }
    
    func checkForVisibility(position: SIMD3<Float>) -> Bool {
        guard let cameraTransform = self.getCameraTransform() else {
            return false
        }
        let playerPosition = cameraTransform.translation
        let rcResult = scene.raycast(
            from: playerPosition,
            to: position,
            query: .nearest,
            mask: .all.subtracting(.player),
            relativeTo: nil
        )
        guard let firstReslut = rcResult.first else {
            return true
        }
        
        let relativeVector = playerPosition - position

        let isEnoghDistance = relativeVector.distance() < firstReslut.distance
        return isEnoghDistance

    }
    
    func checkForVisibility(entity: Entity) -> Bool {
        guard let cameraPosition = self.getCameraTransform()?.translation else {
            return false
        }

        let raycast = self.scene.raycast(
            from: cameraPosition,
            to: entity.position,
            query: .nearest,
            mask: .all.subtracting(.player),
            relativeTo: nil
        )
        
        guard let rcResult = raycast.first else {
            return false
        }
        
        let isVisible = rcResult.entity.id == entity.id
        return isVisible
    }
        
    func getCameraTransform() -> Transform? {
        guard let cameraTransform = self.session.currentFrame?.camera.transform else {
            return nil
        }
        var transform = Transform(matrix: cameraTransform)
        transform.rotation *= simd_quatf(angle: .pi / 2, axis: [0, 0, 1])
        return transform
    }

    func isItInFov(position: SIMD3<Float>) -> Bool? {
        guard let cameraTransform = getCameraTransform() else {
            return nil
        }
        let cameraRotation = cameraTransform.rotation
        let relativeVector = cameraRotation.act(position - cameraTransform.translation)
        let inFov = relativeVector.z < 0
        return inFov
    }

    func getFov() -> SIMD2<Float>? {
        guard let currentFrame = self.session.currentFrame else {
            return nil
        }
        let projectionMatrix = currentFrame.camera.projectionMatrix
        let yScale = projectionMatrix[1, 1]
        let yFov = 2 * atan(1/yScale) // радианы
        let imageResolution = currentFrame.camera.imageResolution
        let xFov = yFov * Float(imageResolution.width / imageResolution.height)
        return [xFov, yFov]
    }
}
