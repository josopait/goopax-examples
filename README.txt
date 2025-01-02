Building Example Programs
=========================

Run script `build-all.sh` to build required libraries and the example programs.


Windows
-------
To build the example programs on windows, install the following applications:
- visual studio 2022
- cmake
- git (with git bash)
Use git bash to run the build script `./build-all.sh`.


MacOS
-----
To build the example programs for MacOS or iOS, install the following applications:
- Xcode
- cmake
Open a terminal.
Set the PATH variable so that the cmake executable is found.
Then run `./build-all.sh`


iOS
---
In addition to the steps required for MacOS, you also need to set the APPLE_DEVELOPER_TEAM environment variable to your developer team id (see https://developer.apple.com/help/account/manage-your-team/locate-your-team-id):

`APPLE_DEVELOPER_TEAM=<your develop team id> ./build-all.sh`

If the examples folder is still in the goopax-X.X.X-iOS directory, the build-all.sh script will know and set the appropriate cmake parameters for iOS.

Then, open build/goopax_examples.xcodeproj and install the programs manually.

