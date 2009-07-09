/*
 *   ShinyCocos - ruby bindings for the cocos2d-iphone game framework
 *   Copyright (C) 2009, Rolando Abarca M.
 *
 *   This library is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License.
 *
 *   This library is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *   Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

extern VALUE rb_mActions;

// genereted by:
// cat cocos2d-iphone/cocos2d/*Action.h | grep @interface | ruby -ne 'md = $_.match(/@interface +(\w+) *: *(\w+)/); puts "extern VALUE rb_c#{md[1]}; // #{md[2]}" if md'
extern VALUE rb_cAction; // Object
extern VALUE rb_cFiniteTimeAction; // Action
extern VALUE rb_cRepeatForever; // Action
extern VALUE rb_cSpeed; // Action
extern VALUE rb_cCameraAction; // IntervalAction
extern VALUE rb_cOrbitCamera; // CameraAction
extern VALUE rb_cEaseAction; // IntervalAction
extern VALUE rb_cEaseRateAction; // EaseAction
extern VALUE rb_cEaseIn; // EaseRateAction
extern VALUE rb_cEaseOut; // EaseRateAction
extern VALUE rb_cEaseInOut; // EaseRateAction
extern VALUE rb_cEaseExponentialIn; // EaseAction
extern VALUE rb_cEaseExponentialOut; // EaseAction
extern VALUE rb_cEaseExponentialInOut; // EaseAction
extern VALUE rb_cEaseSineIn; // EaseAction
extern VALUE rb_cEaseSineOut; // EaseAction
extern VALUE rb_cEaseSineInOut; // EaseAction
extern VALUE rb_cWaves3D; // Grid3DAction
extern VALUE rb_cFlipX3D; // Grid3DAction
extern VALUE rb_cFlipY3D; // FlipX3D
extern VALUE rb_cLens3D; // Grid3DAction
extern VALUE rb_cRipple3D; // Grid3DAction
extern VALUE rb_cShaky3D; // Grid3DAction
extern VALUE rb_cLiquid; // Grid3DAction
extern VALUE rb_cWaves; // Grid3DAction
extern VALUE rb_cTwirl; // Grid3DAction
extern VALUE rb_cGridAction; // IntervalAction
extern VALUE rb_cGrid3DAction; // GridAction
extern VALUE rb_cTiledGrid3DAction; // GridAction
extern VALUE rb_cAccelDeccelAmplitude; // IntervalAction
extern VALUE rb_cAccelAmplitude; // IntervalAction
extern VALUE rb_cDeccelAmplitude; // IntervalAction
extern VALUE rb_cStopGrid; // InstantAction
extern VALUE rb_cReuseGrid; // InstantAction
extern VALUE rb_cInstantAction; // FiniteTimeAction
extern VALUE rb_cShow; // InstantAction
extern VALUE rb_cHide; // InstantAction
extern VALUE rb_cToggleVisibility; // InstantAction
extern VALUE rb_cPlace; // InstantAction
extern VALUE rb_cCallFunc; // InstantAction
extern VALUE rb_cCallFuncN; // CallFunc
extern VALUE rb_cCallFuncND; // CallFuncN
extern VALUE rb_cIntervalAction; // FiniteTimeAction
extern VALUE rb_cSequence; // IntervalAction
extern VALUE rb_cRepeat; // IntervalAction
extern VALUE rb_cSpawn; // IntervalAction
extern VALUE rb_cRotateTo; // IntervalAction
extern VALUE rb_cRotateBy; // IntervalAction
extern VALUE rb_cMoveTo; // IntervalAction
extern VALUE rb_cMoveBy; // MoveTo
extern VALUE rb_cJumpBy; // IntervalAction
extern VALUE rb_cJumpTo; // JumpBy
extern VALUE rb_cBezierBy; // IntervalAction
extern VALUE rb_cScaleTo; // IntervalAction
extern VALUE rb_cScaleBy; // ScaleTo
extern VALUE rb_cBlink; // IntervalAction
extern VALUE rb_cFadeIn; // IntervalAction
extern VALUE rb_cFadeOut; // IntervalAction
extern VALUE rb_cFadeTo; // IntervalAction
extern VALUE rb_cTintTo; // IntervalAction
extern VALUE rb_cTintBy; // IntervalAction
extern VALUE rb_cDelayTime; // IntervalAction
extern VALUE rb_cReverseTime; // IntervalAction
extern VALUE rb_cAnimate; // IntervalAction
extern VALUE rb_cShakyTiles3D; // TiledGrid3DAction
extern VALUE rb_cShatteredTiles3D; // TiledGrid3DAction
extern VALUE rb_cShuffleTiles; // TiledGrid3DAction
extern VALUE rb_cFadeOutTRTiles; // TiledGrid3DAction
extern VALUE rb_cFadeOutBLTiles; // FadeOutTRTiles
extern VALUE rb_cFadeOutUpTiles; // FadeOutTRTiles
extern VALUE rb_cFadeOutDownTiles; // FadeOutUpTiles
extern VALUE rb_cTurnOffTiles; // TiledGrid3DAction
extern VALUE rb_cWavesTiles3D; // TiledGrid3DAction
extern VALUE rb_cJumpTiles3D; // TiledGrid3DAction
extern VALUE rb_cSplitRows; // TiledGrid3DAction
extern VALUE rb_cSplitCols; // TiledGrid3DAction

void init_rb_mAction();
