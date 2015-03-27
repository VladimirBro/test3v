//
//  IAPHelper.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "IAPHelper.h"

@implementation IAPHelper
@synthesize productIdentifiers = _productIdentifiers;
@synthesize products = _products;
@synthesize purchasedProducts = _purchasedProducts;
@synthesize request = _request;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = [productIdentifiers retain];
        
        // Check for previously purchased products
        /*NSMutableSet * purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [purchasedProducts addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
        }
        self.purchasedProducts = purchasedProducts;
        */                
    }
    return self;
}

- (void)requestProducts {
    
    self.request = [[[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers] autorelease];
    _request.delegate = self;
    [_request start];
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    //NSLog(@"Received products results... : %d",[response.products count]);   
    self.products = response.products;
    self.request = nil;    
	/*for (int i=0; i < [response.invalidProductIdentifiers count] ; i++) {
	  NSLog(@"Invalid product ... : %@",[response.invalidProductIdentifiers objectAtIndex:i]); 
	}
	*/   
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:_products];    
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {    
    // TODO: Record the transaction on the server side...
	//NSString *reciept=[NSString base64StringFromData:transaction.transactionReceipt length:[transaction.transactionReceipt length]];
	//NSString *reciept=[Base64 encode:transaction.transactionReceipt];
	//NSLog(@"Reciept : %@", transaction.transactionReceipt);
	/*NSString *receiptDataString = [[NSString alloc] initWithData:transaction.transactionReceipt 
														encoding:NSUTF8StringEncoding];
	receiptDataString =[Base64 encode:[[NSString stringWithFormat:@"%@",receiptDataString] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[[NSUserDefaults standardUserDefaults] setObject:receiptDataString forKey:@"kPackagePurchasedReceipt"];
	//NSLog(@"Reciept : %@", receiptDataString);
	 */
}

- (void)provideContent:(SKPaymentTransaction *)transaction {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:transaction];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    //NSLog(@"completeTransaction...");
    //[self recordTransaction: transaction];
    [self provideContent: transaction];
    //[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {

    //NSLog(@"restoreTransaction...");
    //[self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction];
    //[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    //NSLog(@"failedTransaction...");
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {                
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	//NSLog(@"%@",error.localizedDescription);
	[[NSNotificationCenter defaultCenter] postNotificationName:kProductRestoreFailedNotification object:error];
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	/*if ([queue.transactions count] == 0) {
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:NSLocalizedString(@"noPreviousPurchase",nil) forKey:NSLocalizedDescriptionKey];
		//NSError *error = [NSError errorWithDomain:kDomainPurchaseRestored code:100 userInfo:details];
		[[NSNotificationCenter defaultCenter] postNotificationName:kProductRestoreFailedNotification object:error];
		details = nil;
	}*/
    
    
    if ([queue.transactions count]==0)
    {
        NSDictionary *errDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Sorry, It seems you have not purchased it before.",NSLocalizedDescriptionKey, nil];
        NSError *err=[NSError errorWithDomain:@"Restore Failed" code:11225 userInfo:errDict];
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductRestoreFailedNotification object:err];
    }
    
}

- (void)buyProductIdentifier:(NSString *)productIdentifier { 
    //NSLog(@"Buying %@...", productIdentifier);
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchasedProducts
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)dealloc
{
    [_productIdentifiers release];
    _productIdentifiers = nil;
    [_products release];
    _products = nil;
    [_purchasedProducts release];
    _purchasedProducts = nil;
    [_request release];
    _request = nil;
    [super dealloc];
}

@end
