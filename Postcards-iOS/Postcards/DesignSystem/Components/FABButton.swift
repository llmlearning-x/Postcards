import SwiftUI

struct FABButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(PostcardColors.stampRed)
                    .frame(width: 66, height: 66)
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.82))
                            .frame(width: 28, height: 5)
                            .offset(y: 12)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    )
                    .shadow(color: PostcardColors.stampRed.opacity(0.32), radius: 14, x: 0, y: 6)

                VStack(spacing: 3) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("寄出")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier("RecordButton")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
