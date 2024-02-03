import RealityKit

extension Entity {
    
    func getComponent<T: Component>(_ component: T.Type) -> T? {
        components[component] as? T
    }
}
