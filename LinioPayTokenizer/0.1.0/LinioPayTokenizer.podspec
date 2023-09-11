#
# Be sure to run `pod lib lint LinioPayTokenizer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LinioPayTokenizer'
  s.version          = '0.1.1'
  s.summary          = 'LinioPay Tokenizer is the IOS library interface to get customer’s credit card information in a secure way.'
  s.description      = <<-DESC
LinioPay Tokenizer is the IOS library interface to get customer’s credit card information in a secure way. It allows you to set a predetermined
                       DESC
  s.homepage         = 'https://github.com/LinioIT/pay-tokenizer-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Omar Gonzalez' => 'o.gonzalez@linio.com' }
  s.source           = { :git => 'git@github.com:LinioIT/pay-tokenizer-ios.git', :tag => s.version.to_s }
  s.source_files = 'LinioPayTokenizer/**/*'
end
