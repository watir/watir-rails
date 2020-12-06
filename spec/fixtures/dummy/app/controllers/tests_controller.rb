class TestsController < ApplicationController
  def index
    if Gem::Version.new(Rails.version) < Gem::Version.new('4.1')
      render text: 'Hello world!'
    else
      render plain: 'Hello world!'
    end
  end

  def raise_error
    raise 'watir-rails test message'
  end
end
