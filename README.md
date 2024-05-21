# Qubic Wallet

Official wallet app for the QUBIC network (https://qubic.org/). Find more about QUBIC on (https://doc.qubic.world/). Find us on discord (https://discord.com/invite/2vDMR8m).

(Initial commit after migration from Q-Hub repo)

## Functionality

- [x] Multi account: Add and manage multiple IDs
- [x] Transfers: Send and receive QUBIC
- [x] Manual resend: Manual resend failed transfers
- [x] Block Explorer: View complete tick / transacation / ID info
- [x] Assets: View shares in your accounts
- [x] Asset transfers: Allow to send and receive shares

## Other features

- [x] Require password to login
- [x] Require password view seed / make transfer
- [x] Biometric authentication (provided that your phone has the required hardware)
- [x] Use QR codes

# Supported Platforms

- [x] Android
- [x] Windows
- [x] Linux
- [ ] iOS - submitted
- [ ] MacOS - submitted
- [ ] Web - submitted

## Distribution

- [x] Android: Signed APK (check qubic-hub releases page)
- [x] Windows: Executable
- [ ] Android: App stores

# Security

All stored data is encrypted via (https://pub.dev/packages/flutter_secure_storage)

- Android : Use of EncryptedSharedPreferences
- iOS: KeyChain
- MacOS: KeyChain
- Windows: Windows Credentials Manager

## Cryptographic operations

### Mobile version

Open source Dart cryptographic libraries for required algorithms state that are not audited / production ready. For this, we are using an embedded web browser
which features the Web Crypto API and use Javascript libs for the cryptographic operations. This is transparent to the end user. Javascript libs are extracted by qubic.li wallet and added as an asset.

### Desktop version

In order to not have to embed a javascript runtime inside the application, for desktop apps, we have compiled the Javascript libs to standalone executables using pkg. You can find them here: https://github.com/Qubic-Hub/qubic-helper-utils
Desktop versions try to locate the appropriate executable and if it's missing it automatically downloads it (or allows the user to manually download it).

### Anti-tampering

Both mobile and desktop version check the Hashes of the assets / executables before using them, in order to prevent tampering.

## Backend

Your keys are never shared to any 3rd party. Yet the wallet uses some backend services:

### Access to Qubic Network

Access to the Qubic Network is currently provided by the wonderful work of (https://www.qubic.org). We are working with a new version to iterface directly with the Computor nodes.

### Version checking

The wallet makes some calls to wallet.qubic-hub.com in order to check for updates or critical fixes.

# Compiling - Downloading - Running

Soon there will be a dedicated compilation manual page. Until then here's some brief instructions:

## Android

- Run : `flutter build apk --split-per-abi` for Android and run the .apk file on your device.

## Windows

- Run : `flutter build windows` to build the windows version. Run it in your windows
- Please note that running the windows version requires the VC++ Redistributables which can be found here(https://www.microsoft.com/en-gb/download/details.aspx?id=48145)

# Contribution - Bug reports

Feel free to contribute to the project. Just create an MR. Feel free to post any found bugs in Issues page. We cannot support you in any case. You are welcome to provide updates, bugfixes or other code changes by pull requests.

# License

Permission is hereby granted, perpetual, worldwide, non-exclusive, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The Software cannot be used in any form or in any substantial portions for development, maintenance and for any other purposes, in the military sphere and in relation to military products, including, but not limited to: a. any kind of armored force vehicles, missile weapons, warships, artillery weapons, air military vehicles (including military aircrafts, combat helicopters, military drones aircrafts), air defense systems, rifle armaments, small arms, firearms and side arms, melee weapons, chemical weapons, weapons of mass destruction;

b. any special software for development technical documentation for military purposes;

c. any special equipment for tests of prototypes of any subjects with military purpose of use;

d. any means of protection for conduction of acts of a military nature;

e. any software or hardware for determining strategies, reconnaissance, troop positioning, conducting military actions, conducting special operations;

f. any dual-use products with possibility to use the product in military purposes;

g. any other products, software or services connected to military activities;

h. any auxiliary means related to abovementioned spheres and products.

The Software cannot be used as described herein in any connection to the military activities. A person, a company, or any other entity, which wants to use the Software, shall take all reasonable actions to make sure that the purpose of use of the Software cannot be possibly connected to military purposes.

The Software cannot be used by a person, a company, or any other entity, activities of which are connected to military sphere in any means. If a person, a company, or any other entity, during the period of time for the usage of Software, would engage in activities, connected to military purposes, such person, company, or any other entity shall immediately stop the usage of Software and any its modifications or alterations.

Abovementioned restrictions should apply to all modification, alteration, merge, and to other actions, related to the Software, regardless of how the Software was changed due to the abovementioned actions.

The above copyright notice and this permission notice shall be included in all copies or substantial portions, modifications and alterations of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Donations

If you want to support us, please donate to WZFSPXPLXKNWFDLNMZHQTGMSRIHBEBITVDUXOSVSZGBREGIUVNWVZBIETEQF
