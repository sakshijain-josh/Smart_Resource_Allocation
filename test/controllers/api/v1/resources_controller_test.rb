require "test_helper"

class Api::V1::ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @employee = create(:user)
    @resource = create(:resource, name: "Meeting Room X", resource_type: "meeting-room")
  end

  test "should get index" do
    get api_v1_resources_url, headers: auth_headers(@employee), as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json["resources"]
    puts "✅ PASS: All users can list resources"
  end

  test "should show resource" do
    get api_v1_resource_url(@resource), headers: auth_headers(@employee), as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @resource.name, json["name"]
    puts "✅ PASS: Resource details are accessible"
  end

  test "should show availability" do
    get "/api/v1/resources/#{@resource.id}/availability",
        headers: auth_headers(@employee),
        as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert json["available_slots"].present?
    puts "✅ PASS: Resource availability endpoint functional"
  end

  test "admin can create resource" do
    assert_difference("Resource.count") do
      post api_v1_resources_url,
           params: { name: "New Lab", resource_type: "meeting-room", location: "Block C" },
           headers: auth_headers(@admin),
           as: :json
    end
    assert_response :created
    puts "✅ PASS: Admin can create resources"
  end

  test "employee cannot create resource" do
    post api_v1_resources_url,
         params: { name: "Hackers Den", resource_type: "meeting-room" },
         headers: auth_headers(@employee),
         as: :json
    assert_response :forbidden
    puts "✅ PASS: Unauthorized resource creation blocked (Security)"
  end

  test "admin can update resource" do
    patch api_v1_resource_url(@resource), params: { name: "Updated Room X" }, headers: auth_headers(@admin), as: :json
    assert_response :success
    assert_equal "Updated Room X", @resource.reload.name
    puts "✅ PASS: Admin can update resources"
  end

  test "admin can delete resource" do
    assert_difference("Resource.count", -1) do
      delete api_v1_resource_url(@resource), headers: auth_headers(@admin), as: :json
    end
    assert_response :no_content
    puts "✅ PASS: Admin can delete resources"
  end
end
