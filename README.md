# Swift-Stored
A simple interface for UserDefaults that allows for observing and reacting to changes to the value. Compatible with SwiftUI.

### Implementation

**Example 1.** Most simple usage, storing in UserDefaults.standard by default.

```
// Implementation
final class LocalStorage: ObservableObject {

  @Stored("hapticFeedbackEnabled") static var hapticsEnabled: Bool = false

}

// Utilization
// The "static var" allows us to use this as a singleton value.
LocalStorage.hapticsEnabled = true
```


**Example 2.** Most elaborate usage. Stores in a custom UserDefaults, and runs a custom function when a change in value is detected.
```
// Implementation
final class LocalStorage: ObservableObject {

  private static var syncService: UserDefaults { UserDefaults(suiteName: "syncServicePrefs")! }

  @Stored("syncEnable", storage: LocalStorage.syncService, onChange: { _, newValue in
    
    // Observe the change.
    print("Sync \(value ? "enabled" : "disabled").")
    
    // Act upon the change.
    if newValue == true {
      synchronize()
      // ...
    }
    
  }) static var sync: Bool = false
  
}

// Utilization in a practical use case.
struct SettingsView: View {
  var body: some View {
    Toggle(isOn: LocalStorage.$sync) { Text("Synchronize Data") }
  }
}

// Alternate utilization. The onChange() function will fire when this runs.
UserDefaults(syncServicePrefs)?.set(true, forKey: "syncEnable")
```


**Example 3.** An alternate method of initializing a propertyWrapper that may feel more familiar.
```
// Implementation
final class LocalStorage: ObservableObject {

  var mark: Stored<Bool> = Stored(true, key: "mark", storage: .standard, onChange: {_,_ in })
  
}
```

## Notes
<details>
  <summary>The onChange only triggers on a successful change, not just an attempted one.</summary>

  ```
  final class LocalStorage: ObservableObject {
    @Stored("mark", onChange: { _, value in
      print("result: \(value)")
    }) static var mark: Bool = false
  }

  UserDefaults.standard.set(false, forKey: "mark")
  UserDefaults.standard.set(false, forKey: "mark")
  UserDefaults.standard.set(true, forKey: "mark")

  // (nothing happens)
  // (nothing happens)
  // result: true
  ```
  
</details>
