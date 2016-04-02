BatteryNotifier
==================

.. image:: https://raw.github.com/kalvin126/BatteryNotifier/master/Resources/screenshot.png

Ever leave to go out and about only to find you did not charge your iPhone's battery at all?
Do not look at your phone to often? This tool helps you manage your iOS device battery levels and warns you if they need a charge.


**Download app build** (updated 4/1/16): `BatteryNotifier.zip`_.

.. _BatteryNotifier.zip:
    https://raw.github.com/kalvin126/BatteryNotifier/master/Resources/BatteryNotifier.zip

Features:
............

- Low battery warning notifications
- View all your iOS device battery levels from your Mac

Q/A
...
**Q: When do battery statuses update?**
	A: iOS devices broadcast service announcements continuously when they are awake. Once they sleep, they broadcast exponentially such as after 1 second, 3 seconds, 9 seconds, 27 seconds, and so on, up to a maximum interval of one hour.

**Q: Why is my device not showing?**
    A: An iOS device and your Mac must be on the same network or connected via USB for BatteryNotifier to work. Trust your Mac when you plug in your iOS device for the first time. Be sure to try enabling Wifi sync through iTunes for said device as well. Sometimes it may just glitch and your mac may fail to listen for broadcasts (in this case reconnect to your network).

Credits:
........
- `Samantha Marshall`_ - `SDMMobileDevice`_ creator

.. _Samantha Marshall:
    https://pewpewthespells.com

.. _SDMMobileDevice:
    https://github.com/samdmarshall/SDMMobileDevice
