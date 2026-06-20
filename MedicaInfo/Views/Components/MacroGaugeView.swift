import SwiftUI

struct MacroGaugeView: View {
    let label: String
    let value: Double
    let target: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        target > 0 ? min(value / target, 1.5) : 0
    }
    
    private var isOverTarget: Bool { value > target && target > 0 }
    private var isNearTarget: Bool { value > target * 0.85 && !isOverTarget }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        AngularGradient(
                            colors: [color, isOverTarget ? .red : color],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(-90 + 360 * min(progress, 1.0))
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.smooth(duration: 0.3), value: value)
                
                // Value in center
                VStack(spacing: 0) {
                    Text("\(Int(value))")
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(isOverTarget ? .red : .primary)
                    Text(unit)
                        .font(.system(size: 8, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // Label
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
            
            // Target indicator
            Text("/ \(Int(target)) \(unit)")
                .font(.system(size: 8, design: .rounded))
                .foregroundColor(isOverTarget ? .red : .secondary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color(.systemBackground))
                #else
                .fill(Color(.windowBackgroundColor))
                #endif
                .shadow(color: Color.black.opacity(0.04), radius: 3, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isOverTarget ? Color.red.opacity(0.3) :
                    isNearTarget ? color.opacity(0.3) :
                    Color.clear,
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    HStack {
        MacroGaugeView(label: "Proteine", value: 95, target: 120, unit: "g", color: .blue)
        MacroGaugeView(label: "Grassi", value: 65, target: 60, unit: "g", color: .orange)
        MacroGaugeView(label: "Energia", value: 1800, target: 2000, unit: "kcal", color: .red)
    }
    .padding()
}
