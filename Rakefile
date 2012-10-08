require 'fileutils'

task :default => [:install]

desc "install 3rd-party libs"
task :install do
  shared_lib = "vendor"
  FileUtils.mkdir_p(shared_lib)

  FileUtils.cd("#{shared_lib}");

  [
    ["https://github.com/johnezang/JSONKit.git", "master"],
    ["https://github.com/vicpenap/PrettyKit.git", "master"],
    ["https://github.com/jdg/MBProgressHUD.git", "master"],
    ["https://github.com/samvermette/SVWebViewController.git", "master"],
    ["git@github.com:enormego/EGOTableViewPullRefresh.git", "master"],
  ].each do |lib|
    `git clone #{lib[0]} -b #{lib[1]} --recursive`
  end
end
