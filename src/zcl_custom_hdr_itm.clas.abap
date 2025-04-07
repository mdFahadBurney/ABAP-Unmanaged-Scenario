CLASS zcl_custom_hdr_itm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CUSTOM_HDR_ITM IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

  DATA: ls_docno TYPE if_rap_query_filter=>ty_range_option,
          lr_docno TYPE if_rap_query_filter=>tt_range_option,
          ls_supno TYPE if_rap_query_filter=>ty_range_option,
          lr_supno TYPE if_rap_query_filter=>tt_range_option.






  DATA : lt_response type table of zfb_custom_entity,
          ls_response type zfb_custom_entity.

    TRY.

        DATA(lv_data_req) = io_request->is_data_requested(  ).
        DATA(lv_top) = io_request->get_paging(  )->get_page_size(  ).
        DATA(lv_skip) = io_request->get_paging(  )->get_offset(  ).
        DATA(lt_fields) = io_request->get_requested_elements(  ).
        DATA(lt_sort) = io_request->get_sort_elements(  ).
        DATA(lv_page_size) = io_request->get_paging(  )->get_page_size( ).
        DATA(lv_max_row) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_page_size ).
        DATA(lv_condition) = io_request->get_filter(  )->get_as_ranges( iv_drop_null_comparisons = abap_true ).
        DATA(lv_filter_cond) = io_request->get_parameters(  ).

        lv_max_row = lv_skip + lv_top.
        IF lv_skip > 0.
        lv_skip += 1.
        ENDIF.

        DATA(lt_filter_cond) = io_request->get_parameters(  ).
        SORT lv_condition BY name.

       READ TABLE lv_condition WITH KEY name = 'DOCNO' INTO DATA(ls_key) BINARY SEARCH.
        IF sy-subrc IS INITIAL AND lines( ls_key-range ) = 1.
          DATA(lt_range_value) = ls_key-range.
          LOOP AT lt_range_value INTO DATA(ls_range_value).

            ls_docno-sign = ls_range_value-sign.
            ls_docno-option = ls_range_value-option.
            ls_docno-low =  ls_range_value-low .
            ls_docno-high = ls_range_value-high.

            APPEND ls_docno TO lr_docno.
          ENDLOOP.
        ENDIF.

        READ TABLE lv_condition WITH KEY name = 'SUPPLIER_NO' INTO DATA(ls_data) BINARY SEARCH.
        IF sy-subrc IS INITIAL AND lines( ls_data-range ) = 1.
          DATA(lt_range) = ls_data-range.

          LOOP AT lt_range INTO DATA(ls_range).

            ls_supno-sign = ls_range-sign.
            ls_supno-option = ls_range-option.
            ls_supno-low = ls_range-low.
            ls_supno-high = ls_range-high.

            APPEND ls_supno TO lr_supno.
          ENDLOOP.
        ENDIF.


* key docno : ztdocno_dt;
*
*@UI : { lineItem : [{position : 11, importance : #HIGH }]}
*//@UI.selectionField: [{ position : 11 }]
*  key itemNo : ztitem_no;
*
*@UI : { lineItem : [{position : 12, importance : #HIGH }]}
*//@UI.selectionField: [{ position : 12 }]
*  CompanyCode : ztcomp_cd;
*
*@UI : { lineItem : [{position : 13, importance : #HIGH }]}
*//@UI.selectionField: [{ position : 13 }]
*  PurchOrg : ztpurch_org;
*
*
*@UI : { lineItem : [{position : 14, importance : #HIGH }]}
*//@UI.selectionField: [{ position : 14 }]
*  Currency : ztcurr_dt;
*
*@UI : { lineItem : [{position : 15, importance : #HIGH }]}
*@UI.selectionField: [{ position : 15 }]
*  supplier_no  : ztsupplier_no;
*
*@UI : { lineItem : [{position : 16, importance : #HIGH }]}
*//@UI.selectionField: [{ position : 16 }]
*  Status : ztstatus_st;
*
*@Semantics.quantity.unitOfMeasure: 'unit_of_measure'
*@UI : { lineItem : [{position : 17, importance : #HIGH }]}
*//@UI.selectionField: [{ position : 17 }]
*  Quantity : ztquantity_dt;
*
*@Semantics.amount.currencyCode: 'Currency'
*@UI : { lineItem : [{position : 18, importance : #HIGH }]}
*//@UI.selectionField: [{ position : 18 }]
*  Item_Amount  : ztitem_amt;
*
*@Semantics.amount.currencyCode: 'Currency'
*@UI : { lineItem : [{position : 19, importance : #HIGH }]}
*//@UI.selectionField: [{ position : 19 }]
*  Tax_Amount : zttax_amt;
*
*  unit_of_measure : abap.unit(2);

*      SELECT a~docno,
*             b~item_no,
*               a~comp_cd,
*               a~purch_org,
*               a~currency,
*               a~supplier_no,
*               a~status,
*               b~quantity,
*               b~item_amt,
*               b~tax_amt
*
*         FROM ztm_head_11563 AS a
*        INNER JOIN ztd_items_11563 AS b
*        ON b~docno = a~docno
*        WHERE a~docno IN @lr_docno
*        AND a~supplier_no IN @lr_supno
*        ORDER BY a~docno ASCENDING
*        INTO TABLE @DATA(lt_header).



   SELECT a~docno,
             b~item_no,
             c~address_no,
               a~comp_cd,
               a~purch_org,
               a~currency,
               a~supplier_no,
               a~status,
               b~quantity,
               b~item_amt,
               b~tax_amt,
               c~city,
               c~name,
               c~street_addr,
               c~country


         FROM ztm_head_11563 AS a
        INNER JOIN ztd_items_11563 AS b
        ON b~docno = a~docno
        INNER JOIN ztm_addr_11563 as c
        ON c~docno = a~docno
        WHERE a~docno IN @lr_docno
        AND a~supplier_no IN @lr_supno
        ORDER BY a~docno ASCENDING
        INTO TABLE @DATA(lt_header).

        IF lv_data_req IS INITIAL.
          IF io_request->is_total_numb_of_rec_requested(  ).
            io_response->set_total_number_of_records( lines( lt_header ) ).
            RETURN.
          ENDIF.
        ENDIF.

        LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_output>)
        FROM lv_skip TO lv_max_row.
          MOVE-CORRESPONDING <fs_output> TO ls_response.
          LS_RESPONSE-PurchOrg = <fs_output>-purch_org.
          ls_response-Item_Amount = <fs_output>-item_amt.
          ls_response-Tax_Amount = <fs_output>-tax_amt.
          ls_response-CompanyCode = <fs_output>-comp_cd.
          ls_response-itemNo = <fs_output>-item_no.
          APPEND ls_response TO lt_response.
          CLEAR ls_response.
        ENDLOOP.

        TRY.
            io_response->set_total_number_of_records( lines( lt_response ) ).
            io_response->set_data( lt_response ).
          CATCH cx_rap_query_provider INTO DATA(lx_new_root).
            DATA(lv_text2) = lx_new_root->get_text( ).
        ENDTRY.

      CATCH cx_root INTO DATA(cx_dest).
        DATA(lv_text) =  cx_dest->get_text(  ).



        ENDTRY.



  ENDMETHOD.
ENDCLASS.
