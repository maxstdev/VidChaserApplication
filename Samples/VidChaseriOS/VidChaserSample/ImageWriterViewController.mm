//
//  ImageReaderViewController.mm
//  VidChaserSample
//
//  Created by 이상훈 on 2017. 5. 31..
//  Copyright © 2017년 이상훈. All rights reserved.
//

#import "ImageWriterViewController.h"
#import "PreferenceData.h"
#import "Definitions.h"
#import "Utils.h"
#import <Accelerate/Accelerate.h>
#import <vector>

using namespace std;

static bool isSaved = false;
static bool initialize = false;
static int imageWidth = 0;
static int imageHeight = 0;
static int frameIndex = 0;
static ColorFormat colorFormat;
static unsigned char* imageBuffer;
static unsigned char* strideBuffer;
static vector<unsigned char> imageBuffers;
static vector<unsigned char> strideBuffers;

@interface ImageWriterViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *stateText;
- (IBAction)ClickButton:(id)sender;
- (IBAction)ClickBackButton:(id)sender;

@end

@implementation ImageWriterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [[PreferenceData getInstance] getResolution: imageWidth : imageHeight];
    colorFormat = [[PreferenceData getInstance] getColorFormat];
    
    self.stateText.text = [NSString stringWithFormat:@"%dX%d / %@ : 000 / 300", imageWidth, imageHeight, ColorFormatValueString(colorFormat)];
    
    self.backBtn.layer.cornerRadius = 10;
    self.backBtn.layer.masksToBounds = YES;
    
    self.startBtn.layer.cornerRadius = 10;
    self.startBtn.layer.masksToBounds = YES;
    
    [self setupGL];
    
    [self startEngine:@"extra"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    VidChaser::setScreenOrientation(ScreenOrientation::LANDSCAPE_LEFT);
}

