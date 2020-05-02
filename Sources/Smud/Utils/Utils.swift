


// See SO post http://stackoverflow.com/questions/1835976/what-is-a-sensible-prime-for-hashcode-calculation
public func combinedHash(_ firstObject: AnyHashable, _ otherObjects: AnyHashable...) -> Int {
    let prime = 92821
    var hash = prime &+ firstObject.hashValue
    for object in otherObjects {
        hash = hash &* prime &+ object.hashValue
    }

    return hash
}
