import { DynamicSyncScene } from '@ohos.arkui.UIContext'
import { FPS_BOOST, FPS_IDLE } from '../common/Constants'

export function boostFrameRate(
  scenes: DynamicSyncScene[]
): void {
  scenes.forEach((scene) => {
    scene.setFrameRateRange(FPS_BOOST)
  })
}

export function idleFrameRate(
  scenes: DynamicSyncScene[]
): void {
  scenes.forEach((scene) => {
    scene.setFrameRateRange(FPS_IDLE)
  })
}
