module Rich
  module Integrations
    module FormBuilder
      extend ActiveSupport::Concern

      def rich_text_area(method, options = {})
        @template.send("rich_text_area", @object_name, method, objectify_options(options))
      end

      def rich_picker(method, options = {})
        @template.send("rich_picker", @object_name, method, objectify_options(options))
      end
    end
  end
end
