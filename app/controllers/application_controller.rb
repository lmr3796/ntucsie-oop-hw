class ApplicationController < ActionController::Base
  include ApplicationHelper

  before_filter :set_variables
  protect_from_forgery

  def set_variables
    @homework_number = 3
    @admins = [
      'htlin@csie.ntu.edu.tw',
      'r01922014@csie.ntu.edu.tw',
      'r01922059@csie.ntu.edu.tw',
      'r01944027@csie.ntu.edu.tw',
    ]
  end
end
