Getting Started
---------------

In order to prepare a new installer for a [Dradis Framework](http://dradisframework.org)
release, you need to clone this repo:

    git clone git@github.com:dradis/w32installer
    cd w32installer

You will also need the latest code from the [dradis/dradisframework](http://github.com/dradis/dradisframework/)
repo. If a tag for this release does not exist yet, go to the 
[wiki](http://github.com/dradis/dradisframework/wiki) and create it.

If the tag already exists, download and uncompress the corresponding tarball:

    https://github.com/dradis/dradisframework/tarball/REL-X.Y.Z

Rename the resulting folder from **dradis-dradisframework-XXXXX** to **server**.

You also need the _meta_ files (LICENSE, RELEASE_NOTES, etc.), get them from:

    https://github.com/dradis/meta/tarball/REL-X.Y.Z

Uncompress them under `misc/` and delete the Linux scripts:

    del misc\*.sh

Finally, convert line-end characters to Windows format and add the .txt extension

    ruby -rfileutils -e "Dir['misc/*'].each do |file| FileUtils.mv(file, file+'.txt') if File.file?(file) && !(file =~ /.*txt\Z/); end"
    ruby -rfileutils -e "Dir['misc/*'].each do |file| if( File.file?(file) ) then tmp = File.read(file); f=File.new(file,'wb'); f.write(tmp.gsub(/\n/, \"\r\n\"));  f.close end  end"


