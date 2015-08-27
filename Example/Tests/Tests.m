//
//  PhotoBrowserDemoTests.m
//  PhotoBrowserDemoTests
//
//  Created by DevDivinity
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "IDMPhotoBrowser.h"

@interface PhotoBrowserDemoTests : XCTestCase
{
    IDMPhoto *photo;
    IDMPhotoBrowser *browser;
}
@end

@implementation PhotoBrowserDemoTests

- (void)setUp {
    [super setUp];
    
    photo = [IDMPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"newPhoto" ofType:@"jpg"]];
    photo.captionFont = [UIFont fontWithName:@"verdana" size:14];
    photo.titleFont = [UIFont fontWithName:@"Arial" size:20];
    photo.title = @"Dev Divinity";
    photo.caption = @"The London Eye is a giant Ferris ";
    
    browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPhotoBrowser {
    
    XCTAssertNotNil(photo.captionFont);
    XCTAssertNotNil(photo.titleFont);
    XCTAssertNotNil(photo.title);
    XCTAssertNotNil(photo.caption);
    XCTAssertEqualObjects([browser photoAtIndex:0], photo);
    
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

@end
