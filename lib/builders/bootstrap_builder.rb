module Navigasmic
  class BootstrapNavigationBuilder

    @@classnames = {
      :dropdown => 'dropdown',
      :disabled => 'disabled',
      :highlighted => 'active',
      :group_options => {:class=>"dropdown-menu"},
      :dropdown_toggle => 'dropdown-toggle'
    }
    @@wrapper_tag = :ul
    @@group_tag = :ul
    @@item_tag = :li
    @@label_tag = :span

    attr_accessor :template, :name, :items

    def initialize(template, name, options = {}, &proc)
      @template, @name, @items = template, name.to_s, []
      render(options.delete(:html), &proc)
    end

    def render(options, &proc)
      buffer = template.capture(self, &proc)
      template.concat(template.content_tag(@@wrapper_tag, buffer, options))
    end

    def item(label, options = {}, &proc)
      buffer = block_given? ? template.capture(self, &proc) : ''
      unless buffer.blank?
        buffer = template.content_tag(@@group_tag, buffer, @@classnames[:group_options])
      end
      
      item = NavigationItem.new(label, options, template)
      options[:html] ||= {}
      options[:html][:class] = template.add_html_class(options[:html][:class], @@classnames[:disabled]) if item.disabled?
      options[:html][:class] = template.add_html_class(options[:html][:class], @@classnames[:highlighted]) if item.highlighted?(template.request.path, template.params, template)
      options[:html][:class] = template.add_html_class(options[:html][:class], @@classnames[:dropdown]) unless buffer.blank?
      options[:html][:"data-dropdown"] = "dropdown" unless buffer.blank?

      options[:link_html] ||= {}
      options[:link_html][:class] = template.add_html_class(options[:link_html][:class], @@classnames[:dropdown_toggle]) unless buffer.blank?
      
      link = item.link || "#"
      link = link.is_a?(Proc) ? template.instance_eval(&link) : link
      
      label = template.link_to(label, link, options.delete(:link_html))
      
      item.hidden? ? "" : template.content_tag(@@item_tag, label + buffer, options.delete(:html))
    end


  end
end
