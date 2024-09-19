# DGImageCropper
Simple and clean image cropper made by pure SwiftUI


<div>
<img src="https://github.com/user-attachments/assets/d1b1c985-0d17-401d-96e9-ad9948cbd271" width=200 />
<img src="https://github.com/user-attachments/assets/9751cd3b-d6ac-4ff4-aa59-14bcbae3f17d" width=200 />
<img src="https://github.com/user-attachments/assets/ee5eb929-7cac-4f45-becc-975b4830d6cf" width=200 />
</div>


## Installation

### Swift Package Manager

The [Swift Package Manager](https://www.swift.org/documentation/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding `DGImageCropper` as a dependency is as easy as adding it to the dependencies value of your Package.swift or the Package list in Xcode.

```
dependencies: [
   .package(url: "https://github.com/donggyushin/DGImageCropper", .upToNextMajor(from: "1.0.1"))
]
```

Normally you'll want to depend on the DGImageCropper target:

```
.product(name: "DGImageCropper", package: "DGImageCropper")
```

## Usage
Make an `ImageCropperModel` instance and control the DGImageCropper SwiftUIView through the `ImageCropperModel` instance. <br />

### Functions

| Function    | Description                                               |
|-------------|-----------------------------------------------------------|
| crop        | Cut the selected part of the image and return the image.  |
| changeRatio | Change the ratio of selecting part.                       |


### Code Example
```swift
struct ContentView: View {
    
    let model: ImageCropperModel
    
    @State private var image: UIImage?
    @State private var degree: Double = 0
    
    init() {
        let model: ImageCropperModel = .init(image: .sample)
        self.model = model
    }
    
    var body: some View {
        VStack {
            
            DGImageCropper(model: model)
            
            HStack {
                Button("1:1") {
                    model.changeRatio(ratio: .square)
                }
                
                Spacer()
                
                Button("4:3") {
                    model.changeRatio(ratio: .width4height3)
                }
                
                Spacer()
                
                Button("3:4") {
                    model.changeRatio(ratio: .width3height4)
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .bottom) {
            Button("Crop") {
                let croppedImage = model.crop()
            }
            .offset(y: 100)
        }
    }
}
```