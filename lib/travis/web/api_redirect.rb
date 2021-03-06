require 'sinatra'

class Travis::Web::ApiRedirect < Sinatra::Base
  disable :protection, :static
  set api_endpoint: 'https://api.travis-ci.org'

  class NotPublicImages
    Match = Struct.new(:captures)

    def initialize(pattern, except)
      @except   = except
      @pattern  = pattern
      @captures = Match.new([])
    end

    def match(str)
      @captures if str =~ @pattern && str !~ @except
    end
  end

  get NotPublicImages.new(%r{^/([^/]+)/([^/]+).png}, %r{^/images/}) do
    redirect!
  end

  get '/:owner_name/:name/cc.xml' do
    redirect!
  end

  private

    def public_image?
      params[:owner_name] == 'images'
    end

    def redirect!(path = nil)
      path = File.join(settings.api_endpoint, path || request.fullpath)
      redirect(path, 301)
    end
end
