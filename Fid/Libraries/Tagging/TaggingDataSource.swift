public protocol TaggingDataSource: class {
//    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [ObjectUser])
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel])
}

public extension TaggingDataSource {
//    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [ObjectUser]) {return}
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel]) {return}
}
