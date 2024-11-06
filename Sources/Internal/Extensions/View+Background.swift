//
//  View+Background.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

extension View {
    func background(backgroundColor: Color, overlayColor: Color, corners: [PopupAlignment: CGFloat]) -> some View { background(
        backgroundColor
            .overlay(overlayColor)
            .mask(RoundedCorner(corners: corners))
    )}
}

// MARK: Background Shape
fileprivate struct RoundedCorner: Shape {
    var corners: [PopupAlignment: CGFloat]

    
    var animatableData: CGFloat {
        get { corners.values.max() ?? 0 }
        set { corners.forEach { corners[$0.key] = newValue } }
    }
    func path(in rect: CGRect) -> Path {
        let points = createPoints(rect)
        let path = createPath(rect, points)
        return path
    }
}
private extension RoundedCorner {
    func createPoints(_ rect: CGRect) -> [CGPoint] {[
        .init(x: rect.minX, y: rect.minY + corners[.top]!),
        .init(x: rect.minX + corners[.top]!, y: rect.minY),
        .init(x: rect.maxX - corners[.top]!, y: rect.minY),
        .init(x: rect.maxX, y: rect.minY + corners[.top]!),
        .init(x: rect.maxX, y: rect.maxY - corners[.bottom]!),
        .init(x: rect.maxX - corners[.bottom]!, y: rect.maxY),
        .init(x: rect.minX + corners[.bottom]!, y: rect.maxY),
        .init(x: rect.minX, y: rect.maxY - corners[.bottom]!)
    ]}
    func createPath(_ rect: CGRect, _ points: [CGPoint]) -> Path { let radius = corners.values.max() ?? 0
        var path = Path()

        path.move(to: points[0])
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: points[1], radius: radius)
        path.addLine(to: points[2])
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: points[3], radius: radius)
        path.addLine(to: points[4])
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: points[5], radius: radius)
        path.addLine(to: points[6])
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: points[7], radius: radius)
        path.closeSubpath()

        return path
    }
}
