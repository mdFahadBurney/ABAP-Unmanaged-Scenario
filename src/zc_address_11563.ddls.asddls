 @AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Address Consumption CDS View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_ADDRESS_11563 as projection on ZI_ADDRESS_11563
{
    key Docno,
    key AddressNo,
    Name,
    StreetAddr,
    City,
    Country,
     @Consumption.valueHelpDefinition: [{ entity:{name: 'Z_I_STATUS_DOM_11563', element: 'Value' } }]
    Status,
    /* Associations */
    _header : redirected to parent ZC_HEADER_11563
}
