 @AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_ITEM_11563 as projection on ZI_ITEM_11563
{
    key Docno,
   key ItemNo,
    Status,
     @Semantics.amount.currencyCode: 'Currency'
    Item_Amt,
     @Semantics.amount.currencyCode: 'Currency'
    Tax_Amt,
    @Semantics.quantity.unitOfMeasure: 'Unit_Of_Measure'
    Quantity,
     @Consumption.valueHelpDefinition: [{ entity:{name: 'I_CurrencyText', element: 'Currency' } }]
    Currency,
    Unit_Of_Measure,
    Changed_At,
    Created_At,
    Created_By,
    /* Associations */
    _header : redirected to parent ZC_HEADER_11563
    
 
}
