# README

## Name

ChupaText HTTP server

## Description

ChupaText HTTP server is a HTTP interface for ChupaText, an extensible
text extractor. You can use ChupaText via HTTP.

## Overview

You can run ChupaText HTTP server by the following command lines:

```console
% bundle install
% bin/rails server
```

ChupaText HTTP server supports the following formats by default:

  * CSV (`.csv`)
  * Office Open XML:
    * Document:
      * `.docx`
      * `.docm`
      * `.dotx`
      * `.dotm`
    * Presentation:
      * `.pptx`
      * `.pptm`
      * `.ppsx`
      * `.ppsm`
      * `.potx`
      * `.potm`
      * `.sldx`
      * `.sldm`
    * Workbook:
      * `.xlsx`
      * `.xlsm`
      * `.xltx`
      * `.xltm`
  * OpenDocument:
    * Presentation (`.odp`)
    * Spreadsheet (`.ods`)
    * Text (`.odt`)
  * XML (`.xml`)

You can enable more formats by adding ChupaText decomposer plugins to
`Gemfile.local`. You can find ChupaText decomposer plugins at
https://rubygems.org/search?query=chupa-text-decomposer- . See also
`Gemfile.local.example`.

For example, you can use
[chupa-text-decomposer-pdf](https://rubygems.org/gems/chupa-text-decomposer-pdf)
to add support for PDF:

```ruby
# Gemfile.local
gem "chupa-text-decomposer-pdf"
```

Note that you need to run `bundle install` again when you change
`Gemfile.local`:

```console
$ bundle install
```

You can use the ChupaText HTTP server by the following command line:

```console
% curl --form data=@hello.pdf http://127.0.0.1:3000/extraction.json
```

ChupaText HTTP server returns the following JSON (formatted):

```json
{
  "mime-type": "application/pdf",
  "uri": "file:///tmp/hello.pdf",
  "path": "/tmp/hello20190328-10015-hcaahd.pdf",
  "size": 6567,
  "texts": [
    {
      "mime-type": "text/plain",
      "uri": "file:///tmp/hello.txt",
      "path": "/tmp/hello.txt",
      "size": 6,
      "created_time": "2014-01-05T06:35:43.000Z",
      "source-mime-types": [
        "application/pdf"
      ],
      "creator": "Writer",
      "producer": "LibreOffice 4.1",
      "body": "Page1\n",
      "screenshot": {
        "mime-type": "image/png",
        "data": "iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAIAAAAiOjnJAAAABmJLR0QA/wD/\nAP+gvaeTAAACbklEQVR4nO3aoa0CURRFUeYHJD0g6YMS6JQOqAGPIVjyNIj5\nRcDOELJWBUdsccWd5nlewaf9LT2A3yQsEsIiISwSwiIhLBLCIiEsEsIiISwS\nwiIhLBLCIrFeesDqdDo9n8/j8Xi9XscYY4zD4bD0KN61fFhjjPv9/ng8zufz\n7Xbb7/ev12uz2Sy9i7dM3/CPNc/zNE2Xy2W73e52u6Xn8AFfERa/x/FOQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\nhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgk\n/gFl5TA2XANYHwAAAABJRU5ErkJggg==\n",
        "encoding": "base64"
      }
    }
  ]
}
```

You can specify the URL to be extracted:

```console
% curl \
  --data uri=https://github.com/ranguba/chupa-text-http-server/raw/master/test/fixtures/files/hello.docx \
  http://127.0.0.1:3000/extraction.json
```

ChupaText HTTP server returns the following JSON (formatted):

```console
{
  "mime-type": "application/octet-stream",
  "uri": "https://github.com/ranguba/chupa-text-http-server/raw/master/test/fixtures/files/hello.docx",
  "size": 4110,
  "texts": [
    {
      "mime-type": "text/plain",
      "uri": "https://github.com/ranguba/chupa-text-http-server/raw/master/test/fixtures/files/hello.txt",
      "size": 7,
      "title": "Hello",
      "created_time": "2017-07-10T18:00:16.000Z",
      "modified_time": "2017-07-10T18:00:43.000Z",
      "source-mime-types": [
        "application/octet-stream"
      ],
      "application": "LibreOffice/5.3.4.2$Linux_X86_64 LibreOffice_project/30m0$Build-2",
      "body": "World!\n"
    }
  ]
}
```

You can use ChupaText HTTP server as container. See also:

  * [chupa-text-docker](https://github.com/ranguba/chupa-text-docker)

  * [chupa-text-vagrant](https://github.com/ranguba/chupa-text-vagrant)

## API

The end point URL is `http://#{HOST}:#{PORT}/extraction.json`.

You must specify `data` or `uri` parameter. If you want to extract
text from local file, you can use `data` parameter. If you want to
extract text from remote file, you can use `uri` parameter.

If you use `data`, you must send `data` as `multipart/form-data` or
`application/x-www-form-urlencoded`.

If you use `multipart/form-data`, you must specify `filename` of the
data too. You can also specify `content-type` of the data too.

If you use `application/x-www-form-urlencoded`, you must specify
`mime_type` parameter too. It's MIME type of the data.

Metadata are helpful to choose correct decomposer. Decomposer is a
ChupaText module to extract text from the specific data.

Here are optional parameters:

  * `timeout`: The max seconds to extract texts from the given data.

  * `limit_cpu`: The max amount of CPU time in seconds of external
    process. ChupaText may use external command such as `libreoffice`
    to extract text from data.

  * `limit_as`: The max size of the virtual memory of external
    process. ChupaText may use external command such as `libreoffice`
    to extract text from data.

  * `max_body_size`: The max body size to be extracted.

## Authors

  * Kouhei Sutou `<kou@clear-code.com>`

  * Shimadzu Corporation

## License

GPL 3 or later.

(Kouhei Sutou has a right to change the license including contributed
patches.)
