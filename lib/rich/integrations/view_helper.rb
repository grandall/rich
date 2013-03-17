module Rich
  module Integrations
    module ViewHelper
      extend ActiveSupport::Concern

      def rich_text_area_tag(name, content = nil, options = {})
        element_id = sanitize_to_id(name)
        options = { :language => I18n.locale.to_s }.merge(options)
        input_html = { :id => element_id }.merge( options.delete(:input_html) || {} )

        output_buffer = ActiveSupport::SafeBuffer.new
        output_buffer << text_area_tag(name, content, input_html)

        output_buffer << javascript_tag("$(function(){$('##{element_id}').ckeditor(function() { }, #{options.to_json} );});".html_safe)
        output_buffer
      end

      def rich_picker_tag(name, image = nil, options = {})
        element_id = sanitize_to_id(name)
        options = { :language => I18n.locale.to_s }.merge(options)
        input_html = { 'id' => element_id }.merge( options.delete(:input_html) || {} )

        editor_options = Rich.options(options[:config])

        content = nil
        unless image == nil
          image_url = image.url(:content)
          content = image.id if options[:hidden_input]
        else
          image_url = editor_options[:placeholder_image]
        end

        output_buffer = ActiveSupport::SafeBuffer.new
        if editor_options[:hidden_input] == true
          output_buffer << hidden_field_tag(name, content, input_html)
        else
          output_buffer << text_field_tag(name, content, input_html)
        end

        output_buffer << link_to(I18n.t('picker_browse'), Rich.editor[:richBrowserUrl], :class => 'btn')
        if image_url.present?
          output_buffer << content_tag("ul", :class => 'thumbnails') do
            content_tag("li", :class => 'span12') do
              image_tag(image_url, :class => 'rich-image-preview', :size => '260x180')
            end
          end
        end
        output_buffer << javascript_tag("$(document).ready(function(){$('##{input_html['id']} + a').click(function(e){ e.preventDefault(); assetPicker.showFinder('##{input_html['id']}', #{editor_options.to_json.html_safe})})})")
        output_buffer
      end
    end
  end
end
