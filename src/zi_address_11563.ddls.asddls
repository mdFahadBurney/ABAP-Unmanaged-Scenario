@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Address CDS View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ADDRESS_11563 
as select from ztm_addr_11563
  association to parent ZI_HEADER_11563 as _header on $projection.Docno = _header.Docno
{
    key docno as Docno,
    key address_no as AddressNo,
    name as Name,
    street_addr as StreetAddr,
    city as City,
    country as Country,
    status as Status,
    
    // Association as Public
    _header
}
