# TextMate Swift Completions

[![TextMate Example](https://j.gifs.com/OXnG0Z.gif)](https://www.youtube.com/watch?v=jIMvrCkNn1I&feature=youtu.be)

[YouTube Video](https://www.youtube.com/watch?v=jIMvrCkNn1I&feature=youtu.be)

This is a plugin which enables Swift Auto Completions from within [TextMate](https://github.com/textmate/textmate).

This is still very basic, and more or less a proof-of-concept. I don't use TextMate anymore, so I doubt I'll continue working on this, however I hope avid TextMate users pick up where I stopped. If you'd like to extend this, feel free to create a pull request.

# Features
- Auto Completions using [SourceKittenDaemon](https://github.com/terhechte/SourceKittenDaemon)
- Select Daemon with Configuration (i.e. allows working on multiple projects at the same time)

# Installation

1. You'll need [SourceKittenDaemon](https://github.com/terhechte/SourceKittenDaemon) installed, so head over there and install the latest release.

2. Download the TextMateSwiftCompletion.tmbundle, and double-click it, so that it can be installed in TextMate

# Usage

1. Once TextMate started, there should be a new menu entry under the `Window` named `Swift Completion`. There're two menu entries, the second will be grayed out.

2. Click the `Swift Project Settings` Menu Entry.

3. Now you'll have to open a Terminal and start the SourceKittenDaemon for an Xcode project of your choice on a free local port:

Example:
`SourceKittenDaemon start --port 44876 --project /private/tmp/abcde/abcde.xcodeproj`

4. Enter the selected port in the TextMate Swift Setup window

5. Click `Test Connection`. If the connection fails, open an Issue on GitHub ;)

6. Click "Close"

7. Now you can open a Swift file from your Xcode project.

8. Navigate somewhere and get completions via the "Command-Shift-." (Period) keyboard shortcut.

# State

This is  more or less a proof of concept, so the code is really awful. Also, since TextMate has no official plugin API or Completion API (which I could find), completions do not look very integrated into the editor. Still, they work. Also, I don't use TextMate. I've developed this more or less to have a reference implementation people can build on.

# Contributing

Just check out the repository. It expects TextMate to be installed in /Applications. When you build the repository, it will *kill the current TextMate app*, so make sure you don't have anything important in there. Building the Bundle will automatically install it in TextMate, that way you can just restart TextMate and try it out.

Pull Requests very Welcome.

