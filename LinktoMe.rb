Capability = ["Log","Ecell","Reg","File_list","Cfg_file"]
if RUBY_VERSION.eql?("2.2.2")
	require "Time"
	require "find"
	require "win32ole"
else
	require "Time"
	require "fileutils"
	require "find"
	require "win32ole"
end


Capability.each do |cap|
	require "#{$path_this}/Bin/#{cap}"
	include Object.const_get "#{cap}"
	#puts "Using my defined ability of #{cap}~"
end

