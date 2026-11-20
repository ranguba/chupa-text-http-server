# News

## 1.0.9: 2026-11-20

### Improvements

  * Updated Ruby on Rails to 8.1.
    [GitHub#37][Reported by escooterclinic]

  * Required Ruby 3.2 or later.

  * Dropped Webpacker. Node.js and Yarn aren't needed anymore.

  * Added rubygems-requirements-system as a Bundler plugin. System
    dependencies of decomposers are installed automatically by
    `bundle install`.

  * Changed not to escape `<`, `>`, `&`, U+2028 and U+2029 in JSON
    responses. This is the default behavior of Ruby on Rails 8.1.

  * Added description about `Gemfile.local`.
    [GitHub#17][Reported by Tomohisa Kusukawa]

### Thanks

  * escooterclinic

  * Tomohisa Kusukawa

## 1.0.8: 2021-04-12

### Fixes

  * Removed needless Action Cable related codes.

## 1.0.7: 2021-03-30

### Improvements

  * Updated Ruby on Rails to 6.1.

## 1.0.6: 2021-03-26

### Improvements

  * Added `mime_type` parameter for text data.

## 1.0.5: 2021-03-26

### Improvements

  * Added support for text as `data` parameter.

## 1.0.4: 2019-06-18

### Improvements

  * Added support for `need_screenshot` parameter.

## 1.0.3: 2019-06-14

### Improvements

  * Required chupa-text 1.3.0 or later.

## 1.0.2: 2019-06-10

### Improvements

  * Released temporary resources immediately.

## 1.0.1: 2019-03-29

### Improvements

  * Cached extractor.

## 1.0.0: 2019-03-28

The first release!!!
