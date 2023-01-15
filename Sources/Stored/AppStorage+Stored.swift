//
//  AppStorage+Stored.swift
//
//  Created by Joshua Mathes on 1/15/23.
//

import SwiftUI


@available(iOS 14.0, *)
@available(macOS 11.0, *)
extension AppStorage {
  init(wrappedValue: Value, _ s: Stored<Value>) where Value == Bool {
    self.init(wrappedValue: wrappedValue, s.key, store: s.store)
  }

  init(wrappedValue: Value, _ s: Stored<Value>) where Value == Int {
    self.init(wrappedValue: wrappedValue, s.key, store: s.store)
  }

  init(wrappedValue: Value, _ s: Stored<Value>) where Value == Double {
    self.init(wrappedValue: wrappedValue, s.key, store: s.store)
  }

  init(wrappedValue: Value, _ s: Stored<Value>) where Value == URL {
    self.init(wrappedValue: wrappedValue, s.key, store: s.store)
  }

  init(wrappedValue: Value, _ s: Stored<Value>) where Value == String {
    self.init(wrappedValue: wrappedValue, s.key, store: s.store)
  }

  init(wrappedValue: Value, _ s: Stored<Value>) where Value == Data {
    self.init(wrappedValue: wrappedValue, s.key, store: s.store)
  }
}
