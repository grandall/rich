module Rich
  module Integrations
    module FormHelper
      extend ActiveSupport::Concern

      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::JavaScriptHelper

      def rich_text_area(object_name, method, options = {})
        options = { :language => I18n.locale.to_s }.merge(options)
        input_html = (options.delete(:input_html) || {}).stringify_keys

        instance_tag = ActionView::Base::InstanceTag.new(object_name, method, self, options.delete(:object))
        instance_tag.send(:add_default_name_and_id, input_html)

        object = instance_tag.retrieve_object(nil)
        editor_options = Rich.options(options[:config], object_name, object.id)

        output_buffer = ActiveSupport::SafeBuffer.new
        output_buffer << instance_tag.to_text_area_tag(input_html)

        output_buffer << javascript_tag("$(document).ready(function(){$('##{input_html['id']}').ckeditor(function() { }, #{editor_options.to_json} );});".html_safe)
        output_buffer
      end

      def rich_picker(object_name, method, options = {})
        options = { :language => I18n.locale.to_s }.merge(options)
        input_html = (options.delete(:input_html) || {:class => 'input-file rich-picker'}).stringify_keys

        instance_tag = ActionView::Base::InstanceTag.new(object_name, method, self, options.delete(:object))
        instance_tag.send(:add_default_name_and_id, input_html)

        object = instance_tag.retrieve_object(nil)
        editor_options = Rich.options(options[:config], object_name, object.id)
        if object.send(method).nil?
          image = nil
          image_url = editor_options[:placeholder_image]
        else
          image = object.send(method)
          image_url = image.url(:content)
          input_html.merge!({:value => image.id}) if editor_options[:hidden_input]
        end

        output_buffer = ActiveSupport::SafeBuffer.new
        if editor_options[:hidden_input] == true
          output_buffer << instance_tag.to_input_field_tag('hidden', input_html)
        else
          output_buffer << instance_tag.to_input_field_tag('text', input_html)
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
