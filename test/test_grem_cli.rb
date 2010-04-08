require File.join(File.dirname(__FILE__), "test_helper.rb")
require 'grem/cli'

class TestGremCli < Test::Unit::TestCase
  def setup
    @example_path = File.join(File.expand_path('~/github'), 'benatkin', 'example')
    exit unless @example_path.include?('example') # sanity check
    FileUtils.rm_rf(@example_path)
    Grem::CLI.execute(@stdout_io = StringIO.new, ['benatkin', 'example'])
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end
  
  def test_repo_cloned
    readme_path = File.join(@example_path, 'README')
    assert_match(/You have reached this example repo/, readme_path)
  end
end
