# Shuttle Tracker
An app for iPhone, iPad, iPod touch, Apple Watch (soon), and Mac to track the Rensselaer campus shuttles

Download the app today: https://shuttletracker.app/swiftui


## Development
[STLogging](https://github.com/wtg/Shuttle-Tracker-Logging) is a required dependency, but it isn’t included as a remote package dependency in the Xcode project. The easiest way to include it is to clone the STLogging repository separately and to add it to a shared Xcode workspace alongside the main Shuttle Tracker project. Otherwise, Xcode might complain about being unable to find the STLogging implementation when building Shuttle Tracker.
