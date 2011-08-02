This repository contains the code used to generate an NSIS-based installer for 
the [Dradis Framework](http://dradisframework.org).

Getting Started
---------------

In order to prepare a new installer for a release, you need to clone this repo:

    git clone git@github.com:dradis/w32installer
    cd w32installer

You will also need the latest code from the [dradis/dradisframework](http://github.com/dradis/dradisframework/)
repo. If a tag for this release does not exist yet, go to the 
[wiki](http://github.com/dradis/dradisframework/wiki) and create it.

If the tag already exists, download and uncompress the corresponding tarball:

    https://github.com/dradis/dradisframework/tarball/vX.Y.Z

Rename the resulting folder from **dradis-dradisframework-XXXXX** to **server**.

    mv dradis-dradisframework-* server
    rm server/Gemfile.lock

You also need the _meta_ files (LICENSE, RELEASE_NOTES, etc.), get them from:

    https://github.com/dradis/meta/tarball/vX.Y.Z

Uncompress them under `misc/` and delete the Linux scripts:

    del misc\*.sh

Finally, convert line-end characters to Windows format and add the .txt extension

    ruby -rfileutils -e "Dir['misc/*'].each do |file| FileUtils.mv(file, file+'.txt') if File.file?(file) && !(file =~ /.*txt\Z/); end"
    ruby -rfileutils -e "Dir['misc/*'].each do |file| if( File.file?(file) ) then tmp = File.read(file); f=File.new(file,'wb'); f.write(tmp.gsub(/\n/, \"\r\n\"));  f.close end  end"


Create the install and uninstall includes
-----------------------------------------

In order for NSIS to find all the files used by this Dradis release, we need
to use a helper script to generate an index:

    ruby nsis_folder_dump.rb server server

The output a `server_install.nsh` and a `server_uninstall.nsh` that will be
parsed by NSIS.


Customizing the NSIS script
---------------------------

Open the NSIS script and change the version number in the following locations:

    line 17 - !define PRODUCT_VERSION "x.y.z"
    line 41 - !define MUI_WELCOMEPAGE_TEXT "This wizard wil guide you through the installation of dradis version x.y.z"
    line 75 - OutFile "dradis-vx.y.x-setup.exe"
    line 76 - installDir "$APPDATA\dradis-x.y"

Check if new versions of the **sqlite3**, **bundler**, or **rake** gems are 
available.

Compile the NSIS script and test the installer.


Wrapping up
-----------

After everything is tested and re-tested, commit any changes to your 
`dradis-setup.nsi` script and create the appropiate branch and tag:

    git pull origin master
    git commit dradis-setup.nsi
    git push origin master
    git branch RB-X.Y
    git push -u origin RB-X.Y
    git tag -a vX.Y.Z -m 'Dradis Framework vX.Y.Z'
    git push --tags

