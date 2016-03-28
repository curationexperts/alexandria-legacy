# https://gist.github.com/bmaddy/4567fad5aa55e5a600e1
#
# On Vagrant, Passenger is run under Apache, so EXPLAIN_PARTIALS must
# be set in /etc/sysconfig/httpd; see
# https://www.phusionpassenger.com/library/indepth/environment_variables.html
if Rails.env.development? || ENV['EXPLAIN_PARTIALS']
  module ActionView
    class PartialRenderer
      def render_with_explanation(*args)
        rendered = render_without_explanation(*args).to_s
        # Note: We haven't figured out how to get a path when @template is nil.
        start_explanation = "\n<!-- START PARTIAL #{@template.inspect} -->\n"
        end_explanation = "\n<!-- END PARTIAL #{@template.inspect} -->\n"
        start_explanation.html_safe + rendered + end_explanation.html_safe
      end

      alias_method_chain :render, :explanation
    end
  end
end
