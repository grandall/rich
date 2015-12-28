require 'rack/raw_upload'
require "rich/authorize"
    
module Rich
  class Engine < Rails::Engine
    isolate_namespace Rich

    # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
    initializer "rich.add_middleware", :group => :all do |app|
      app.config.assets.precompile += %w[
              ckeditor/ckeditor.js
              ckeditor/config.js
              ckeditor/**/*.js
              ckeditor/**/*.css
              ckeditor/**/*.png
              ckeditor/**/*.gif
              ckeditor/**/*.html
              ckeditor/**/*.md
      ]
      app.middleware.use 'Rack::RawUpload', :paths => ['/rich/files']
    end

    initializer 'rich.include_authorization' do |app|
      ActiveSupport.on_load(:action_controller) do
        include Rich::Authorize
      end
    end

    initializer "rich.integrations" do
      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, Rich::Integrations::ViewHelper
        ActionView::Base.send :include, Rich::Integrations::FormHelper
        ActionView::Helpers::FormBuilder.send :include, Rich::Integrations::FormBuilder
      end
    end

  end
end
