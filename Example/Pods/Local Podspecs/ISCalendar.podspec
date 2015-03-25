#
# Be sure to run `pod lib lint ISCalendar.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ISCalendar"
  s.version          = "0.1.0"
  s.summary          = "A short description of ISCalendar."
  s.description      = <<-DESC
                       Calendar style control alternative to iOS drum date pickers.
                       DESC
  s.homepage         = "https://github.com/ivany4/ISCalendar"
  s.license          = 'MIT'
  s.author           = { "Ivan Sinkarenko" => "ivan.sinkarenko@devbridge.com" }
  s.source           = { :git => "https://github.com/ivany4/ISCalendar.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ISCalendar' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit'
end
