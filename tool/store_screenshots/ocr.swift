// Prints the text lines macOS Vision finds in an image, one per line:
// "<x> <y> <width> <height>\t<text>", in image pixels from the top left.
//
//     swift tool/store_screenshots/ocr.swift shot.png [lang ...]
import AppKit
import Vision

let args = CommandLine.arguments
guard args.count > 1, let image = NSImage(contentsOfFile: args[1]),
      let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    FileHandle.standardError.write("usage: ocr.swift <image> [lang ...]\n".data(using: .utf8)!)
    exit(1)
}
let width = CGFloat(cg.width), height = CGFloat(cg.height)

let request = VNRecognizeTextRequest()
// .accurate hangs for good on this machine (macOS 27); .fast reads the
// quiz's large text well enough.
request.recognitionLevel = .fast
request.usesLanguageCorrection = false
if args.count > 2 { request.recognitionLanguages = Array(args[2...]) }
try VNImageRequestHandler(cgImage: cg).perform([request])

for case let observation in request.results ?? [] {
    guard let text = observation.topCandidates(1).first?.string else { continue }
    let box = observation.boundingBox  // normalized, origin bottom left
    let x = Int(box.minX * width), y = Int((1 - box.maxY) * height)
    print("\(x) \(y) \(Int(box.width * width)) \(Int(box.height * height))\t\(text)")
}
