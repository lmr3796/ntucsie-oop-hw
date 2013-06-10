require 'grit'

class PathController < ApplicationController
  before_filter :check_email, :except => [:help]
  def check_email
    if not /@csie\.ntu\.edu\.tw/ =~ session[:email]
      render :json => { :message => 'Invalid account, please login with your NTU CSIE account.', :error => ''}, :status => 403
      return 
    end
  end
  def git
    @email = session[:email]
    @id = @email[0...@email.index('@')]

    @repo = params[:path].strip

    # create directory & get the newest version
    dest = homework_dest_for(params[:hw_id], @id)
    begin
      version = 0
      if File.directory?(dest)
        Dir.foreach(dest) do |f|
          n = f.to_i
          if n.to_s == f
            version = n if n > version
          end
        end
      else
        Dir.mkdir(dest, 0755)
      end
    rescue SystemCallError => e
      render :json => { :message => 'Failed to create directory.', :error => e.message }, :status => 500
      return
    end
    version += 1
    
    # clone repo
    git = Grit::Git.new(dest)
    repo_dir = File.join(dest, version.to_s)
    info = git.clone({ :timeout => 60, :process_info => true }, @repo, repo_dir)
    if info[0] != 0
      render :json => { :message => 'Git clone failed.', :error => info[2] }, :status => 400 
      return
    end

    # return repo info
    begin
      repo = Grit::Repo.new(repo_dir)
    rescue Grit::NoSuchPathError => e
      render :json => { :message => 'Git clone failed.', :error => e.message }, :status => 400
      return
    end
    head = repo.commits.first
    render :json => { :message => 'Git clone succeeded.', :version => version.ordinalize, :repo => @repo, :info => head }
  end

  def help
  end
end
