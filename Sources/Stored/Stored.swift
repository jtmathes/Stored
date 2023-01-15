//
//  Stored.swift
//
//  Created by Joshua Mathes on 1/14/23.
//

// With contributions from the following:
// https://www.vadimbulavin.com/advanced-guide-to-userdefaults-in-swift/
// https://www.swiftbysundell.com/articles/property-wrappers-in-swift/


import Foundation


@available(iOS 13.0, *)
@available(macOS 10.15, *)
@propertyWrapper
class Stored<AnyType>: NSObject, ObservableObject {

  init(
    wrappedValue defaultValue: AnyType,
    _ key: String,
    store: UserDefaults = .standard,
    onChange: @escaping (AnyType, AnyType) -> Void = { (oldValue, newValue) in }
  ) {
    self.defaultValue = defaultValue
    self.key = key
    self.store = store
    self.onChange = onChange

    super.init()
    store.addObserver(self, forKeyPath: key, options: [.old, .new], context: nil)
  }


  convenience init(
    _ defaultValue: AnyType,
    key: String,
    store: UserDefaults = .standard,
    onChange: @escaping (AnyType, AnyType) -> Void = { (oldValue, newValue) in }
  ) {
    self.init(wrappedValue: defaultValue, key, store: store, onChange: onChange)
  }


  let key: String
  private let defaultValue: AnyType
  let store: UserDefaults
  private let onChange: (AnyType, AnyType) -> Void


  var wrappedValue: AnyType {
    get {
      let value = store.value(forKey: key) as? AnyType
      return value ?? defaultValue
    }
    set {
      if let optional = newValue as? AnyOptional, optional.isNil {
        store.removeObject(forKey: key)
      } else {
        store.setValue(newValue, forKey: key)
      }

    }
  }


  // Observes the UserDefault and fires the onChange() function if it changes in the background.
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard let change = change, object != nil, keyPath == key else { return }
    if let oldValue: AnyType = change[.oldKey] as? AnyType, let newValue: AnyType = change[.newKey] as? AnyType {
      onChange(oldValue, newValue)
      //      print("changed \(Date())")
    }
  }


  var projectedValue: Stored<AnyType> {
    self
  }


  deinit {
    self.store.removeObserver(self, forKeyPath: key, context: nil)
  }

}



// MARK: Enables optional values.

@available(iOS 13.0, *)
@available(macOS 10.15, *)
extension Stored where AnyType: ExpressibleByNilLiteral {
  convenience init(
    _ key: String,
    store: UserDefaults = .standard,
    onChange: @escaping (AnyType, AnyType) -> Void = { (oldValue, newValue) in }
  ) {
    self.init(wrappedValue: nil, key, store: store, onChange: onChange)
  }
}


private protocol AnyOptional {
  var isNil: Bool { get }
}


extension Optional: AnyOptional {
  var isNil: Bool { self == nil }
}
