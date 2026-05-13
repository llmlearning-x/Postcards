import { Travel } from '../model/Travel';
import { Colors } from './Colors';
import { StampPerforation } from './PostalComponents';

@Component
export struct TravelFilterChips {
  @Link selectedTravelID: string | null;
  travels: Travel[] = [];
  allTitle: string = '全部';

  build() {
    if (this.travels.length > 0) {
      Scroll() {
        Row({ space: 10 }) {
          this.Chip(this.allTitle, this.selectedTravelID === null, () => {
            this.selectedTravelID = null;
          })

          ForEach(this.travels, (travel: Travel) => {
            this.Chip(travel.destination, this.selectedTravelID === travel.id, () => {
              this.selectedTravelID = travel.id;
            })
          })
        }
        .padding({ left: 4, right: 4 })
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
    }
  }

  @Builder
  Chip(title: string, isSelected: boolean, action: () => void) {
    Button() {
      Row({ space: 6 }) {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
        if (!isSelected) {
          Text(title === this.allTitle ? 'ALL' : title.substring(0, 8).toUpperCase())
            .fontSize(9)
            .fontWeight(FontWeight.Normal)
            .fontFamily('serif')
            .fontColor(Colors.travelBlue)
            .opacity(0.62)
        }
      }
      .padding({ left: 22, right: 22, top: 14, bottom: 14 })
    }
    .type(ButtonType.Normal)
    .borderRadius(5)
    .backgroundColor(isSelected ? Colors.travelBlue : Color.White)
    .border({
      width: 1,
      color: isSelected ? 'rgba(216,191,125,0.5)' : 'rgba(15,93,73,0.2)',
      radius: 5
    })
    
    .onClick(action)
  }
}
