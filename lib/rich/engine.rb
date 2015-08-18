require 'rack/raw_upload'
require "rich/authorize"
    
module Rich
  class Engine < Rails::Engine
    isolate_namespace Rich

    initializer "rich.add_middleware" do |app|
      app.config.assets.precompile += %W(
              ckeditor/*.js
              ckeditor/*.css
              ckeditor/*.png
              ckeditor/*.gif
              ckeditor/*.html
              ckeditor/*.md
      )
      app.middleware.use 'Rack::RawUpload', :paths => ['/rich/files']
    end

    initializer 'rich.include_authorization' do |app|
      ActiveSupport.on_load(:action_controller) do
        include Rich::Authorize
      end
    end
<<<<<<< HEAD

    initializer "rich.integrations" do
      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, Rich::Integrations::ViewHelper
        ActionView::Base.send :include, Rich::Integrations::FormHelper
        ActionView::Helpers::FormBuilder.send :include, Rich::Integrations::FormBuilder
      end
    end

=======
>>>>>>> upstream/master
  end
end
