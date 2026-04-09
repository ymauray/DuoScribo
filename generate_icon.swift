import AppKit
import CoreGraphics

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

let context = NSGraphicsContext.current!.cgContext

// 1. Fond avec dégradé
let colors = [NSColor.orange.cgColor, NSColor.red.cgColor] as CFArray
let colorSpace = CGColorSpaceCreateDeviceRGB()
let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 0, y: 0), options: [])

// 2. Dessiner la flamme (via SF Symbol)
let config = NSImage.SymbolConfiguration(pointSize: 600, weight: .black)
if let flame = NSImage(systemSymbolName: "flame.fill", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
    let flameSize = flame.size
    let x = (size.width - flameSize.width) / 2
    let y = (size.height - flameSize.height) / 2
    
    // Ombre de la flamme
    context.setShadow(offset: CGSize(width: 0, height: -20), blur: 30, color: NSColor.black.withAlphaComponent(0.3).cgColor)
    
    flame.draw(in: NSRect(x: x, y: y, width: flameSize.width, height: flameSize.height), from: .zero, operation: .sourceOver, fraction: 1.0)
}

image.unlockFocus()

if let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) {
    let png = bitmap.representation(using: .png, properties: [:])
    try? png?.write(to: URL(fileURLWithPath: "Sources/Assets.xcassets/AppIcon.appiconset/icon.png"))
    print("Icône générée avec succès !")
}
