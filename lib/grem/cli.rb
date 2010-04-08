require 'optparse'
require 'launchy'
require 'pathname'

module Grem
  class CLI
    def self.execute(stdout, arguments=[])
      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          The (GitHub) REpo Manager (grem) clones a github repo into ~/github/username/reponame.

          Cloning:

            #{File.basename($0)} github_username repo_name

            Clones a repo to ~/github/\#{github_username}/\#{repo_name}

          Browsing:

            #{File.basename($0)}

            Browses to a page on GitHub based on the current directory.
            ~/github goes to http://github.com/
            ~/github/benatkin goes to http://github.com/benatkin
            ~/github/benatkin/grem and deeper goes to http://github.com/benatkin/grem
            outside ~/github prints a friendly error message

          Options are:
        BANNER
        opts.separator ""
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if arguments.length == 2
          self.clone(stdout, arguments)
        elsif arguments.length == 0
          self.browse(stdout, arguments)
        else
          stdout.puts opts; exit
        end
      end
    end

    def self.clone(stdout, arguments=[])
      username = arguments[0]
      reponame = arguments[1]

      #FileUtils.mkdir_p
      user_path = File.join(File.expand_path('~/github'), username)
      repo_path = File.join(user_path, reponame)
      if File.exist?(repo_path)
        stdout.puts "A file already exists at #{repo_path}. Exiting."; exit
      end
      
      remote_path = "git://github.com/#{username}/#{reponame}.git"

      FileUtils.mkdir_p(user_path)
      FileUtils.chdir(user_path) do
        system('git', 'clone', remote_path)
      end
    end

    def self.browse(stdout, arguments=[])
      url = 'http://github.com/'

      github = Pathname.new(File.expand_path('~/github'))
      here = Pathname.new(Dir.pwd)
      if self.is_under(here, github) then
        relative = here.relative_path_from(github).to_s
        while true
          break if File.split(File.split(relative)[0])[0] ==
            File.split(File.split(File.split(relative)[0])[0])[0]
          relative = File.split(relative)[0]
        end
        url += relative if relative != '.'
      else
        stdout.puts 'It appears that you are not in ~/github. For usage info, run "grem --help".'
        exit
      end
      Launchy.open(url)
    end

    def self.is_under(here, github)
      while here.parent != here
        return true if here == github
        here = here.parent
      end
      return false
    end
  end
end
