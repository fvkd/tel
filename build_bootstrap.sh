#!/usr/bin/env bash
# Download official bootstrap packages, merge changes and pack zips
ARCHS="aarch64 arm i686 x86_64"

# Iterate the string variable using for loop
BOOTSTRAP_URL="https://github.com/termux/termux-packages/releases/download/bootstrap-"
VERSION="2026.02.15-r1+apt.android-7"
git clone --depth=1 https://github.com/t-e-l/bootstrap-changes
git clone --depth=1 https://github.com/t-e-l/bin
rm -f bin/README.md > /dev/null 2>&1
mv -f bin/* bootstrap-changes/bin/ > /dev/null 2>&1

# Fixes for tel-setup and other scripts
sed -i 's/\bexa\b/eza/g' bootstrap-changes/bin/tel-setup
sed -i 's/\bexa\b/eza/g' bootstrap-changes/bin/tel-edit
sed -i 's/exit 0/exit 1/' bootstrap-changes/bin/tel-helpers
sed -i 's/^check_connection$/check_connection || exit 1/' bootstrap-changes/bin/tel-setup

# My added fixes for tel-setup
sed -i 's/^tel-update/#tel-update/g' bootstrap-changes/bin/tel-setup # Disable self-update
sed -i 's/pkg install/apt-get install -y/g' bootstrap-changes/bin/tel-setup # Replace pkg with apt-get
sed -i 's/\(apt-get install -y \)/\1which /' bootstrap-changes/bin/tel-setup # Install which command
sed -i '106,108s/^/#/' bootstrap-changes/bin/tel-setup # Fix line 106 syntax error
# Ensure sources.list uses grimler.se and apt update allows release info changes
sed -i 's|apt-get update|apt-get update --allow-releaseinfo-change|g' bootstrap-changes/bin/tel-setup # Allow release info change
sed -i 's|termux.org/packages|grimler.se/termux-packages-24|g' bootstrap-changes/bin/tel-setup # Set grimler mirror


for ARCH in $ARCHS; do
    URL=$BOOTSTRAP_URL$VERSION/bootstrap-$ARCH.zip
    echo "working on $ARCH"
    rm -f bootstrap-$ARCH.zip
	echo "downloading orginal bootstrap from $URL"
	wget -O bootstrap-$ARCH.zip $URL > /dev/null 2>&1
	unzip bootstrap-$ARCH.zip -d bootstrap-$ARCH > /dev/null 2>&1
	cp -r bootstrap-changes/* bootstrap-$ARCH 
	# Fix libz.so.1 symlink for apt-get
	ln -sf usr/lib/libz.so.1.3.2 bootstrap-$ARCH/usr/lib/libz.so.1
	cd bootstrap-$ARCH
        rm -f etc/apt/sources.list.d/*.list
	echo "zipping package"
	zip -r ../app/src/main/cpp/bootstrap-$ARCH.zip * > /dev/null 2>&1
	cd ..
	rm -rf bootstrap-$ARCH
done
rm -rf bootstrap-changes
rm -rf bin
