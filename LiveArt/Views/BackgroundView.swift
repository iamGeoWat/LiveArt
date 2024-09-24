//
//  BackGroundView.swift
//  LiveArt
//
//  Created by GeoWat on 2024/9/23.
//

import SwiftUI

struct BackgroundView: View {
    let dotSize: CGFloat = 3
    let spacing: CGFloat = 15

    var body: some View {
        Canvas { context, size in
            let columns = Int(size.width / (dotSize + spacing))
            let rows = Int(size.height / (dotSize + spacing))

            for row in 0...rows {
                for column in 0...columns {
                    let xPosition = CGFloat(column) * (dotSize + spacing) + spacing / 2
                    let yPosition = CGFloat(row) * (dotSize + spacing) + spacing / 2
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: xPosition, y: yPosition, width: dotSize, height: dotSize)),
                        with: .color(
                            .gray.opacity(0.25)
                        )
                    )
                }
            }
        }
    }
}

#Preview {
    BackgroundView()
}
