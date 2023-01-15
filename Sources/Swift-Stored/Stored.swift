//
//  Stored.swift
//
//  Created by Joshua Mathes on 1/14/23.
//

// With contributions from the following:
// https://www.vadimbulavin.com/advanced-guide-to-userdefaults-in-swift/
// https://www.swiftbysundell.com/articles/property-wrappers-in-swift/


import Foundation
import SwiftUI


@available(macOS 10.15, *)
@propertyWrapper
class Stored<AnyType>: NSObject {

  init(
    wrappedValue defaultValue: AnyType,
    _ key: String,
    storage: UserDefaults = .standard,
    onChange: @escaping (AnyType, AnyType) -> Void = { (oldValue, newValue) in }
  ) {
    self.defaultValue = defaultValue
    self.key = key
    self.storage = storage
    self.onChange = onChange

    super.init()
    storage.addObserver(self, forKeyPath: key, options: [.old, .new], context: nil)
  }


  let key: String
  private let defaultValue: AnyType
  let storage: UserDefaults
  private let onChange: (AnyType, AnyType) -> Void


  var wrappedValue: AnyType {
    get {
      let value = storage.value(forKey: key) as? AnyType
      return value ?? defaultValue
    }
    set {
      if let optional = newValue as? AnyOptional, optional.isNil {
        storage.removeObject(forKey: key)
      } else {
        storage.setValue(newValue, forKey: key)
      }
    }
  }


  // Observes the UserDefault and fires the onChange() function if it changes in the background.
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard let change = change, object != nil, keyPath == key else { return }
    if let oldValue: AnyType = change[.oldKey] as? AnyType, let newValue: AnyType = change[.newKey] as? AnyType {
      onChange(oldValue, newValue)
    }
  }


  deinit {
    self.storage.removeObserver(self, forKeyPath: key, context: nil)
  }


  lazy var projectedValue: Binding<AnyType> = {
    Binding(
      get: {
        self.wrappedValue
      }, set: { newValue in
        self.wrappedValue = newValue
      })
  }()


  //  override var description: String {
  //    return "\(key): \(wrappedValue)"
  //  }

}



// MARK: Enables optional values.

@available(macOS 10.15, *)
extension Stored where AnyType: ExpressibleByNilLiteral {
  convenience init(
    _ key: String,
    storage: UserDefaults = .standard,
    onChange: @escaping (AnyType, AnyType) -> Void = { (oldValue, newValue) in }
  ) {
    self.init(wrappedValue: nil, key, storage: storage, onChange: onChange)
  }
}


private protocol AnyOptional {
  var isNil: Bool { get }
}


extension Optional: AnyOptional {
  var isNil: Bool { self == nil }
}

