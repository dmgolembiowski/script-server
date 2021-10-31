#!/bin/bash

# Copy assets from the samples directory for first-time users
pushd samples
cp -ar ./* ../conf/ &
wait $!

# Overwrite the unhelpful default conf.json with one that better suits
# a standard use-case
echo -e "{\n    \"access\": {\n        \"code_editors\": [\"*\"]\n    }\n}" > ../conf/conf.json &
wait $!

rm -r ../conf/{ldap,ssl}/ 
mkdir -p ../conf/runners && mv ../conf/scripts/* ../conf/runners/ && rm -r ../conf/scripts
mkdir -p ../conf/schedules
popd

function install_deps() {
    /usr/bin/env python3 -m pip install \
        --user \
        --trusted-host pypi.org \
        --trusted-host files.pythonhosted.org \
        -r requirements.txt
}

# Ask the user if they want to install dependencies for the script-server
read -p "Install Python dependencies (y/n)?" choice
case "$choice" in
  n|N|no|No ) echo "Skipping installation" ;;
  * ) install_deps && echo "Done" ;;
esac

# Optionally has the developer download static files en lieu of building from source
read -p "Run tools/init.py (y/n)?" choice
case "$choice" in
  n|N|no|No ) echo "Skipping installation" ;;
  * ) /usr/bin/env python3 tools/init.py --no-npm ;;
esac


echo "If nothing gave you an error, go ahead and run \"python3 launcher.py\""
