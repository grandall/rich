module Rich
  module Integrations
    module FormHelper
      extend ActiveSupport::Concern

      def rich_text_area(object_name, method, options = {})
        Rich::Integrations::RichTextArea.new(object_name, method, self, options).render
      end

      def rich_picker(object_name, method, options = {})
        Rich::Integrations::RichPicker.new(object_name, method, self, options).render
      end

    end

    class RichTextArea < ActionView::Helpers::Tags::Base
      def render
        options = @options.stringify_keys
        add_default_name_and_id(options)

        editor_options = Rich.options(options.delete('config'), @object_name, options['id'])

        output = ActiveSupport::SafeBuffer.new
        output << @template_object.content_tag("textarea", options.delete("value") { value_before_type_cast(@object) }, options)
        #output << @template_object.javascript_tag("$(document).ready(function(){CKEDITOR.replace('#{options['id']}', #{editor_options.to_json})});".html_safe)
        output
      end
    end

    class RichPicker < ActionView::Helpers::Tags::Base
      def render
        options = @options.stringify_keys
        add_default_name_and_id(options)

        editor_options = Rich.options(options.delete('config'), @object_name, options['id'])

        image = value(@object)
        if image.nil?
          image_url = editor_options[:placeholder_image]
        else
          image_url = image.url(:content)
        end

        output = ActiveSupport::SafeBuffer.new

        if editor_options[:hidden_input]
          output << @template_object.hidden_field_tag(options['name'], image.try(:id), options)
        else
          output << @template_object.text_field_tag(options['name'], options['value'], options)
        end

        output << @template_object.link_to(I18n.t('picker_browse'), Rich.editor[:richBrowserUrl], :class => 'btn')
        if image_url.present?
          output << @template_object.content_tag('ul', :class => 'thumbnails') do
            @template_object.content_tag('li', :class => 'span12') do
              @template_object.image_tag(image_url, :class => 'rich-image-preview', :size => '260x180')
            end
          end
        end

        output << @template_object.javascript_tag("$(document).ready(function(){$('##{options['id']} + a').click(function(e){ e.preventDefault(); assetPicker.showFinder('##{options['id']}', #{editor_options.to_json.html_safe})})})")

        output

      end
    end
  end
end
