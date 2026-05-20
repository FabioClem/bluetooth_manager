#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint bluetooth_manager.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'bluetooth_manager'
  s.version          = '2.0.0'
  s.summary          = 'Flutter plugin to read and observe the Bluetooth adapter state on Android, iOS and macOS.'
  s.description      = <<-DESC
A lightweight Flutter plugin that exposes the current Bluetooth adapter
state, streams state changes through an EventChannel and, on Android,
allows enabling/disabling the adapter (with the Android 13+ caveat). On
iOS and macOS the plugin reads the state via CoreBluetooth and can open
the system Bluetooth settings screen.
                       DESC
  s.homepage         = 'https://github.com/FabioClem/bluetooth_manager'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FabioClem' => 'https://github.com/FabioClem' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.13'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
