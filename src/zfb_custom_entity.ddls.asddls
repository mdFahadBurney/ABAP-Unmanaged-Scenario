@EndUserText.label: 'Custom Entity in RAP ABAP'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CUSTOM_HDR_ITM'
@UI : {
headerInfo: {
typeName : 'Custom Report',
typeNamePlural : 'Custom Report'
}
}
define custom entity ZFB_CUSTOM_ENTITY
 // with parameters parameter_name : parameter_type
{
@UI : { lineItem : [{position : 10, importance : #HIGH }]}
@UI.selectionField: [{ position : 10 }]
//@Consumption.valueHelpDefinition: [{   }]
  key docno : ztdocno_dt;
  
@UI : { lineItem : [{position : 11, importance : #HIGH }]}
//@UI.selectionField: [{ position : 11 }]
  key itemNo : ztitem_no;
  
@UI : { lineItem : [{position : 12, importance : #HIGH }]}
 key address_no : ztaddress_no ; 

  
@UI : { lineItem : [{position : 13, importance : #HIGH }]}
//@UI.selectionField: [{ position : 12 }]
  CompanyCode : ztcomp_cd;

@UI : { lineItem : [{position : 14, importance : #HIGH }]}
//@UI.selectionField: [{ position : 13 }]
  PurchOrg : ztpurch_org;


@UI : { lineItem : [{position : 15, importance : #HIGH }]}
//@UI.selectionField: [{ position : 14 }]
  Currency : ztcurr_dt;
 
@UI : { lineItem : [{position : 16, importance : #HIGH }]}
@UI.selectionField: [{ position : 16 }] 
  supplier_no  : ztsupplier_no;

@UI : { lineItem : [{position : 17, importance : #HIGH }]}
//@UI.selectionField: [{ position : 16 }] 
  Status : ztstatus_st;

@Semantics.quantity.unitOfMeasure: 'unit_of_measure'
@UI : { lineItem : [{position : 18, importance : #HIGH }]}
//@UI.selectionField: [{ position : 17 }] 
  Quantity : ztquantity_dt;
  
@Semantics.amount.currencyCode: 'Currency'
@UI : { lineItem : [{position : 19, importance : #HIGH }]}
//@UI.selectionField: [{ position : 18 }]
  Item_Amount  : ztitem_amt;
 
@Semantics.amount.currencyCode: 'Currency'
@UI : { lineItem : [{position : 20, importance : #HIGH }]}
//@UI.selectionField: [{ position : 19 }] 
  Tax_Amount : zttax_amt;
 

 @UI : { lineItem : [{position : 21, importance : #HIGH }]} 
  name           : ztname_dt;
 @UI : { lineItem : [{position : 22, importance : #HIGH }]}
  street_addr    : ztstreet_addr;
 @UI : { lineItem : [{position : 23, importance : #HIGH }]}
  city           : ztcity_dt;
 @UI : { lineItem : [{position : 24, importance : #HIGH }]}
  country        : ztcountry_dt;

  
  
  
  
  unit_of_measure : abap.unit(2);
  
  
  
//  key client         : mandt not null;
//  key docno          : ztdocno_dt not null;
//  comp_cd            : ztcomp_cd;
//  purch_org          : ztpurch_org;
//  currency           : ztcurr_dt;
//  supplier_no        : ztsupplier_no;
//  status             : ztstatus_st;
//  changed_at         : ztdate_dt;
//  created_at         : ztdate_dt;
//  created_by         : ztcreated_by;
//  locallastchangedat : timestampl;


//  key client      : abap.clnt not null;
//  @AbapCatalog.foreignKey.screenCheck : true
//  key docno       : ztdocno_dt not null
//    with foreign key [1..*,1] ztm_head_11563
//      where client = ztd_items_11563.client
//        and docno = ztd_items_11563.docno;
//  key item_no     : ztitem_no not null;
//  status          : ztstatus_st;
//  @Semantics.quantity.unitOfMeasure : 'ztd_items_11563.unit_of_measure'
//  quantity        : ztquantity_dt;
//  @Semantics.amount.currencyCode : 'ztd_items_11563.currency'
//  item_amt        : ztitem_amt;
//  @Semantics.amount.currencyCode : 'ztd_items_11563.currency'
//  tax_amt         : zttax_amt;
//  unit_of_measure : abap.unit(2);
//  currency        : ztcurr_dt;
//  changed_at      : ztdate_dt;
//  created_at      : ztdate_dt;
//  created_by      : ztcreated_by;
  
  
}
