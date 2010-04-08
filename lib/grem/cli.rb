require 'optparse'

module Grem
  class CLI
    def self.execute(stdout, arguments=[])

      options = {
      }
      mandatory_options = %w()

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          The (GitHub) REpo Manager (grem) clones a github repo into ~/github/username/reponame.

          Usage: #{File.basename($0)} github_username repo_name

          Options are:
        BANNER
        opts.separator ""
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end

        if arguments.length != 2
          stdout.puts opts; exit
        end
      end

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
  end
end
