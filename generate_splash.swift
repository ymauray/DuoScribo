import AppKit
import CoreGraphics

let size = CGSize(width: 512, height: 512)
let image = NSImage(size: size)

image.lockFocus()
let config = NSImage.SymbolConfiguration(pointSize: 300, weight: .black)
if let flame = NSImage(systemSymbolName: "flame.fill", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
    // On dessine la flamme en blanc pour le splash screen
    let flameSize = flame.size
    let x = (size.width - flameSize.width) / 2
    let y = (size.height - flameSize.height) / 2
    
    // Teindre l'image en blanc
    let rect = NSRect(x: x, y: y, width: flameSize.width, height: flameSize.height)
    flame.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
    
    // Appliquer une teinte blanche via un calque
    NSColor.white.set()
    rect.fill(using: .sourceAtop)
}
image.unlockFocus()

if let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) {
    let png = bitmap.representation(using: .png, properties: [:])
    try? png?.write(to: URL(fileURLWithPath: "Sources/Assets.xcassets/SplashIcon.imageset/splash_icon.png"))
    print("Image Splash générée !")
}
