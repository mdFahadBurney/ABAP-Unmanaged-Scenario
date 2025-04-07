@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_HEADER_11563 as projection on ZI_HEADER_11563
{   
     @Search.defaultSearchElement: true
    key Docno,
    CompCd,
    PurchOrg,
    @Consumption.valueHelpDefinition: [{ entity:{name: 'I_CurrencyText', element: 'Currency' } }]
    Currency,
    SupplierNo,
    @Consumption.valueHelpDefinition: [{ entity:{name: 'Z_I_STATUS_DOM_11563', element: 'Value' } }]
    Status,
    Changed_At,
    Created_At,
    Created_By,
    LocalLastChangedAt,
//    key Docno,
//    CompCd,
//    PurchOrg,
//    Currency,
//    SupplierNo,
//    Status,
//    ChangedAt,
//    CreatedAt,
//    CreatedBy,
//    LocalLastChangedAt,
//    /* Associations */
//    _item,
    /* Associations */
    _item : redirected to composition child ZC_ITEM_11563,
    _address : redirected to composition child ZC_ADDRESS_11563
    
}
