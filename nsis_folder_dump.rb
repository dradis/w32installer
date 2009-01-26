require 'fileutils'
include FileUtils::Verbose

def recursive_folder_dump(folder, install_file, uninstall_file, relative_path)
  cd(folder) {
    Dir.foreach('.\\') { |inner_file|
      if File.directory?(inner_file) && inner_file != '.' && inner_file != '..'
        install_file.puts "SetOutPath \"$INSTDIR\\" + relative_path + inner_file + "\""
        recursive_folder_dump(inner_file, install_file, uninstall_file, relative_path + inner_file + "\\")
        uninstall_file.puts "RMDir \"$INSTDIR\\" + relative_path + inner_file + "\""
      elsif inner_file != '.' && inner_file != '..'
        install_file.puts "File \"" + relative_path + inner_file + "\""
        uninstall_file.puts "Delete \"$INSTDIR\\" + relative_path + inner_file + "\""
      end
    }
  }
end


if ARGV[1] == nil
  puts 'usage: ruby nsis_folder_dump.rb <folder> <id>'
  puts 'where:'
  puts '<folder> - is the folder/file structure to be dumped'
  puts '<id> - will be used to create the output file names: <id>_install.nsi and <id>_uninstall.nsi'
  exit
end

if !File.exists?(ARGV[0])
  puts ARGV[0] + " is not an existing folder"
  exit  
end

install_file = File.new(ARGV[1]+"_install.nsh",'w')
uninstall_file = File.new(ARGV[1]+"_uninstall.nsh",'w')

install_file.puts "SetOutPath \"$INSTDIR\\" + ARGV[0] + "\""
recursive_folder_dump(ARGV[0], install_file, uninstall_file, ARGV[0] + "\\")
uninstall_file.puts "RMDir \"$INSTDIR\\" + ARGV[0] + "\""

install_file.close

