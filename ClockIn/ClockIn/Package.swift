// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .package(url: "https://github.com/mongodb/mongo-swift-driver.git", from: "VERSION.STRING.HERE"),
    ],
    targets: [
        .target(name: "MyPackage", dependencies: ["MongoSwift"])
    ]
)
