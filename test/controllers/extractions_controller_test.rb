require 'test_helper'

class ExtractionsControllerTest < ActionDispatch::IntegrationTest
  setup do
  end

  def run_http_server(content_type: nil, body: nil, status: nil)
    config = {
      :Port => 0,
      :Logger => Rails.logger,
      :AccessLog => [
        [Rails.logger, WEBrick::AccessLog::COMMON_LOG_FORMAT],
      ],
    }
    server = WEBrick::HTTPServer.new(config)
    path = "/data"
    server.mount_proc(path) do |request, response|
      response.content_type = content_type
      response.body = body
      response.status = status if status
    end
    server_thread = Thread.new do
      server.start
    end
    begin
      port = server[:Port]
      yield("http://127.0.0.1:#{port}#{path}")
    ensure
      server.shutdown
      server_thread.join
    end
  end

  sub_test_case "browser" do
    test "root" do
      get root_url
      assert_redirected_to extraction_url
    end

    test "#show" do
      get extraction_url
      assert_response :success
    end

    sub_test_case "#create" do
      test "no params" do
        visit(extraction_url)
        click_button("Extract")
        within("#error_explanation") do
          assert_equal(["Data can't be blank"],
                       all("li").collect(&:text))
        end
      end

      test "URI" do
        visit(extraction_url)
        run_http_server(content_type: "text/plain", body: "Hello") do |uri|
          fill_in("URI", with: uri.to_s)
          click_button("Extract")
          assert_equal(["Hello"],
                       all(".text pre").collect(&:text))
        end
      end

      sub_test_case "data" do
        def assert_extract(expected, fixture_name)
          visit(extraction_url)
          attach_file("Data", file_fixture(fixture_name))
          click_button("Extract")
          extracted = all(".text").collect do |node|
            [
              node.find(".metadata-title td").text,
              node.find(".body").text,
            ]
          end
          assert_equal(expected, extracted)
        end

        test "HTML" do
          assert_extract([["Hello", "World!"]], "hello.html")
        end

        test "OpenDocument Text" do
          assert_extract([["Hello", "World!"]], "hello.odt")
        end

        test "Word: old" do
          assert_extract([["Hello", "World!"]], "hello.doc")
        end

        test "Word" do
          assert_extract([["Hello", "World!"]], "hello.docx")
        end

        test "OpenDocument Spreadsheet" do
          assert_extract([
                           [
                             "Hello",
                             "Sheet1 A1 Sheet1 A2 Sheet1 B1 " +
                             "Sheet2 A1 Sheet2 A2 Sheet2 B1",
                           ],
                         ],
                         "hello.ods")
        end

        test "Excel: old" do
          assert_extract([
                           [
                             "Hello",
                             "Sheet1 A1 Sheet1 A2 Sheet1 B1 " +
                             "Sheet2 A1 Sheet2 A2 Sheet2 B1",
                           ],
                         ],
                         "hello.xls")
        end

        test "Excel" do
          assert_extract([
                           [
                             "Hello",
                             "Sheet1 A1 Sheet1 A2 Sheet1 B1 " +
                             "Sheet2 A1 Sheet2 A2 Sheet2 B1",
                           ],
                         ],
                         "hello.xlsx")
        end

        test "OpenDocument Presentation" do
          assert_extract([
                           [
                             "Hello",
                             "Page1 Title Page1 Content " +
                             "Page2 Title Page2 Content",
                           ]
                         ],
                         "hello.odp")
        end

        test "PowerPoint: old" do
          assert_extract([
                           [
                             "Hello",
                             "Page1 Title Page1 Content " +
                             "Page2 Title Page2 Content",
                           ]
                         ],
                         "hello.ppt")
        end

        test "PowerPoint" do
          assert_extract([
                           [
                             "Hello",
                             "Page1 Title Page1 Content " +
                             "Page2 Title Page2 Content",
                           ]
                         ],
                         "hello.pptx")
        end
      end
    end
  end

  sub_test_case "API" do
    sub_test_case "URI" do
      test "success" do
        run_http_server(content_type: "text/plain", body: "Hello") do |uri|
          post(extraction_url(format: "json"),
               params: {
                 uri: uri,
               })
          assert_equal("application/json", response.content_type,
                       response.body)
          extracted = JSON.parse(response.body)["texts"].collect do |text|
            text["body"]
          end
          assert_equal(["Hello"], extracted)
        end
      end

      test "not found" do
        run_http_server(content_type: "text/plain", body: "Hello") do |uri|
          nonexistent_uri = URI.parse(uri)
          nonexistent_uri.path = "/nonexistent"
          post(extraction_url(format: "json"),
               params: {
                 uri: nonexistent_uri.to_s,
               })
          assert_response(:unprocessable_entity)
          assert_equal("application/json", response.content_type,
                       response.body)
          assert_equal({
                         "uri" => [
                           "Download error: <#{nonexistent_uri}>: 404 Not Found",
                         ],
                       },
                       JSON.parse(response.body))
        end
      end

      test "internal server error" do
        run_http_server(content_type: "text/plain",
                        body: "Error",
                        status: 500) do |uri|
          post(extraction_url(format: "json"),
               params: {
                 uri: uri,
               })
          assert_response(:unprocessable_entity)
          assert_equal("application/json", response.content_type,
                       response.body)
          assert_equal({
                         "uri" => [
                           "Download error: <#{uri}>: 500 Internal Server Error",
                         ],
                       },
                       JSON.parse(response.body))
        end
      end
    end

    sub_test_case "data" do
      def assert_extract(expected, fixture_name)
        post(extraction_url(format: "json"),
             params: {
               data: fixture_file_upload(file_fixture(fixture_name)),
             })
        assert_equal("application/json", response.content_type,
                     response.body)
        extracted = JSON.parse(response.body)["texts"].collect do |text|
          [text["title"], text["body"]]
        end
        assert_equal(expected, extracted)
      end

      test "HTML" do
        assert_extract([["Hello", "World!"]], "hello.html")
      end

      test "OpenDocument Text" do
        assert_extract([["Hello", "World!\n"]], "hello.odt")
      end

      test "Word: old" do
        assert_extract([["Hello", "World!\n"]], "hello.doc")
      end

      test "Word" do
        assert_extract([["Hello", "World!\n"]], "hello.docx")
      end

      test "OpenDocument Spreadsheet" do
        assert_extract([
                         [
                           "Hello",
                           "Sheet1 A1\nSheet1 A2\nSheet1 B1\n" +
                           "Sheet2 A1\nSheet2 A2\nSheet2 B1\n",
                         ],
                       ],
                       "hello.ods")
      end

      test "Excel: old" do
        assert_extract([
                         [
                           "Hello",
                           "Sheet1 A1\nSheet1 A2\nSheet1 B1\n" +
                           "Sheet2 A1\nSheet2 A2\nSheet2 B1\n",
                         ],
                       ],
                       "hello.xls")
      end

      test "Excel" do
        assert_extract([
                         [
                           "Hello",
                           "Sheet1 A1\nSheet1 A2\nSheet1 B1\n" +
                           "Sheet2 A1\nSheet2 A2\nSheet2 B1\n",
                         ],
                       ],
                       "hello.xlsx")
      end

      test "OpenDocument Presentation" do
        assert_extract([
                         [
                           "Hello",
                           "Page1 Title\nPage1 Content\n" +
                           "Page2 Title\nPage2 Content\n",
                         ]
                       ],
                       "hello.odp")
      end

      test "PowerPoint: old" do
        assert_extract([
                         [
                           "Hello",
                           "Page1 Title\nPage1 Content\n" +
                           "Page2 Title\nPage2 Content\n",
                         ]
                       ],
                       "hello.ppt")
      end

      test "PowerPoint" do
        assert_extract([
                         [
                           "Hello",
                           "Page1 Title\nPage1 Content\n" +
                           "Page2 Title\nPage2 Content\n",
                         ]
                       ],
                       "hello.pptx")
      end
    end
  end
end
