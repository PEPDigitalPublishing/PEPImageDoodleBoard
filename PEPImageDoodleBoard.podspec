
Pod::Spec.new do |s|

    s.name            = 'PEPImageDoodleBoard'

    s.version         = '0.1.0'

    s.summary         = '照片采集、浏览及画笔标注'

    s.license         = 'MIT'

    s.homepage        = 'https://github.com/PEPDigitalPublishing/PEPImageDoodleBoard'

    s.author          = { '崔冉' => 'cuir@pep.com.cn' }

    s.platform        = :ios, '9.0'

    s.source          = { :git => 'https://github.com/PEPDigitalPublishing/PEPImageDoodleBoard' }

    s.source_files    = 'Core/*.{h,m}','Core/pep/*.{h,m}'

    s.resource = 'Core/PEPImageDoodleBoard.bundle'

    s.frameworks      = 'Foundation', 'UIKit', 'AVFoundation'

end
