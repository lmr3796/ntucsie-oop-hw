require 'grit'

class WelcomeController < ApplicationController
  def index
    if session[:email]
      @email = session[:email]
      @id = @email[0...@email.index('@')]
      @submissions = []

      # Create directory only on valid IDs
      return if not /@csie\.ntu\.edu\.tw/ =~ session[:email]
    end
  end

  def history
    @email = session[:email]
    @id = @email[0...@email.index('@')]
    @submissions = []

    # Create directory only on valid IDs
    if not /@csie\.ntu\.edu\.tw/ =~ session[:email]
      render :status => 403
      return
    end

    dest = homework_dest_for(params[:hw_id], @id)
    FileUtils.mkdir_p dest unless File.directory?(dest)
    Dir.foreach(dest) do |f|
      n = f.to_i
      if n.to_s != f
        next
      end

      repo_dir = File.join(dest, f)
      @repo = Grit::Repo.new(repo_dir) rescue nil
      @submissions.push({
        :version  => n,
        :repo     => origin_for(@repo),
        :info     => @repo.commits.first,
        :time     => File::Stat.new(repo_dir).ctime
      }) rescue nil
    end
    @submissions.sort! { |x,y| y[:version] <=> x[:version] }

    render :json => { :status => 'success', :submission => @submissions }
    return
  end
end
