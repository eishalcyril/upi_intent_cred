#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint upi_intent.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'upi_intent_cred'
  s.version          = '1.0.2'
  s.summary          = 'UPI payments plugin with iOS CRED/GPay fix and SPM support. Fork of upi_intent.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/eishalcyril/upi_intent_cred'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Eishal Cyril' => 'eishalcyril@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files = 'upi_intent/Sources/upi_intent/**/*.swift'
  s.resource_bundles = {'upi_intent_privacy' => ['upi_intent/Sources/upi_intent/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'upi_intent_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
