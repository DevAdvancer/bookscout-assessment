gem 'xcodeproj'
require 'xcodeproj'

project = Xcodeproj::Project.new('BookScout.xcodeproj')

app_target = project.new_target(:application, 'BookScout', :ios, '17.0')
app_target.product_name = 'BookScout'

debug = project.build_configuration_list['Debug']
release = project.build_configuration_list['Release']
[debug, release].each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['SWIFT_VERSION'] = '6.0'
end

app_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.assessment.bookscout'
  config.build_settings['INFOPLIST_FILE'] = 'App/Info.plist'
  config.build_settings['SWIFT_VERSION'] = '6.0'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
end

app_group = project.main_group.new_group('App', 'App')
app_file = app_group.new_file('BookScoutApp.swift')
assets_file = app_group.new_file('Assets.xcassets')
app_target.add_file_references([app_file])
app_target.resources_build_phase.add_file_reference(assets_file)
app_group.new_file('Info.plist')

package_ref = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
package_ref.relative_path = '.'
project.root_object.package_references << package_ref

%w[BookFeature BookDomain BookData AppCore].each do |product_name|
  dependency = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  dependency.product_name = product_name
  dependency.package = package_ref
  app_target.package_product_dependencies << dependency

  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.product_ref = dependency
  app_target.frameworks_build_phase.files << build_file
end

project.save
