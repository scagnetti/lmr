require 'bundler/capistrano'

# deploy config
set :application, "lmr"
set :user, 'volker'
set :domain, 'h1611578.stratoserver.net'
set :scm, 'git'
set :repository,  "#{user}@#{domain}:/opt/git/lmr.git"
set :git_enable_submodules, 1 # if you have vendored rails
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
set :deploy_to, "/home/volker/#{application}"
set :deploy_via, :export

# roles (servers)
role :web, "#{domain}" 
role :app, "#{domain}" 
role :db,  "#{domain}", :primary => true

# additional settings
default_run_options[:pty] = true

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end
 end
 
# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"