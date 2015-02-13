part of ripplelib.core;


class RippleDateTime extends DateTime {

  static const int _RIPPLE_EPOCH_MILLIS = 946684800000;
  // = new DateTime.utc(2000, 1, 1, 0, 0, 0, 0).milliSecondsSinceEpoch

  static final RippleDateTime RIPPLE_EPOCH = new RippleDateTime.fromMillisecondsSinceRippleEpoch(0);


  RippleDateTime(int year,
                [int month = 1,
                 int day = 1,
                 int hour = 0,
                 int minute = 0,
                 int second = 0,
                 int millisecond = 0])
      : super(year, month, day, hour, minute, second, millisecond) {
    _checkValidTime();
  }

  RippleDateTime.utc(int year,
                    [int month = 1,
                     int day = 1,
                     int hour = 0,
                     int minute = 0,
                     int second = 0,
                     int millisecond = 0])
      : super.utc(year, month, day, hour, minute, second, millisecond) {
    _checkValidTime();
  }

  RippleDateTime.now() : super.now();

  RippleDateTime.fromMillisecondsSinceRippleEpoch(int millis)
      : super.fromMillisecondsSinceEpoch(_RIPPLE_EPOCH_MILLIS + millis);

  RippleDateTime.fromSecondsSinceRippleEpoch(int seconds)
      : super.fromMillisecondsSinceEpoch(_RIPPLE_EPOCH_MILLIS + 1000 * seconds);

  RippleDateTime.fromDateTime(DateTime dateTime)
      : super.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch) {
    _checkValidTime();
  }

  int get millisecondsSinceRippleEpoch => millisecondsSinceEpoch - _RIPPLE_EPOCH_MILLIS;

  int get secondsSinceRippleEpoch => calculateSecondsSinceRippleEpoch(this);

  void _checkValidTime() {
    if(this.isBefore(RIPPLE_EPOCH)) {
      throw new ArgumentError("The given time is before the Ripple Epoch: $this");
    }
  }

  static int calculateSecondsSinceRippleEpoch(DateTime time) =>
      (time.millisecondsSinceEpoch - _RIPPLE_EPOCH_MILLIS) ~/ 1000;

}