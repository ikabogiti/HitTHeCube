import ARKit
import Combine

final class ARSessionDelegateAdapter: NSObject, ARSessionDelegate {
    
    let didUpdateFramePublisher = PassthroughSubject<(session: ARSession, frame: ARFrame), Never>()
    
    let didAddAnchorsPublisher = PassthroughSubject<(session: ARSession, anchors: [ARAnchor]), Never>()
    
    let didUpdateAnchorsPublisher = PassthroughSubject<(session: ARSession, anchors: [ARAnchor]), Never>()
    
    let didRemoverAnchorsPublisher = PassthroughSubject<(session: ARSession, anchors: [ARAnchor]), Never>()
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        didUpdateFramePublisher.send((session, frame))
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        didAddAnchorsPublisher.send((session, anchors))
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        didUpdateAnchorsPublisher.send((session, anchors))
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        didRemoverAnchorsPublisher.send((session, anchors))
    }

}
