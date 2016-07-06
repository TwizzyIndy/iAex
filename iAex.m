
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import "sqlite3.h"

void printToStdOut(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat: format arguments: args];
    va_end(args);
    [[NSFileHandle fileHandleWithStandardOutput] writeData: [formattedString dataUsingEncoding: NSNEXTSTEPStringEncoding]];
	[formattedString release];
}

void printUsage() {
	printToStdOut(@"\niOS Authentication Extractor by TwizzyIndy\n");
    printToStdOut(@"May-2016\n\n");

}

NSMutableArray *getCommandLineOptions(int argc, char **argv) {
	NSMutableArray *arguments = [[NSMutableArray alloc] init];
	int argument;
	if (argc == 1) {
		[arguments addObject:(id)kSecClassGenericPassword];
		return [arguments autorelease];
    } else {
        printUsage();
    }

	return [arguments autorelease];

}

NSArray * getKeychainObjectsForSecClass(CFTypeRef kSecClassType) {
	NSMutableDictionary *genericQuery = [[NSMutableDictionary alloc] init];
	
	[genericQuery setObject:(id)kSecClassType forKey:(id)kSecClass];
	[genericQuery setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
	[genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	[genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
	[genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
	NSArray *keychainItems = nil;
	if (SecItemCopyMatching((CFDictionaryRef)genericQuery, (CFTypeRef *)&keychainItems) != noErr)
	{
		keychainItems = nil;
	}
	[genericQuery release];
	return keychainItems;
}


void printAccountToken(NSDictionary* passwordItem) {
    
    NSData* dataToken = [passwordItem objectForKey:(id)kSecValueData];
    printToStdOut(@"Token : %@\n", [[NSString alloc] initWithData:dataToken encoding:NSUTF8StringEncoding] );
    
}

void printAccountId(NSDictionary* passwordItem) {
    
    printToStdOut(@"ID : %@\n", [passwordItem objectForKey:(id)kSecAttrAccount] );
}

void printGenericPassword(NSDictionary *passwordItem) {


		printToStdOut(@"Generic Password\n");
		printToStdOut(@"----------------\n");
		printToStdOut(@"Service: %@\n", [passwordItem objectForKey:(id)kSecAttrService]);
		printToStdOut(@"Account: %@\n", [passwordItem objectForKey:(id)kSecAttrAccount]);
		printToStdOut(@"Entitlement Group: %@\n", [passwordItem objectForKey:(id)kSecAttrAccessGroup]);
		printToStdOut(@"Label: %@\n", [passwordItem objectForKey:(id)kSecAttrLabel]);
		printToStdOut(@"Generic Field: %@\n", [[passwordItem objectForKey:(id)kSecAttrGeneric] description]);
		NSData* passwordData = [passwordItem objectForKey:(id)kSecValueData];
		printToStdOut(@"Keychain Data: %@\n\n", [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding]);
}

void printResultsForSecClass(NSArray *keychainItems, CFTypeRef kSecClassType) {
	if (keychainItems == nil) {
		printToStdOut(@"\nFound Nothing !\n");
		return;
	}

	NSDictionary *keychainItem;
	for (keychainItem in keychainItems) {
        
        if ( [[keychainItem objectForKey:(id)kSecAttrService] isEqual:@"com.apple.account.AppleAccount.token"])
        {
            if (kSecClassType == kSecClassGenericPassword) {
                printAccountToken(keychainItem);
            }
            
        } else if ( [[keychainItem objectForKey:(id)kSecAttrService] isEqual:@"com.apple.icloud.fmip.auth"]) {
            
            if (kSecClassType == kSecClassGenericPassword) {
                printAccountId(keychainItem);
                
            }
            
        }
        
	}
	return;
}



int main(int argc, char **argv) 
{
	id pool=[NSAutoreleasePool new];
	NSArray* arguments;
	arguments = getCommandLineOptions(argc, argv);
	NSArray *passwordItems;	
	
	NSArray *keychainItems = nil;
	for (id kSecClassType in (NSArray *) arguments) {
		keychainItems = getKeychainObjectsForSecClass((CFTypeRef)kSecClassType);
		printResultsForSecClass(keychainItems, (CFTypeRef)kSecClassType);
		[keychainItems release];	
	}
    
	[pool drain];
}