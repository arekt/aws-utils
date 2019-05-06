require 'json'
require 'yaml'
require "active_support/all"

module ResourceTransform
  def macro(event:, context:)
    fragment = event.dig("fragment")
    requestId = event.dig("requestId")
    output = {
      fragment: transform(fragment),
      status: "success",
      requestId: requestId
    }.deep_stringify_keys
    output
  end

  private

  def content_for_resource(resource)
    base_name = resource["Type"]
    return yield(resource) unless base_name.present?
    file_name = "templates/#{base_name.underscore}.yaml.erb"
    if File.exist?(file_name)
      yield(YAML.load_file(file_name))
    else
      yield(resource) #TODO maybe better to check if Type match "Simple"
    end
  end

  def transform(fragment)
    puts "-- original --"
    puts fragment
    r = fragment["Resources"].map do |key, resource|
      content_for_resource(resource) do |content|
        [ key, content ]
      end
    end
    output = {Resources: Hash[r]}
    puts "-- result --"
    puts output
    output
  end
end
