import {
  TileId,
  DrillIcon,
  TILE_SIZE,
  TILE_RADIUS,
  ICON_FONT_SIZE_LARGE,
  PINCH_FINGERS,
  PINCH_COMPLETE_THRESHOLD,
  PINCH_SNAP_FACTOR
} from '../common/Constants'

@Component
struct PinchStation {
  @State scaleVal: number = 1.0
  @State pinchBase: number = 1.0
  @State drillDone: boolean = false
  @Link activeStation: string

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Text(this.drillDone ? DrillIcon.COMPLETED : DrillIcon.PINCH_DEFAULT)
        .fontSize(ICON_FONT_SIZE_LARGE)
        .fontColor($r('app.color.pinch_icon'))
        .scale({ x: this.scaleVal, y: this.scaleVal })
    }
    .width(TILE_SIZE)
    .height(TILE_SIZE)
    .borderRadius(TILE_RADIUS)
    .backgroundColor($r('app.color.tile_background'))
    .id(TileId.PINCH_TILE)
    .gesture(
      PinchGesture({ fingers: PINCH_FINGERS })
        .onActionStart(() => {
          this.activeStation = TileId.PINCH_TILE
          this.pinchBase = this.scaleVal
        })
        .onActionUpdate((e: GestureEvent) => {
          this.scaleVal = this.pinchBase * e.scale
        })
        .onActionEnd((e: GestureEvent) => {
          this.scaleVal = Math.round(this.scaleVal * PINCH_SNAP_FACTOR) / PINCH_SNAP_FACTOR
          if (this.scaleVal >= PINCH_COMPLETE_THRESHOLD) {
            this.drillDone = true
          }
        })
    )
    .onGestureJudgeBegin((gestureInfo: GestureInfo,
      event: BaseGestureEvent) => {
      let btnHeld = event.getModifierKeyState?.(['Ctrl'])
      if (btnHeld) {
        console.info('Confirm modifier active')
      }
      if (gestureInfo.type === GestureControl.GestureType.PINCH_GESTURE) {
        return GestureJudgeResult.CONTINUE
      }
      return GestureJudgeResult.REJECT
    })
  }
}
