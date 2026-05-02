import {
  STATUS_FONT_SIZE,
  HINT_FONT_SIZE
} from '../common/Constants'

@Component
export struct StatusRing {
  @Prop completedCount: number = 0;
  @Prop totalCount: number = 2;

  build() {
    Column() {
      Text(`${this.completedCount} / ${this.totalCount}`)
        .fontSize(STATUS_FONT_SIZE)
        .fontColor(this.completedCount >= this.totalCount
          ? $r('app.color.status_text_active')
          : $r('app.color.status_text_idle'))
        .fontWeight(FontWeight.Bold)

      Text(this.completedCount >= this.totalCount
        ? $r('app.string.status_all_done')
        : $r('app.string.status_in_progress'))
        .fontSize(HINT_FONT_SIZE)
        .fontColor($r('app.color.status_subtitle'))
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .padding(8)
  }
}
