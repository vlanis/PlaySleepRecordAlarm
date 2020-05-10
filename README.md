# PlaySleepRecordAlarm

## Description

Application allows user to set a sleep timer, during which a calm and relaxing sound of nature will be played helping user to fall asleep, then application will star recording sounds of sleep. At the end, user will be gently woken up with a alarm sound scheduled to be fired at time, configured prior staring the flow with Alarm option.

## General info

* supports only iPhone idiom
* iOS 13 and higher

## What is done

* application flow as follows:
  * user sets Sleep Timer and Alarm Time
  * taps Play
  * sounds of nature playback is initiated
  * after sleep timer if fired, sounds is turned off and audio recording is started
  * at time set by Alarm Time alarm (with sound and alert) is triggered, user taps Stop button in order to stop alarm from playing and reset screen to its initial state
  * user may pause (with Pause button) nature sounds playback and sound recording at any time, but not an alarm
  
* background audio playback and sounds recording is supported
* while application is inactive, user will receive a local notification with an alarm message
* some unit tests (see `SleepAlarmViewModelTests`)

## Entities

#### SleepAlarmViewModelImp
Adopts `SleepAlarmViewModel` protocol. Encapsulates Sleep Alarm screen business logic.

#### SleepAlarmViewController
UI (View) of the Sleep Alarm screen.

#### AudioPlayerController
Adopts `AudioPlayerControllable` protocol. Responsible for an audio file playback.

#### AudioRecorderController
Adopts `AudioRecorderControllable` protocol. Responsible for a sound recording.

#### LocalNotificationController
Adopts `LocalNotificationControllable` protocol. Manages scheduling and canceling of a local notifications. Also observse notifications triggering by implementing some of methods from `UNUserNotificationCenterDelegate`.

#### ApplicationNavigatorImp
Adopts `ApplicationNavigator` and `SleepAlarmPresenter`. That is a mix of Router and Presenter. Responsible for navigation stack setup and screens presentation.

#### Row
Helper. A generic structure that surves as a model for table view cell setup and configuration.

#### BasicTableViewCell
Table view cell used for displaying Sleep Timer and Alarm Time options.

#### TimePickerViewController
Implements time picking functionality.

#### ContentSizeModalPresentationController
Used for `TimePickerViewController` custom presentation.

#### Extension folder group
`Date+PlaySleepRecordAlarm`, `DateFormatter+PlaySleepRecordAlarm` and `UIStoryboard+PlaySleepRecordAlarm`.

## TODOs and what to improve

* to grey Sleep Timer and Alarm Time option while flow is running in order to notify user that those are disabled (UX improvement)
* to decompose `TimePickerViewController` on View and ViewModel
* write more unit tests
* to handle application to be opened with Local Notification by gently moving application into alarm state
* configure Local Notification (`UNNotification`) to play some short (30 secs of less) audio track as an alarm sound; this is required to still be able to play actual aralm sound if application was closed while flow was running
* implement possibility to turn off a sound recording
