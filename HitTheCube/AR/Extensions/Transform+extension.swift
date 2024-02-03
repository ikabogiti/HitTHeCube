import Foundation
import RealityKit

extension Transform {
    public func yAngleFromSinCos()  -> Float {
        return self.matrix.yAngleFromSinCos()
    }

    public  func xAngleFromSinCos() -> Float {
        return self.matrix.xAngleFromSinCos()
    }
    
    public  func zAngleFromSinCos() -> Float {
        return self.matrix.zAngleFromSinCos()
    }

}
