import SwiftUI

struct TravelFilterChips: View {
    let travels: [Travel]
    @Binding var selectedTravelID: UUID?
    let allTitle: String
    let selectedColor: Color
    let unselectedBackground: Color
    let font: Font

    init(
        travels: [Travel],
        selectedTravelID: Binding<UUID?>,
        allTitle: String = "全部",
        selectedColor: Color = PostcardColors.travelBlue,
        unselectedBackground: Color = .white,
        font: Font = .subheadline.weight(.medium)
    ) {
        self.travels = travels
        self._selectedTravelID = selectedTravelID
        self.allTitle = allTitle
        self.selectedColor = selectedColor
        self.unselectedBackground = unselectedBackground
        self.font = font
    }

    var body: some View {
        if !travels.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    chip(title: allTitle, isSelected: selectedTravelID == nil) {
                        selectedTravelID = nil
                    }

                    ForEach(travels) { travel in
                        chip(
                            title: travel.destination,
                            isSelected: selectedTravelID == travel.id
                        ) {
                            selectedTravelID = travel.id
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .heavy, design: .serif))
                if !isSelected {
                    Text(title == allTitle ? "ALL" : title.prefix(8).uppercased())
                        .font(.system(size: 9, weight: .medium, design: .serif))
                        .foregroundColor(selectedColor.opacity(0.62))
                }
            }
            .foregroundColor(isSelected ? .white : selectedColor)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isSelected ? selectedColor : unselectedBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isSelected ? PostcardColors.dawnYellow.opacity(0.5) : selectedColor.opacity(0.2), lineWidth: 1)
            )
            .overlay(StampPerforationOverlay(cornerRadius: 5, color: PostcardColors.pageBackground))
        }
        .buttonStyle(.plain)
    }
}
