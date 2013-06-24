Then /^the file named "(.*?)" is a binary file$/ do |file_name|
  prep_for_fs_check do
    File.binary? file_name
  end
end

When /^I enter my password$/ do
  f = "#{ENV['HOME']}/.gpg_passwd"
  if File.exists? f
    p = File.open(f).first
    type p
  else
    puts "If you use a gpg key with password, please provide it via the file #{f}."
  end
end
