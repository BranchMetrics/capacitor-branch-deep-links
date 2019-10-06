
  Pod::Spec.new do |s|
    s.name = 'CapacitorBranchDeepLinks'
    s.version = '0.0.1'
    s.summary = 'Capacitor plugin for Branch.io deep links'
    s.license = 'MIT'
    s.homepage = 'none'
    s.author = 'Bound State Software'
    s.source = { :git => 'none', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
    s.dependency 'Branch'
  end
