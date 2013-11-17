//
//  TWBSocialHelper.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 13/10/2013.
//  Copyright (c) 2013 TheWorkingBear. All rights reserved.
//

#import "TWBSocialHelper.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TWBSocialHelper ()

@property (nonatomic) ACAccountStore *facebookAccountStore;

/**
 For Facebook SLRequest methods, each app needs a Facebook App ID. This can be setup at https://developers.facebook.com.
 The name of the app shows up on Facebook posts as "via <app name>". Replace xxxxxxxx below with your App ID.
 */
#define kFacebookAppIdentifier @"178351082358246"

@end

@implementation TWBSocialHelper

+(TWBSocialHelper *)sharedHelper
{
    static dispatch_once_t pred;
    static TWBSocialHelper *instance = nil;
    
    dispatch_once(&pred, ^{instance = [[self alloc] initSingleton];});
    return instance;
}

-(instancetype)initSingleton
{
    self = [super init];
    
    if (self)
    {
        // Init code goes here, if necessary.
    }
    
    return self;
}

#pragma mark - Twitter Methods


// Facebook Methods
-(void)requestReadAccessToFacebook
{
    
    // Specify the permissions required
    NSArray *permissions = @[@"read_stream", @"email"];
    
    // Specify the audience
    NSDictionary *facebookOptions = [[NSDictionary alloc] init];
    facebookOptions = @{ACFacebookAppIdKey : kFacebookAppIdentifier,
                        ACFacebookAudienceKey :  ACFacebookAudienceFriends,
                        ACFacebookPermissionsKey : permissions};
    
    // Create an Account Store
    _facebookAccountStore = [[ACAccountStore alloc] init];
    
    
    // Specify the Account Type
    ACAccountType *accountType = [[ACAccountType alloc] init];
    accountType = [_facebookAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    if (!accountType.accessGranted) {
        _readAccessGranted = NO;
        _writeAccessGranted = NO;
    }
    
    // Perform the permission request
    [_facebookAccountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            _readAccessGranted = YES;
            NSLog(@"Read permissions granted.");
            NSArray *array = [_facebookAccountStore accountsWithAccountType:accountType];
            _facebookAccount = [array lastObject];
            [self requestWriteAccessToFacebook];
        }
        if (error) {
            if (error.code == 6) {
                NSLog(@"Error: There is no Facebook account setup.");
            } else
            {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }
    }];
}

-(void)requestWriteAccessToFacebook
{
    // Publish permissions will only be requested if read access has been granted, otherwise an alert will be generated.
    if (_readAccessGranted)
    {
        
        
        // Specify the permissions required
        NSArray *permissions = @[@"publish_stream"];
        
        // Specify the audience
        
        NSDictionary *facebookOptions = [[NSDictionary alloc] init];
        facebookOptions = @{ACFacebookAppIdKey : kFacebookAppIdentifier,
                            ACFacebookAudienceKey :  ACFacebookAudienceFriends,
                            ACFacebookPermissionsKey : permissions};
        
        // Create an Account Store
        //ACAccountStore *facebookAccountStore = [[ACAccountStore alloc] init];
        
        // Specify the Account Type
        ACAccountType *accountType = [[ACAccountType alloc] init];
        accountType = [_facebookAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        if (!accountType.accessGranted) {
            _readAccessGranted = NO;
            _writeAccessGranted = NO;
        }
        
        // Perform the permission request
        [_facebookAccountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                _writeAccessGranted = YES;
                NSArray *array = [_facebookAccountStore accountsWithAccountType:accountType];
                _facebookAccount = [array lastObject];
                
                NSLog(@"Write permissions granted.");
            }
            
            if (error) {
                if (error.code == 6) {
                    NSLog(@"Error: There is no Facebook account setup.");
                } else
                {
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
            }
        }];
    }
    
    else
    {
        UIAlertView *readPermission = [[UIAlertView alloc] initWithTitle:@"Permissions Required" message:@"Read permissions are required before requesting publish permissions." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [readPermission show];
        readPermission = nil;
    }

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ReadAccessGranted"
     object:nil];
}



-(void)renewFacebookCredentials
{
    [_facebookAccountStore renewCredentialsForAccount:_facebookAccount
                                           completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                                               if (error) {
                                                   NSLog(@"Error Renewing Credentials:%@", [error localizedDescription]);
                                               } else{
                                                   [self requestReadAccessToFacebook];
                                               }
                                               
                                               NSLog(@"ACAccountCredentialRenewResult: %d", renewResult);
                                           }];
}


@end
