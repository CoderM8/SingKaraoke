import 'package:rxdart/rxdart.dart';
import 'package:sing_karaoke/constant.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  PositionData(this.position, this.bufferedPosition, this.duration);
}

Stream<PositionData> get positionDataStream =>
    Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        set(player.value).positionStream,
        set(player.value).bufferedPositionStream,
        set(player.value).durationStream,
            (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));


Stream<PositionData> get videoPositionDataStream =>
    Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioMixPlayer.positionStream,
        audioMixPlayer.bufferedPositionStream,
        audioMixPlayer.durationStream,
            (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));
