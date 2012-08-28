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

      def rich_picker_tag(name, content = nil, options = {})
        element_id = sanitize_to_id(name)
        options = { :language => I18n.locale.to_s }.merge(options)
        input_html = { :id => element_id }.merge( options.delete(:input_html) || {} )

        output_buffer = ActiveSupport::SafeBuffer.new
        output_buffer << text_field_tag(name, content, input_html)

        output_buffer << link_to(I18n.t('picker_browse'), Rich.editor[:richBrowserUrl], :class => 'button')
        output_buffer << image_tag(@object.send(method), :class => 'rich-image-preview', :style => 'height: 100px')
        output_buffer << javascript_tag("$(function(){$('##{input_html['id']} a').click(function(e){ e.preventDefault(); assetPicker.showFinder('##{input_html['id']}', #{options.to_json.html_safe})})})")
        output_buffer
      end
    end
  end
end
