require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "error" if already_built_response?
    @res.location = url
    @res.status = 302
    session.store_session(res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "error" if already_built_response?
    @res['Content-Type'] = content_type
    # @res.set_header('body', content)
    @res.write(content)
    session.store_session(res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir_path = File.dirname(__FILE__)
    template_path = File.join(dir_path,"..", "views", ERB.new("<%=self.class.to_s.underscore%>").result(binding),
      "#{template_name}.html.erb")
    temp_code = File.read(template_path)
    render_content(ERB.new(temp_code).result(binding), "text/html")
    
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

