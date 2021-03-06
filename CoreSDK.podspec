Pod::Spec.new do |spec|
	spec.name                 = 'CoreSDK'
	spec.version              = '1.0.0'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002410625'
	spec.license              = 'Mozilla Public License 2.0'
	spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Core iOS SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-core-sdk.git', :tag => spec.version }
	spec.source_files         = 'Core/**/*.{h,m}'
	spec.public_header_files  = [
                'Core/EMSRequestManager.h',
                'Core/Models/EMSRequestModelBuilder.h',
                'Core/Models/EMSRequestModel.h',
                'Core/Models/EMSResponseModel.h',
                'Core/Models/EMSCompositeRequestModel.h',
                'Core/Repository/RequestModel/EMSRequestModelRepositoryProtocol.h',
                'Core/Repository/RequestModel/EMSRequestModelRepository.h',
                'Core/Repository/EMSRepositoryProtocol.h',
                'Core/Repository/EMSSQLSpecificationProtocol.h',
                'Core/Database/EMSSQLiteHelper.h',
                'Core/Database/EMSModelMapperProtocol.h',
                'Core/Database/EMSRequestContract.h',
                'Core/EMSAuthentication.h',
                'Core/EMSDeviceInfo.h',
                'Core/NSError+EMSCore.h',
                'Core/EMSCoreCompletion.h',
                'Core/Worker/EMSRESTClient.h',
                'Core/EMSTimestampProvider.h'
	]
	spec.libraries = 'z', 'c++', 'sqlite3'
end