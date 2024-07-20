import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sing_karaoke/constant.dart';

class PositionSeekWidget extends StatefulWidget {
  Duration? currentPosition;
  Duration? duration;
  Function(Duration)? seekTo;
  Color? bgColor;

  PositionSeekWidget({super.key, this.currentPosition, this.duration, this.seekTo, this.bgColor});

  @override
  PositionSeekWidgetState createState() => PositionSeekWidgetState();
}

class PositionSeekWidgetState extends State<PositionSeekWidget> {
  Duration? _visibleValue;
  bool? listenOnlyUserInterraction = false;

  double get percent => widget.duration!.inMilliseconds == 0 ? 0 : _visibleValue!.inMilliseconds / widget.duration!.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _visibleValue = widget.currentPosition;
  }

  @override
  void didUpdateWidget(PositionSeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listenOnlyUserInterraction!) {
      _visibleValue = widget.currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                min: 0,
                max: widget.duration!.inMilliseconds.toDouble(),
                value: percent * widget.duration!.inMilliseconds.toDouble(),
                activeColor: pink,
                inactiveColor: Colors.grey,
                onChangeEnd: (newValue) {
                  setState(() {
                    listenOnlyUserInterraction = false;
                    widget.seekTo!(_visibleValue!);
                  });
                },
                onChangeStart: (_) {
                  setState(() {
                    listenOnlyUserInterraction = true;
                  });
                },
                onChanged: (newValue) {
                  setState(() {
                    final to = Duration(milliseconds: newValue.floor());
                    _visibleValue = to;
                  });
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: durationToString(widget.currentPosition!), fontFamily: "R"),
              TextWidget(text: durationToString(widget.duration!), fontFamily: "R"),
            ],
          ),
        )
      ],
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitHours = twoDigits(duration.inHours.remainder(Duration.hoursPerDay));
  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return twoDigitHours == "00" ? '$twoDigitMinutes:$twoDigitSeconds' : '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
}
