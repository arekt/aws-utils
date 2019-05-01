require "spec_helper"
require "yaml"

describe ResourceTransform do
  let :requestId do 123 end
  let :resource do
    { Type: "SimpleResource::S3ApiProxy" }
  end
  let :event do
    { requestId: requestId,
      fragment: {Resources: {Foo: resource, Bar: "bar"}}
    }
  end
  let :output do
    macro(event: event.deep_stringify_keys, context: nil)
  end
  let :final_resources do
    output["fragment"]
  end
  it "first example in first group" do
    expect(final_resources).to eq({"Bar" => "bar", "Foo" => "foo...\n"})
    expect(output["requestId"]).to eq requestId
  end
end
