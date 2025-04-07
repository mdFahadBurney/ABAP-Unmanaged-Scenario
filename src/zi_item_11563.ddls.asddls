@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions : true

define view entity ZI_ITEM_11563
  as select from ztd_items_11563
  association to parent ZI_HEADER_11563 as _header on $projection.Docno = _header.Docno
{

  key docno           as Docno, // Docnument Number
key item_no         as ItemNo,
      status          as Status, // Status Code
      @Semantics.amount.currencyCode: 'Currency'
      item_amt        as Item_Amt, // Item Amount
      @Semantics.amount.currencyCode: 'Currency'
      tax_amt         as Tax_Amt,  // Tax Amount
      @Semantics.quantity.unitOfMeasure : 'Unit_Of_Measure'
      quantity        as Quantity,
      currency        as Currency,
      unit_of_measure as Unit_Of_Measure, // Unit Of Measure
      changed_at      as Changed_At,
      created_at      as Created_At,
      created_by      as Created_By,
      
         // Association must be Public
    _header 
}
