Pod::Spec.new do |s|
  s.name                  = 'MijickPopups'
  s.summary               = 'Popups, popovers, sheets, alerts, toasts, banners, (...) presentation made simple. Written with and for SwiftUI.'
  s.description           = <<-DESC
  MijickPopups solves two seemingly contradictory problems - to allow developers to create fully customizable popup, and to make the process as simple as possible.
                               DESC
  
  s.version               = '3.0.1'
  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '12.0'
  s.tvos.deployment_target = '15.0'
  s.watchos.deployment_target = '7.0'
  s.visionos.deployment_target = '1.0'
  s.swift_version         = '6.0'
  
  s.source_files          = 'Sources/**/*'
  s.frameworks            = 'SwiftUI', 'Foundation', 'Combine'
  
  s.homepage              = 'https://github.com/Mijick/Popups.git'
  s.license               = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author                = { 'Tomasz Kurylik from Mijick' => 'tomasz.kurylik@mijick.com' }
  s.source                = { :git => 'https://github.com/Mijick/Popups.git', :tag => s.version.to_s }
end
