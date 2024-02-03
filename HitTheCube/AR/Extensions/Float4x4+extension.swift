import Foundation
import RealityKit

extension float4x4 {
    
    var transform: Transform {
        Transform(matrix: self)
    }
    
    public func yAngleFromSinCos()  -> Float {
        let sin = self[0][2]
        let cos = self[0][0]
        return angleFrom(sin: sin, cos: cos)
    }
    
    public func xAngleFromSinCos() -> Float {
        let sin = self[2][1]
        let cos = self[1][1]
        return  angleFrom(sin: sin, cos: cos)
    }
    
    public func zAngleFromSinCos() -> Float {
        let sin = self[1][0]
        let cos = self[0][0]
        return angleFrom(sin: sin, cos: cos)
    }
    
    private func angleFrom(sin: Float, cos: Float) -> Float {
        var angleFromCos: Float = acos(cos).isNaN ? 0 : acos(cos)
        var angleFromSin: Float = asin(sin).isNaN ? 0 : asin(sin)
        let poweredSinus = pow(sin, 2)
        if sin < 0 {
            angleFromCos *= -1
            if cos < 0 {
                angleFromSin = -.pi - angleFromSin
            }
        } else if cos < 0 {
            angleFromSin = .pi - angleFromSin
        }
        var angle = ((1.0 - poweredSinus) * angleFromSin + poweredSinus * angleFromCos)
        if angle < 0 {
            angle *= -1
        } else if angle > 0 {
            angle = Float.pi * 2 - angle
        }
        if angle > .pi {
            angle = (angle + (-2 * .pi)).magnitude
        } else {
            angle *= -1
        }
        return angle * -1
    }
}
