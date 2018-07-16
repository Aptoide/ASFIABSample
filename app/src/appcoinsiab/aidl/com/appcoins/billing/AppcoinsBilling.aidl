// AppcoinsBilling.aidl
package com.appcoins.billing;

// Declare any non-default types here with import statements

interface AppcoinsBilling {
/**
        * Checks support for the requested billing API version, package and in-app type.
        * Minimum API version supported by this interface is 3.
        * @param apiVersion billing API version that the app is using
        * @param packageName the package name of the calling app
        * @param type type of the in-app item being purchased ("inapp" for one-time purchases
        *        and "subs" for subscriptions)
        * @return RESULT_OK(0) on success and appropriate response code on failures.
        */
       int isBillingSupported(int apiVersion, String packageName, String type);

       /**
        * Provides details of a list of SKUs
        * Given a list of SKUs of a valid type in the skusBundle, this returns a bundle
        * with a list JSON strings containing the productId, price, title and description.
        * This API can be called with a maximum of 20 SKUs.
        * @param apiVersion billing API version that the app is using
        * @param packageName the package name of the calling app
        * @param type of the in-app items ("inapp" for one-time purchases
        *        and "subs" for subscriptions)
        * @param skusBundle bundle containing a StringArrayList of SKUs with key "ITEM_ID_LIST"
        * @return Bundle containing the following key-value pairs
        *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, appropriate response codes
        *                         on failures.
        *         "DETAILS_LIST" with a StringArrayList containing purchase information
        *                        in JSON format similar to:
        *                        '{ "productId" : "exampleSku",
        *                           "type" : "inapp",
        *                           "price" : "$5.00",
        *                           "price_currency": "USD",
        *                           "price_amount_micros": 5000000,
        *                           "title : "Example Title",
        *                           "description" : "This is an example description" }'
        */
       Bundle getSkuDetails(int apiVersion, String packageName, String type, in Bundle skusBundle);

       /**
        * Returns a pending intent to launch the purchase flow for an in-app item by providing a SKU,
        * the type, a unique purchase token and an optional developer payload.
        * @param apiVersion billing API version that the app is using
        * @param packageName package name of the calling app
        * @param sku the SKU of the in-app item as published in the developer console
        * @param type of the in-app item being purchased ("inapp" for one-time purchases
        *        and "subs" for subscriptions)
        * @param developerPayload optional argument to be sent back with the purchase information
        * @return Bundle containing the following key-value pairs
        *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, appropriate response codes
        *                         on failures.
        *         "BUY_INTENT" - PendingIntent to start the purchase flow
        *
        * The Pending intent should be launched with startIntentSenderForResult. When purchase flow
        * has completed, the onActivityResult() will give a resultCode of OK or CANCELED.
        * If the purchase is successful, the result data will contain the following key-value pairs
        *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, appropriate response
        *                         codes on failures.
        *         "INAPP_PURCHASE_DATA" - String in JSON format similar to
        *                                 '{"orderId":"12999763169054705758.1371079406387615",
        *                                   "packageName":"com.example.app",
        *                                   "productId":"exampleSku",
        *                                   "purchaseTime":1345678900000,
        *                                   "purchaseToken" : "122333444455555",
        *                                   "developerPayload":"example developer payload" }'
        *         "INAPP_DATA_SIGNATURE" - String containing the signature of the purchase data that
        *                                  was signed with the private key of the developer
        */
       Bundle getBuyIntent(int apiVersion, String packageName, String sku, String type, String developerPayload);

       /**
        * Returns the current SKUs owned by the user of the type and package name specified along with
        * purchase information and a signature of the data to be validated.
        * This will return all SKUs that have been purchased in V3 and managed items purchased using
        * V1 and V2 that have not been consumed.
        * @param apiVersion billing API version that the app is using
        * @param packageName package name of the calling app
        * @param type of the in-app items being requested ("inapp" for one-time purchases
        *        and "subs" for subscriptions)
        * @param continuationToken to be set as null for the first call, if the number of owned
        *        skus are too many, a continuationToken is returned in the response bundle.
        *        This method can be called again with the continuation token to get the next set of
        *        owned skus.
        * @return Bundle containing the following key-value pairs
        *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, appropriate response codes
                                  on failures.
        *         "INAPP_PURCHASE_ITEM_LIST" - StringArrayList containing the list of SKUs
        *         "INAPP_PURCHASE_DATA_LIST" - StringArrayList containing the purchase information
        *         "INAPP_DATA_SIGNATURE_LIST"- StringArrayList containing the signatures
        *                                      of the purchase information
        *         "INAPP_CONTINUATION_TOKEN" - String containing a continuation token for the
        *                                      next set of in-app purchases. Only set if the
        *                                      user has more owned skus than the current list.
        */
       Bundle getPurchases(int apiVersion, String packageName, String type, String continuationToken);

       /**
        * Consume the last purchase of the given SKU. This will result in this item being removed
        * from all subsequent responses to getPurchases() and allow re-purchase of this item.
        * @param apiVersion billing API version that the app is using
        * @param packageName package name of the calling app
        * @param purchaseToken token in the purchase information JSON that identifies the purchase
        *        to be consumed
        * @return RESULT_OK(0) if consumption succeeded, appropriate response codes on failures.
        */
       int consumePurchase(int apiVersion, String packageName, String purchaseToken);

       /**
        * Returns a pending intent to launch the purchase flow for upgrading or downgrading a
        * subscription. The existing owned SKU(s) should be provided along with the new SKU that
        * the user is upgrading or downgrading to.
        * @param apiVersion billing API version that the app is using, must be 5 or later
        * @param packageName package name of the calling app
        * @param oldSkus the SKU(s) that the user is upgrading or downgrading from,
        *        if null or empty this method will behave like {@link #getBuyIntent}
        * @param newSku the SKU that the user is upgrading or downgrading to
        * @param type of the item being purchased, currently must be "subs"
        * @param developerPayload optional argument to be sent back with the purchase information
        * @return Bundle containing the following key-value pairs
        *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, appropriate response codes
        *                         on failures.
        *         "BUY_INTENT" - PendingIntent to start the purchase flow
        *
        * The Pending intent should be launched with startIntentSenderForResult. When purchase flow
        * has completed, the onActivityResult() will give a resultCode of OK or CANCELED.
        * If the purchase is successful, the result data will contain the following key-value pairs
        *         "RESPONSE_CODE" with int value, RESULT_OK(0) if success, appropriate response
        *                         codes on failures.
        *         "INAPP_PURCHASE_DATA" - String in JSON format similar to
        *                                 '{"orderId":"12999763169054705758.1371079406387615",
        *                                   "packageName":"com.example.app",
        *                                   "productId":"exampleSku",
        *                                   "purchaseTime":1345678900000,
        *                                   "purchaseToken" : "122333444455555",
        *                                   "developerPayload":"example developer payload" }'
        *         "INAPP_DATA_SIGNATURE" - String containing the signature of the purchase data that
        *                                  was signed with the private key of the developer
        *                                  TODO: change this to app-specific keys.
        */
       Bundle getBuyIntentToReplaceSkus(int apiVersion, String packageName,
           in List<String> oldSkus, String newSku, String type, String developerPayload);
}