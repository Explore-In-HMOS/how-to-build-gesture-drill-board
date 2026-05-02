export enum TileId {
  PINCH_TILE = 'PinchTile',
  DRAG_TILE = 'DragTile',
  DRILL_ROOT = 'drillRoot'
}

export enum DrillIcon {
  PINCH_DEFAULT = '⊕',
  DRAG_DEFAULT = '↕',
  COMPLETED = '✓'
}

export const TILE_SIZE = 90
export const TILE_RADIUS = 16
export const TILE_SIZE_COMPACT = 86
export const TILE_RADIUS_COMPACT = 14
export const TILE_SPACING = 8

export const ICON_FONT_SIZE = 28
export const ICON_FONT_SIZE_LARGE = 32
export const HEADER_FONT_SIZE = 14
export const STATUS_FONT_SIZE = 12
export const HINT_FONT_SIZE = 9
export const DRAG_PREVIEW_SIZE = 48
export const DRAG_PREVIEW_RADIUS = 24
export const DRAG_PREVIEW_FONT_SIZE = 24

export const PINCH_FINGERS = 2
export const PINCH_COMPLETE_THRESHOLD = 1.5
export const PINCH_SNAP_FACTOR = 10

export const DRAG_CLAMP_LIMIT = 25
export const DRAG_COMPLETE_DISTANCE = 15
export const DRAG_HINT_X = 26
export const DRAG_HINT_Y = 72
export const DRAG_HINT_X_COMPACT = 22
export const DRAG_HINT_Y_COMPACT = 68

export const FPS_BOOST: ExpectedFrameRateRange = {
  min: 0, max: 120, expected: 90
}
export const FPS_IDLE: ExpectedFrameRateRange = {
  min: 0, max: 60, expected: 30
}

export const TOTAL_DRILLS = 2
export const BORDER_RADIUS_CIRCLE = '50%'
export const FULL_SIZE = '100%'
