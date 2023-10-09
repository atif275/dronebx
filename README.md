
to build

. ./b.sh

to run

. ./r.sh

to see on your mac -- on your mac run the following in a saperate terminal

. ./run_in_xpra

once you run the above you should see xterm pop on your your screen
in the xterm you can type and run gazebo

# on your mac

brew install xpra 

# Possible Errors
1. If you see an error containing CRYPTOGRAPHY_OPENSSL_NO_LEGACY try doing the following
    export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=TRUE
2. Down grading xpra to 4.4.9,23 using brew
    brew edit xpra
    HOMEBREW_NO_INSTALL_FROM_API=1 brew reinstall xpra
