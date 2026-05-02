import { dragController } from '@kit.ArkUI';
import { unifiedDataChannel } from '@kit.ArkData';
import {
  TileId,
  DrillIcon,
  TILE_SIZE,
  TILE_RADIUS,
  ICON_FONT_SIZE_LARGE,
  HINT_FONT_SIZE,
  DRAG_CLAMP_LIMIT,
  DRAG_COMPLETE_DISTANCE,
  DRAG_HINT_X,
  DRAG_HINT_Y,
  DRAG_PREVIEW_SIZE,
  DRAG_PREVIEW_RADIUS,
  DRAG_PREVIEW_FONT_SIZE
} from '../common/Constants'

@Component
struct DragStation {
  @State drillDone: boolean = false
  @State offX: number = 0
  @State offY: number = 0
  @Link activeStation: string
  private dragAction: dragController.DragAction | null = null

  @Builder
  DragPreview() {
    Column() {
      Text(DrillIcon.DRAG_DEFAULT)
        .fontSize(DRAG_PREVIEW_FONT_SIZE)
        .fontColor($r('app.color.drag_icon'))
    }
    .width(DRAG_PREVIEW_SIZE)
    .height(DRAG_PREVIEW_SIZE)
    .borderRadius(DRAG_PREVIEW_RADIUS)
    .backgroundColor($r('app.color.drag_preview_background'))
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Text(this.drillDone ? DrillIcon.COMPLETED : DrillIcon.DRAG_DEFAULT)
        .fontSize(ICON_FONT_SIZE_LARGE)
        .fontColor($r('app.color.drag_icon'))
        .translate({ x: this.offX, y: this.offY })
      if (!this.drillDone) {
        Text($r('app.string.drag_hint'))
          .fontSize(HINT_FONT_SIZE)
          .fontColor($r('app.color.hint_text'))
          .position({ x: DRAG_HINT_X, y: DRAG_HINT_Y })
      }
    }
    .width(TILE_SIZE)
    .height(TILE_SIZE)
    .borderRadius(TILE_RADIUS)
    .backgroundColor($r('app.color.tile_background'))
    .clip(true)
    .id(TileId.DRAG_TILE)
    .gesture(
      PanGesture()
        .onActionStart(() => {
          this.activeStation = TileId.DRAG_TILE
        })
        .onActionUpdate((e: GestureEvent) => {
          this.offX = Math.max(0 - DRAG_CLAMP_LIMIT,
            Math.min(DRAG_CLAMP_LIMIT, e.offsetX))
          this.offY = Math.max(0 - DRAG_CLAMP_LIMIT,
            Math.min(DRAG_CLAMP_LIMIT, e.offsetY))
        })
        .onActionEnd(() => {
          let dist = Math.sqrt(
            this.offX * this.offX +
              this.offY * this.offY)
          if (dist >= DRAG_COMPLETE_DISTANCE) {
            this.drillDone = true
            let t = new unifiedDataChannel.Text();
            let ud = new unifiedDataChannel.UnifiedData(t);
            try {
              this.dragAction = this.getUIContext()
                .getDragController()
                .createDragAction(
                  [() => {
                    this.DragPreview()
                  }],
                  {
                    pointerId: 0, data: ud,
                    extraParams: ''
                  });
              this.dragAction.on('statusChange',
                (info) => {
                  if (info.status === dragController.DragStatus.ENDED) {
                    this.dragAction?.off('statusChange')
                  }
                })
              this.dragAction.startDrag()
            } catch (err) {
              console.error(`Drag: ${err.message}`)
            }
          }
          this.offX = 0
          this.offY = 0
        })
    )
    .onGestureJudgeBegin((gestureInfo, event) => {
      if (gestureInfo.type === GestureControl.GestureType.PINCH_GESTURE) {
        return GestureJudgeResult.REJECT
      }
      return GestureJudgeResult.CONTINUE
    })
  }
}
