import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';

/// Default portrait controls.
class FlickCustomControls extends StatelessWidget {
  final void Function()? onFullScreenToggle;

  const FlickCustomControls({
    super.key,
    this.iconSize = 20,
    this.fontSize = 12,
    this.onFullScreenToggle,
  });

  /// Icon size.
  ///
  /// This size is used for all the player icons.
  final double iconSize;

  /// Font size.
  ///
  /// This size is used for all the text.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Positioned.fill(
        //   child: FlickShowControlsAction(
        //     child: FlickSeekVideoAction(
        //       child: Center(
        //         child: FlickVideoBuffer(
        //           child: FlickAutoHideChild(
        //             showIfVideoNotInitialized: false,
        //             child: FlickPlayToggle(
        //               size: 30,
        //               color: Colors.black,
        //               padding: EdgeInsets.all(12),
        //               decoration: BoxDecoration(
        //                 color: Colors.white70,
        //                 borderRadius: BorderRadius.circular(40),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickAutoHideChild(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Spacer(),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // FlickSubtitleToggle(
                          //   size: iconSize,
                          // ),
                          // SizedBox(
                          //   width: iconSize / 2,
                          // ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => onFullScreenToggle?.call(),
                                    child: Text(
                                      '전체화면',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        height: 1.25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: FlickFullScreenToggle(
                                    size: iconSize,
                                    toggleFullscreen: onFullScreenToggle,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
