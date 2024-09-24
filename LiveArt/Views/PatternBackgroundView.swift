//
//  PatternBackgroundView.swift
//  LiveArt
//
//  Created by ByteDance on 3/7/24.
//

//import SwiftUI
//import CoreMotion
//import Combine
//
//
//struct PatternBackgroundView: View {
//    let dotSize: CGFloat = 3
//    let spacing: CGFloat = 15
//    @ObservedObject var motionManager = MotionManager()
//    var funMode = false
//
//    var body: some View {
//        Canvas { context, size in
//            let columns = Int(size.width / (dotSize + spacing))
//            let rows = Int(size.height / (dotSize + spacing))
//
//            for row in 0...rows {
//                for column in 0...columns {
//                    let xPosition = CGFloat(column) * (dotSize + spacing) + spacing / 2
//                    let yPosition = CGFloat(row) * (dotSize + spacing) + spacing / 2
//                    
//                    let color = calculateShadingForPosition(x: xPosition, y: yPosition, size: size, motionData: motionManager.motionData)
//                    
//                    
//                    context.fill(
//                        Path(ellipseIn: CGRect(x: xPosition, y: yPosition, width: dotSize, height: dotSize)),
//                        with: .color(
//                            funMode ? color : .gray.opacity(0.25)
//                        )
//                    )
//                }
//            }
//        }
//    }
//    
//    // Calculate dot shading based on gyroscope data
//    private func calculateShadingForPosition(x: CGFloat, y: CGFloat, size: CGSize, motionData: CMDeviceMotion?) -> Color {
//        let defaultColor = Color.gray.opacity(0.25)
//        guard let motionData = motionData else {
//            // Return a default shading if motionData is not available
//            return defaultColor
//        }
//        // Calculate shading based on position; this is a simplified placeholder logic
//        let normalizedX = x / size.width // [0, 1]
//        let normalizedY = y / size.height // [0, 1]
//        // Simplified example: adjust shading based on device tilt
//        let tiltFactor = (
//            normalizedX * 0.2 + motionData.attitude.roll / .pi,
//            normalizedY * 0.2 + motionData.attitude.pitch / .pi
//        ) // Range [-1, 1]
//        
//        if (-0.3..<0.3).contains(tiltFactor.0) && (-0.05..<0.55).contains(tiltFactor.1) {
//            let normalizedTiltFactor = (
//                normalize(value: tiltFactor.0, from: (-0.3, 0.3), to: (-1, 1)),
//                normalize(value: tiltFactor.1, from: (-0.05, 0.55), to: (-1, 1))
//            )
//            let distance = sqrt(
//                normalizedTiltFactor.0 * normalizedTiltFactor.0 +
//                normalizedTiltFactor.1 * normalizedTiltFactor.1
//            )
//            return Color(hue: distance, saturation: 0.8, brightness: 0.8, opacity: 0.3)
//        }
//        return defaultColor
//    }
//}
//
//class MotionManager: ObservableObject {
//    private var motionManager = CMMotionManager()
//    @Published var motionData: CMDeviceMotion?
//
//    init() {
//        startGyroscope()
//    }
//
//    private func startGyroscope() {
//        if motionManager.isDeviceMotionAvailable {
//            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // Update 60 times per second
//            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
//                guard let data = data, error == nil else { return }
//                self?.motionData = data
//            }
//        }
//    }
//}
//
//#Preview {
//    PatternBackgroundView()
//}
