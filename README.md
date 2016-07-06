# iAex

## iCloud Authentication Token Extractor (Jailbroken)

A Jailbroken executable which could dump the iCloud account token saved in the iDevices. What is Token ?? If you get it, you wont need to know the credentials or the password to access the iCloud account. You can use it on any other reverse-engineering or educational purposes. (e.g. Elcomsoft Password Breaker's Download from iCloud Account feature). You would need a mac based machine to compile this.
 
Based and enhanced on [Keychain-Dumper](http://github.com/ptoomey3/Keychain-Dumper).

## Building

### Create a Self-Signed Certificate

Open up the Keychain Access app located in /Applications/Utilties/Keychain Access

From the application menu open Keychain Access -> Certificate Assistant -> Create a Certificate

Enter a name for the certificate, and make note of it, as you will need it later when you sign `iAex`.  Make sure the Identity Type is “Self Signed Root” and the Certificate Type is “Code Signing”.  You don’t need to check the “Let me override defaults” unless you want to change other properties on the certificate (name, email, etc).

### Build It

You should be able to compile the project using the included makefile.

    make iAex

If all goes well you should have a binary `iAex` placed in the same directory as all of the other project files.

### Sign It

First we need to find the certificate to use for signing.

    make list

Find the 40 character hex string corresponding to the certificate you generated above. You can then sign `iAex`.

    CER=<40 character hex string for certificate> make codesign

You should now be able to follow the directions specified in the Usage section above.  If you don't want to use the wildcard entitlment file that is provided, you can also sign specific entitlements into the binary.

The resulting file can be used in place of the included entitlements.xml file.

## Contact & Help

If you find a bug you can [open an issue](http://github.com/TwizzyIndy/iAex/issues).
