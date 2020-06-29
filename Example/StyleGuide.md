## Table Of Content

- [1.0 General](#10-general)
- [2.0 Architecture](#20-architecture)
	- [2.1.0 Our Approach](#210-our-approach)
		- [2.1.1.0 CI and Rest](#2110-ci-and-rest)
			- [2.1.1.1.0 Summary](#21110-summary)
	- [2.2.0 Summary](#220-summary)

##  1.0 General

##  2.0 Architecture
Use compiler inferred context to write shorter, clear code.  (Also see [Type Inference](#type-inference).)

**Preferred**:
```swift
let selector = #selector(viewDidLoad)
view.backgroundColor = .red
let toView = context.view(forKey: .to)
let view = UIView(frame: .zero)
```

**Not Preferred**:
```swift
let selector = #selector(ViewController.viewDidLoad)
view.backgroundColor = UIColor.red
let toView = context.view(forKey: UITransitionContextViewKey.to)
let view = UIView(frame: CGRect.zero)
```
###  2.1.0 Our Approach

####  2.1.1.0 CI and Rest

Unused (dead) code, including Xcode template code and placeholder comments should be removed. An exception is when your tutorial or book instructs the user to use the commented code.

Aspirational methods not directly associated with the tutorial whose implementation simply calls the superclass should also be removed. This includes any empty/unused UIApplicationDelegate methods.

**Preferred**:
```swift
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  return Database.contacts.count
}
```

**Not Preferred**:
```swift
override func didReceiveMemoryWarning() {
  super.didReceiveMemoryWarning()
  // Dispose of any resources that can be recreated.
}

override func numberOfSections(in tableView: UITableView) -> Int {
  // #warning Incomplete implementation, return the number of sections
  return 1
}

override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  // #warning Incomplete implementation, return the number of rows
  return Database.contacts.count
}

```
####  2.1.1.1.0 Summary
I hope that you love our doc generator ❤️

####  2.2.0 Summary
I hope that you love our doc generator ❤️
