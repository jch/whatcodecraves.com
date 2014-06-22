require 'pathname'

# Skipping capistrano in favor of simpler rsync deployment
namespace :deploy do
  def root
    Pathname.new(File.expand_path('../../..', __FILE__))
  end

  def host
    @host = ENV['DEPLOY_HOST'] || "jch@whatcodecraves.com"
  end

  def remote(*cmd)
    cmd = "ssh #{host} 'cd #{root.basename} && #{cmd * ' && '}'"
    puts cmd
    system(cmd)
  end

  # @param [String] filename relative path to conf file to root
  # @param [Hash] options
  # @option options [String] :output relative or absolute path to output
  def template(filename, options = {})
    options = {
      output: root + filename.gsub('.erb', '')
    }.merge(options)
    options[:output] = Pathname.new(options[:output])

    template = ERB.new((root + filename).read)
    options[:output].open('w') do |f|
      f.puts(template.result(binding))
    end
  end

  task :code do
    remote "git pull origin master"
  end

  task :bundle do
    remote "bundle install --quiet --without debug"
  end

  task :config do
    remote "rake deploy:config_remote",
      "sudo cp config/apache.conf /etc/apache2/sites-enabled/whatcodecraves.com",
      "sudo service apache2 reload"
  end

  task :config_remote do
    template "config/apache.conf.erb"
  end

  task :assets do
    remote "rake assets:precompile"
  end

  task :restart do
    remote 'touch tmp/restart.txt'
  end

  # @see [sitemap_generator](https://github.com/kjvarga/sitemap_generator)
  desc "Write sitemap to public. Uses BASE_URL as anchor"
  task :sitemap do
    remote "BASE_URL=http://whatcodecraves.com foreman run rake util:sitemap"
  end
end

task deploy: ['deploy:code', 'deploy:bundle', 'deploy:sitemap', 'deploy:assets', 'deploy:restart']