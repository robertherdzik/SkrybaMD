## Table Of Content

- [1.0 General](#10-general)
	- [1.1.0 ddd](#110-ddd)
- [2.0 Architecture](#20-architecture)
	- [2.1.0 Our Approach](#210-our-approach)
		- [2.1.1.0 next point](#2110-next-point)
		- [2.1.2.0 dfsdf](#2120-dfsdf)
			- [2.1.2.1.0 Our Approach Description](#21210-our-approach-description)
			- [2.1.2.2.0 Why This One](#21220-why-this-one)
			- [2.1.2.3.0 CI and Rest](#21230-ci-and-rest)
- [3.0 Summary](#30-summary)

##  1.0 General
This guide was last updated for Swift 4.2 on January 22, 2019.

###  1.1.0 ddd
This guide was last updated for Swift 4.2 on January 22, 2019.

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
We have choosen this Architecture because is good and because we have choosen this ;p 

####  2.1.1.0 next point
We have choosen this Architecture because is good and because we have choosen this ;p 

####  2.1.2.0 dfsdf
We have choosen this Architecture because is good and because we have choosen this ;p 

####  2.1.2.1.0 Our Approach Description
* Indent using 2 spaces rather than tabs to conserve space and help prevent line wrapping. Be sure to set this preference in Xcode and in the Project settings as shown below:

![Xcode indent settings](screens/indentation.png)

* Method braces and other braces (`if`/`else`/`switch`/`while` etc.) always open on the same line as the statement but close on a new line.
* Tip: You can re-indent by selecting some code (or **Command-A** to select all) and then **Control-I** (or **Editor ▸ Structure ▸ Re-Indent** in the menu). Some of the Xcode template code will have 4-space tabs hard coded, so this is a good way to fix that.

**Preferred**:
```swift
if user.isHappy {
  // Do something
} else {
  // Do something else
}
```

**Not Preferred**:
```swift
if user.isHappy
{
  // Do something
}
else {
  // Do something else
}
```

####  2.1.2.2.0 Why This One
The architecture is the structure and description of a system/enterprise.
It enables the implementation, understanding, maintenance, repair and further development of a system/enterprise. 
The architect describes a system (enterprise) in an architecture in order to enable its usage, fixing, building and further development.
The architect specifies the architecture,  which essentially consists of a set of integrated blueprints,  starting from requirements and past cases.
The designers/engineers though, take over the blueprint from the architect to further design (the parts of) the architecture to the detail necessary for implementation, proper usage, maintenance and further development.
The architecture describes primarily the current system/enterprise.
It may also describe the target system/enterprise in order to visualise its end state.

####  2.1.2.3.0 CI and Rest

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
##  3.0 Summary
I hope that you love our doc generator ❤️
