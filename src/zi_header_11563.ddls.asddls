@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header Interface View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_HEADER_11563 as select from ztm_head_11563
composition[1..*] of ZI_ITEM_11563 as _item 
composition[1..*] of ZI_ADDRESS_11563 as _address
{    
@Search.defaultSearchElement: true
key docno as Docno,      //Document Number
comp_cd as CompCd,       //Company Code
purch_org as PurchOrg,   // Purchasing Organization
currency as Currency,    //Currency
supplier_no as SupplierNo, //Supplier Number
@Consumption.valueHelpDefinition: [{ entity : { name : 'Z_I_STATUS_DOM_11563' , element: 'Value'  } }]
status as Status,          // Status
changed_at as Changed_At,   //Changed At
created_at as Created_At,   //Created At
created_by as Created_By,   //Created By
@Semantics.systemDateTime.localInstanceLastChangedAt: true
locallastchangedat as LocalLastChangedAt,

//key ztm_head_11563.docno as Docno,
//ztm_head_11563.comp_cd as CompCd,
//ztm_head_11563.purch_org as PurchOrg,
//ztm_head_11563.currency as Currency,
//ztm_head_11563.supplier_no as SupplierNo,
//ztm_head_11563.status as Status,
//ztm_head_11563.changed_at as ChangedAt,
//ztm_head_11563.created_at as CreatedAt,
//ztm_head_11563.created_by as CreatedBy,
//ztm_head_11563.locallastchangedat as Locallastchangedat,
// Make Associations Public
_item,
_address
    
}
