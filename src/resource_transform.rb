require 'json'
require "active_support/all"


module ResourceTransform
  def macro(event:, context:)
    fragment = event.dig("fragment")
    requestId = event.dig("requestId")
    {
      fragment: transform(fragment),
      status: "success",
      requestId: requestId
    }.deep_stringify_keys
  end

  private

  def content_for_resource(resource)
    base_name = resource["Type"]
    return yield(resource) unless base_name.present?
    file_name = "templates/#{base_name.underscore}.yaml.erb"
    yield(File.read(file_name)) if File.exist?(file_name)
  end

  def transform(fragment)
    r = fragment["Resources"].map do |key, resource|
      content_for_resource(resource) do |content|
        [ key, content ]
      end
    end
    Hash[r]
  end
end
