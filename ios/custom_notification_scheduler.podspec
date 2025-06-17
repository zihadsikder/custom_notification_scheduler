#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint custom_notification_scheduler.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'custom_notification_scheduler'
  s.version          = '0.0.1'  # Match with pubspec.yaml version
  s.summary          = 'A Flutter plugin for scheduling notifications with custom sounds and FCM support.'
  s.description      = <<-DESC
                       A Flutter plugin that allows scheduling local notifications with custom sounds, payloads, and FCM token retrieval.
                       DESC
  s.homepage         = 'https://github.com/zihadsikder/custom_notification_scheduler'  # Ensure this is a valid URL
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Zihad Sikder' => 'zihad@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'  # Specify minimum iOS version
  s.swift_version = '5.0'

  # Flutter.framework dependency
  s.prepare_command = <<-CMD
    find . -name '*.xcframework' -type d | while read -r framework; do
      if [ -d "$framework/ios-arm64_armv7" ]; then
        cp -r "$framework/ios-arm64_armv7" "$framework/ios"
      fi
    done
  CMD
end