- (void)setupGL
{
    GLKView *glKitview = (GLKView *)self.view;
    [EAGLContext setCurrentContext:glKitview.context];
    glEnable(GL_DEPTH_TEST);
    
    float screenSizeWidth = self.view.bounds.size.width;
    float screenSizeHeight = self.view.bounds.size.height;
    glViewport(0, 0, screenSizeWidth, screenSizeHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glClearColor(0.0f, 0.0f, 0.0f, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    VidChaser::renderScene();
    
    self.stateText.text = [NSString stringWithFormat:@"%dX%d / %@ : %03d / 300", imageWidth, imageHeight, ColorFormatValueString(colorFormat), frameIndex];

    
    if(isSaved == false)
    {
        self.stateText.text = [NSString stringWithFormat:@"%dX%d / %@ : 000 / 300", imageWidth, imageHeight, ColorFormatValueString(colorFormat)];
        [self.startBtn setTitle:@"START" forState:UIControlStateNormal];
    }
    
    glDisable(GL_DEPTH_TEST);
}

void onNewCameraFrame(Byte * data, int length, int width, int height, ColorFormat format)
{
    if(isSaved)
    {
        if(frameIndex >= 300)
        {
            isSaved = false;
            frameIndex = 0;
            return;
        }
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"/Images"];
        if(initialize == false)
        {
            if(![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            else
            {
                [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
                [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            initialize = true;
        }
        NSString *filename = [NSString stringWithFormat:@"/%03d.img", frameIndex];

        NSMutableData *dstData = [[NSMutableData alloc] init];
        
        int stride = width + 20;
        
        if(colorFormat == ColorFormat::RGBA8888)
        {
            int bufferSize = stride * height * 4;
            if(strideBuffers.size() < bufferSize)
            {
                strideBuffers.resize(bufferSize);
                imageBuffers.resize(bufferSize);
            }
            
            imageBuffer = &imageBuffers[0];
            strideBuffer = &strideBuffers[0];
            
            for(int i = 0; i < width * height; ++i)
            {
                imageBuffer[4 * i] = data[3 * i];
                imageBuffer[4 * i + 1] = data[3 * i + 1];
                imageBuffer[4 * i + 2] = data[3 * i + 2];
                imageBuffer[4 * i + 3] = 255.0f;
            }
            
            int strideSize = (stride - width) * 4;
            unsigned char *zeroBuffer = (unsigned char *) calloc (strideSize, sizeof(char));
            
            unsigned char *tempStride = strideBuffer;
            unsigned char *tempImage = imageBuffer;
            
            for(int i = 0; i < height; ++i)
            {
                memcpy(tempStride, tempImage, sizeof(char) * width * 4);
                memcpy(tempStride, zeroBuffer, sizeof(char) * strideSize);
                tempImage += width * 4;
                tempStride += stride * 4;
            }
            delete [] zeroBuffer;
            
            [dstData appendBytes:[Utils intToByte:width] length:4];
            [dstData appendBytes:[Utils intToByte:height] length:4];
            [dstData appendBytes:[Utils intToByte:colorFormat] length:4];
            [dstData appendBytes:[Utils intToByte:stride] length:4];
            [dstData appendBytes:strideBuffer length: stride * height * 4];
        }
        else if(colorFormat == ColorFormat::RGB888)
        {
            int bufferSize = stride * height * 3;
            if(strideBuffers.size() < bufferSize)
            {
                strideBuffers.resize(bufferSize);
                imageBuffers.resize(bufferSize);
            }
            
            imageBuffer = &imageBuffers[0];
            strideBuffer = &strideBuffers[0];
            
            for(int i = 0; i < width * height; ++i)
            {
                imageBuffer[3 * i] = data[3 * i];
                imageBuffer[3 * i + 1] = data[3 * i + 1];
                imageBuffer[3 * i + 2] = data[3 * i + 2];
            }
            
            int strideSize = (stride - width) * 3;
            unsigned char *zeroBuffer = (unsigned char *) calloc (strideSize, sizeof(char));
            
            unsigned char *tempStride = strideBuffer;
            unsigned char *tempImage = imageBuffer;
            
            for(int i = 0; i < height; ++i)
            {
                memcpy(tempStride, tempImage, sizeof(char) * width * 3);
                memcpy(tempStride, zeroBuffer, sizeof(char) * strideSize);
                tempImage += width * 3;
                tempStride += stride * 3;
            }
            delete [] zeroBuffer;
            
            [dstData appendBytes:[Utils intToByte:width] length:4];
            [dstData appendBytes:[Utils intToByte:height] length:4];
            [dstData appendBytes:[Utils intToByte:colorFormat] length:4];
            [dstData appendBytes:[Utils intToByte:stride] length:4];
            [dstData appendBytes:strideBuffer length: stride * height * 3];
        }
        
        NSString *filePullPath = [folderPath stringByAppendingString:filename];
        [dstData writeToFile:filePullPath atomically:YES];
        
        frameIndex++;
    }
}

- (void)startEngine:(NSString*)path
{
    VidChaser::create("/D1ufge80KUp5yKJYbNKq3klEF9VxHeTaIbUZ7WZwRk=");
    VidChaser::startCamera(0, imageWidth, imageHeight, std::string([path UTF8String]));
    VidChaser::initRendering();
    VidChaser::setPreviewCallback(onNewCameraFrame);
    
    float screenSizeWidth = self.view.bounds.size.width;
    float screenSizeHeight = self.view.bounds.size.height;
    VidChaser::updateRendering(screenSizeWidth, screenSizeHeight);
    [self setStatusBarOrientaionChange];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    VidChaser::updateRendering(size.width, size.height);
    [self setOrientaionChange];
}

- (void)setOrientaionChange
{
    if(UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait)
    {
        VidChaser::setScreenOrientation(ScreenOrientation::PORTRAIT_UP);
    }
    else if(UIDevice.currentDevice.orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        VidChaser::setScreenOrientation(ScreenOrientation::PORTRAIT_DOWN);
    }
    else if(UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft)
    {
        VidChaser::setScreenOrientation(ScreenOrientation::LANDSCAPE_LEFT);
    }
    else if(UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight)
    {
        VidChaser::setScreenOrientation(ScreenOrientation::LANDSCAPE_RIGHT);
    }
}

- (void)setStatusBarOrientaionChange
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationPortrait)
    {
        VidChaser::setScreenOrientation(ScreenOrientation::PORTRAIT_UP);
    }
    else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        VidChaser::setScreenOrientation(ScreenOrientation::PORTRAIT_DOWN);
    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft)
    {
        VidChaser::setScreenOrientation(ScreenOrientation::LANDSCAPE_LEFT);
    }
    else if(orientation == UIInterfaceOrientationLandscapeRight)
    {
        VidChaser::setScreenOrientation(ScreenOrientation::LANDSCAPE_RIGHT);
    }
}


- (IBAction)ClickButton:(id)sender {
    isSaved = !isSaved;
    if(isSaved == true)
    {
        initialize = false;
        [self.startBtn setTitle:@"STOP" forState:UIControlStateNormal];
    }
    else
    {
        frameIndex = 0;
        self.stateText.text = [NSString stringWithFormat:@"%dX%d / %@ : 000 / 300", imageWidth, imageHeight, ColorFormatValueString(colorFormat)];
        [self.startBtn setTitle:@"START" forState:UIControlStateNormal];
    }
}

- (IBAction)ClickBackButton:(id)sender {
    isSaved = false;
    frameIndex = 0;
    self.stateText.text = [NSString stringWithFormat:@"%dX%d / %@ : 000 / 300", imageWidth, imageHeight, ColorFormatValueString(colorFormat)];
    [self.startBtn setTitle:@"START" forState:UIControlStateNormal];
    VidChaser::deinitRendering();
    VidChaser::stopCamera();
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
