import Foundation
import simd


extension SIMD3 where Scalar == Float {

    func distance() -> Float {
        simd_length(self)
    }
    
    func isEmpty() -> Bool {
        self == [0, 0, 0]
    }
    func sum() -> Float {
        return x + y + z
    }
    
    func reduceVector(by lengthToReduce: Float) -> SIMD3<Float> {
        let length = simd_length(self)
        guard length > lengthToReduce else {
            return SIMD3<Float>(0, 0, 0)
        }
        let newLength = length - lengthToReduce
        let normalizedVector = simd_normalize(self)
        return normalizedVector * newLength
    }
}

