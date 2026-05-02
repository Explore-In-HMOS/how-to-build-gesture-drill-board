import { PromptAction } from '@kit.ArkUI';
import { dragController } from '@kit.ArkUI';
import { unifiedDataChannel } from '@kit.ArkData';
import { DynamicSyncScene } from '@ohos.arkui.UIContext';
import {
  TileId,
  DrillIcon,
  TILE_SIZE_COMPACT,
  TILE_RADIUS_COMPACT,
  TILE_SPACING,
  ICON_FONT_SIZE,
  HEADER_FONT_SIZE,
  STATUS_FONT_SIZE,
  HINT_FONT_SIZE,
  DRAG_PREVIEW_SIZE,
  DRAG_PREVIEW_RADIUS,
  DRAG_PREVIEW_FONT_SIZE,
  PINCH_FINGERS,
  PINCH_COMPLETE_THRESHOLD,
  PINCH_SNAP_FACTOR,
  DRAG_CLAMP_LIMIT,
  DRAG_COMPLETE_DISTANCE,
  DRAG_HINT_X_COMPACT,
  DRAG_HINT_Y_COMPACT,
  FPS_BOOST,
  FPS_IDLE,
  TOTAL_DRILLS,
  BORDER_RADIUS_CIRCLE,
  FULL_SIZE
} from '../common/Constants'

@Entry
@Component
struct DrillBoard {
  @State activeStation: string = TileId.PINCH_TILE
  @State pinchScale: number = 1.0
  @State pinchBase: number = 1.0
  @State pinchDone: boolean = false
  @State dragOffX: number = 0
  @State dragOffY: number = 0
  @State dragDone: boolean = false
  private dragAction: dragController.DragAction | null = null
  private scenes: DynamicSyncScene[] = []
  promptAction: PromptAction = this.getUIContext().getPromptAction();

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
    Column() {
      Text($r('app.string.drill_board_title'))
        .fontSize(HEADER_FONT_SIZE)
        .fontColor($r('app.color.header_text'))
        .margin({ bottom: 8 })

      Row({ space: TILE_SPACING }) {
        Stack({ alignContent: Alignment.Center }) {
          Text(this.pinchDone ? DrillIcon.COMPLETED : DrillIcon.PINCH_DEFAULT)
            .fontSize(ICON_FONT_SIZE)
            .fontColor($r('app.color.pinch_icon'))
            .scale({
              x: this.pinchScale,
              y: this.pinchScale
            })
        }
        .width(TILE_SIZE_COMPACT)
        .height(TILE_SIZE_COMPACT)
        .borderRadius(TILE_RADIUS_COMPACT)
        .backgroundColor($r('app.color.tile_background'))
        .id(TileId.PINCH_TILE)
        .gesture(
          PinchGesture({ fingers: PINCH_FINGERS })
            .onActionStart(() => {
              this.pinchBase = this.pinchScale
              this.boostFps()
            })
            .onActionUpdate((e: GestureEvent) => {
              this.pinchScale = this.pinchBase * e.scale
            })
            .onActionEnd((e: GestureEvent) => {
              this.pinchScale =
                Math.round(this.pinchScale * PINCH_SNAP_FACTOR) / PINCH_SNAP_FACTOR
              if (this.pinchScale >= PINCH_COMPLETE_THRESHOLD) {
                this.pinchDone = true
                this.activeStation = TileId.DRAG_TILE
              }
              this.idleFps()
            })
        )
        .onGestureJudgeBegin((gi, ev) => {
          if (gi.type === GestureControl.GestureType.PINCH_GESTURE) {
            return GestureJudgeResult.CONTINUE
          }
          return GestureJudgeResult.REJECT
        })

        // Drag tile — icon moves inside box
        Stack({ alignContent: Alignment.Center }) {
          Text(this.dragDone ? DrillIcon.COMPLETED : DrillIcon.DRAG_DEFAULT)
            .fontSize(ICON_FONT_SIZE)
            .fontColor($r('app.color.drag_icon'))
            .translate({
              x: this.dragOffX,
              y: this.dragOffY
            })
          if (!this.dragDone) {
            Text($r('app.string.drag_hint'))
              .fontSize(HINT_FONT_SIZE)
              .fontColor($r('app.color.hint_text'))
              .position({ x: DRAG_HINT_X_COMPACT, y: DRAG_HINT_Y_COMPACT })
          }
        }
        .width(TILE_SIZE_COMPACT)
        .height(TILE_SIZE_COMPACT)
        .borderRadius(TILE_RADIUS_COMPACT)
        .backgroundColor($r('app.color.tile_background'))
        .clip(true)
        .id(TileId.DRAG_TILE)
        .gesture(
          PanGesture()
            .onActionStart(() => {
              this.activeStation = TileId.DRAG_TILE
              this.boostFps()
            })
            .onActionUpdate((e: GestureEvent) => {
              this.dragOffX = Math.max(0 - DRAG_CLAMP_LIMIT,
                Math.min(DRAG_CLAMP_LIMIT, e.offsetX))
              this.dragOffY = Math.max(0 - DRAG_CLAMP_LIMIT,
                Math.min(DRAG_CLAMP_LIMIT, e.offsetY))
            })
            .onActionEnd(() => {
              let dist = Math.sqrt(
                this.dragOffX * this.dragOffX +
                  this.dragOffY * this.dragOffY)
              if (dist >= DRAG_COMPLETE_DISTANCE) {
                this.dragDone = true
                let t = new unifiedDataChannel.Text();
                let ud = new unifiedDataChannel.UnifiedData(t);
                try {
                  this.dragAction = this
                    .getUIContext()
                    .getDragController()
                    .createDragAction(
                      [() => {
                        this.DragPreview()
                      }],
                      {
                        pointerId: 0, data: ud,
                        extraParams: ''
                      }
                    );
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
              this.dragOffX = 0
              this.dragOffY = 0
              this.idleFps()
            })
        )
        .onGestureJudgeBegin((gi, ev) => {
          let mod = ev.getModifierKeyState?.(['Ctrl'])
          console.info(`Modifier: ${mod}`)
          if (gi.type === GestureControl.GestureType.PINCH_GESTURE) {
            return GestureJudgeResult.REJECT
          }
          return GestureJudgeResult.CONTINUE
        })
      }

      Text((this.pinchDone ? 1 : 0) +
        (this.dragDone ? 1 : 0) + ` / ${TOTAL_DRILLS}`)
        .fontSize(STATUS_FONT_SIZE)
        .fontColor($r('app.color.status_text_active'))
        .margin({ top: 12 })
    }
    .width(FULL_SIZE)
    .height(FULL_SIZE)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.board_background'))
    .borderRadius(BORDER_RADIUS_CIRCLE)
    .clip(true)
    .id(TileId.DRILL_ROOT)
    .onAppear(() => {
      this.scenes = this.getUIContext()
        .requireDynamicSyncScene(TileId.DRILL_ROOT)
    })
    .onChildTouchTest((touchInfo) => {
      let currentStation = this.activeStation
      for (let info of touchInfo) {
        if (info.id === currentStation) {
          return {
            id: info.id,
            strategy: TouchTestStrategy.FORWARD_COMPETITION
          }
        }
      }
      return { strategy: TouchTestStrategy.DEFAULT }
    })
  }

  // ── Frame-rate helpers ──
  boostFps() {
    let localScenes = this.scenes
    localScenes.forEach((s) => {
      s.setFrameRateRange(FPS_BOOST)
    })
  }

  idleFps() {
    let localScenes = this.scenes
    localScenes.forEach((s) => {
      s.setFrameRateRange(FPS_IDLE)
    })
  }
}
