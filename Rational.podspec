Pod::Spec.new do |s|
  s.name             = 'Rational'
  s.version          = '0.0.1'
  s.summary          = 'An iOS utility for limiting review requests using SKStoreReviewController.'

  s.description      = <<-DESC
    An iOS utility managing the frequency of asking the SKStoreReviewController for a review, based
    on different types of triggers, app versions, and launch counts.
                       DESC

  s.homepage         = 'https://github.com/zigadolar/rational-rating-utility'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dolar, Ziga' => 'dolar.ziga@gmail.com' }
  s.source           = { :git => 'https://github.com/zigadolar/rational-rating-utility.git', :tag => s.version.to_s }

  s.platform     = :ios, '10.3'
  s.ios.deployment_target = '10.3'
  s.swift_version = '5.0'

  s.ios.source_files = 'Rational/Classes/**/*'
  s.ios.frameworks = 'StoreKit'

end
