[![License](https://img.shields.io/cocoapods/l/BadgeSwift.svg?style=flat)](/LICENSE)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat)](https://developer.apple.com/swift)
[![Twitter](https://img.shields.io/twitter/follow/Roherdzik.svg?style=social&label=Follow)](https://twitter.com/Roherdzik)

# SkrybaMD 📝
Simple markdown documentation generator, never again -> git conflicts among the team members which are updating documentation at the same time 💥

# How it works? 

![](./ReadmeAssets/SkrybaMD_flow.png)

# TODO
- [x] create script installation logic (now script need to be build from xcode and copy/paste in the place where source files are located)
- [x] handle as a input of the script name of the Output file
- [ ] create redable README.md file, with installation, how to use, ect...
- [ ] clean up code, move to separate files, change into classes/structures
- [x] create .md anchors from table of content to particular documentation place (see: https://gist.github.com/asabaylus/3071099#file-gistfile1-md)
- [ ] Handle special characters in the Table of Content titles like e.g.: `, ~ ... now probably some of them will break linking mechanism
- [ ] Add "Do not edit directly .md file" footer
- [ ] Unit Tests
- [ ] Move Todo to separate .md file
