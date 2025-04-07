CLASS lhc__header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CLASS-DATA : mt_root_to_create TYPE STANDARD TABLE OF ztm_head_11563 WITH NON-UNIQUE DEFAULT KEY,
                 ms_root_to_Create TYPE ztm_head_11563,
                 mt_item           TYPE STANDARD TABLE OF ztd_items_11563 WITH NON-UNIQUE DEFAULT KEY,
                 mt_address        TYPE STANDARD TABLE OF ztm_address_1563 WITH NON-UNIQUE DEFAULT KEY,
                 mt_root_to_delete TYPE STANDARD TABLE OF ztm_heaD_11563 WITH NON-UNIQUE DEFAULT KEY,
                 ms_delete         TYPE ztm_head_11563,
                 lt_final_update   TYPE STANDARD TABLE OF ztm_head_11563 WITH NON-UNIQUE DEFAULT KEY,
                 ls_delitm         TYPE ztd_items_11563,
                 lt_del_entity     TYPE STANDARD TABLE OF ztm_head_11563  WITH NON-UNIQUE DEFAULT KEY,

                 ls_item           TYPE ztd_items_11563,
                 ls_address        TYPE ztm_addr_11563,
                 lt_item_delete    TYPE STANDARD TABLE OF ztd_items_11563,
                 mt_root_to_update TYPE STANDARD TABLE OF ztm_head_11563 WITH NON-UNIQUE DEFAULT KEY,
                 mt_action         TYPE STANDARD TABLE OF ztm_head_11563 WITH NON-UNIQUE DEFAULT KEY.




    CLASS-METHODS : get_next_docno RETURNING VALUE(r_docno_val) TYPE ztdocno_dt.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR _header RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _header RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE _header.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE _header.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE _header.

    METHODS read FOR READ
      IMPORTING keys FOR READ _header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK _header.

    METHODS rba_Address FOR READ
      IMPORTING keys_rba FOR READ _header\_Address FULL result_requested RESULT result LINK association_links.

    METHODS rba_Item FOR READ
      IMPORTING keys_rba FOR READ _header\_Item FULL result_requested RESULT result LINK association_links.

    METHODS cba_Address FOR MODIFY
      IMPORTING entities_cba FOR CREATE _header\_Address.

    METHODS cba_Item FOR MODIFY
      IMPORTING entities_cba FOR CREATE _header\_Item.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION _header~reject RESULT result.

    METHODS status FOR MODIFY
      IMPORTING keys FOR ACTION _header~status RESULT result.

ENDCLASS.

CLASS lhc__header IMPLEMENTATION.

  METHOD get_instance_features.

    "--Disable the APPROVE and REJECT Status if they are Already APPROVED or REJECTED
    READ ENTITIES OF zi_header_11563 IN LOCAL MODE
    ENTITY _header
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_currentStatus)
    FAILED failed.



    result = VALUE #( FOR ls_status IN lt_currentstatus
    (
    %key = ls_status-%key
    %features = VALUE #( %action-status = COND #(
                                                WHEN ls_status-Status = 'APR'
                                                THEN if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled
                                                )
                         %action-reject = COND #(
                                                WHEN ls_status-Status = 'REJ'
                                                THEN if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled
                                                )

      ) )

    ).


  ENDMETHOD.

  METHOD get_instance_authorizations.

*  *  "--Implement this Method also with ETAG Functionality
*
    SELECT * FROM ZTM_HEAd_11563 FOR ALL ENTRIES IN @keys
    WHERE docno = @keys-Docno
    INTO TABLE @DATA(lt_head_data).

    "--Implemented Parallel Cursor here

    SORT lt_head_data BY docno.
    LOOP AT keys INTO DATA(key).
      READ TABLE lt_head_data INTO DATA(wa_head_data) WITH KEY docno = key-Docno BINARY SEARCH.
      DATA(lv_index) = sy-tabix.

      LOOP AT lt_head_data INTO DATA(wa_head) FROM lv_index.

        IF sy-subrc = 0.
          DATA(lv_allowed) =  COND #( WHEN wa_head-status = 'NEW' OR wa_head-status = 'REJ'
                                         THEN if_abap_behv=>auth-allowed

                                         ELSE if_abap_behv=>auth-unauthorized
                                         ).

          APPEND VALUE #( docno = key-docno %action-status = lv_allowed  ) TO result.

        ENDIF.
      ENDLOOP.
    ENDLOOP.



  ENDMETHOD.

  METHOD create.

    IF entities IS NOT INITIAL.
      "--Get the Document No. Value

      DATA(lv_docnum) = get_next_docno(  ).

      GET TIME STAMP FIELD DATA(lv_timestamp).


      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_head_data>).
        MOVE-CORRESPONDING <LFS_HEAD_dATA> TO ms_root_to_create.
        ms_root_to_create-docno = lv_docnum.
        ms_root_to_create-comp_cd = <lfs_head_data>-CompCd.
        ms_root_to_create-purch_org = <lfs_head_data>-PurchOrg.
        ms_root_to_create-supplier_no = <lfs_head_data>-SupplierNo.
        ms_root_to_create-changed_at = <lfs_head_data>-Changed_At.
        ms_root_to_create-created_by = <lfs_head_data>-Created_By.
        ms_root_to_create-created_at = <lfs_head_data>-Created_At.

        ms_root_to_create-locallastchangedat = lv_timestamp.



        INSERT CORRESPONDING #( ms_root_to_create ) INTO TABLE mapped-_header.
        INSERT CORRESPONDING #( ms_root_to_create ) INTO TABLE mt_root_to_create.
      ENDLOOP.


    ENDIF.


  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.

    "--Implementing the LOCK Functionality
    TRY.
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZLOCKHEAD' ).

      CATCH cx_abap_lock_failure INTO DATA(exception).
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      TRY.
          "--LOCK Incoming Request if it is not already Locked
          lock->enqueue(
*    it_table_mode =
            it_parameter  =  VALUE #( ( name = 'DOCNO' value = REF #( <lfs_key>-Docno ) ) )
*    _scope        =
*    _wait         =
          ).
        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
          DATA(lv_username) = foreign_lock->user_name.

          APPEND VALUE #(
          docno = keys[ 1 ]-Docno
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Record is locked by ' && lv_username
                 )
          ) TO reported-_header."--Any Failed Messages REPORTED and FAILED will take

          APPEND VALUE #(
          docno = keys[ 1 ]-Docno
          ) TO failed-_header.

        CATCH cx_abap_lock_failure INTO exception.
          RAISE SHORTDUMP exception.

      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD rba_Address.
  ENDMETHOD.

  METHOD rba_Item.
  ENDMETHOD.

  METHOD cba_Address.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<lfs_entity>).

      LOOP AT <lfs_entity>-%target ASSIGNING FIELD-SYMBOL(<lfs_address>).

        ls_address-address_no = <lfs_address>-AddressNo.
        MOVE-CORRESPONDING <lfs_address> TO ls_address.
        ls_address-street_addr = <lfs_address>-StreetAddr.
        INSERT CORRESPONDING #( ls_address ) INTO TABLE mt_address.
*clear ls_item.
*  MT_ITEM = CORRESPONDING #( <lfs_entity>-%target )."--Records of Item Getting Added.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD cba_Item.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<lfs_entity>).

      LOOP AT <lfs_entity>-%target ASSIGNING FIELD-SYMBOL(<lfs_item>).

        ls_item-item_no = <lfs_item>-ItemNo.
        MOVE-CORRESPONDING <lfs_item> TO ls_item.
        INSERT CORRESPONDING #( ls_item ) INTO TABLE mt_item.
*clear ls_item.
*  MT_ITEM = CORRESPONDING #( <lfs_entity>-%target )."--Records of Item Getting Added.

      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.

  METHOD reject.

    "--Instance Features 2
    DATA(lv_docnum) = keys[ 1 ]-Docno.
    SELECT * FROM ztm_head_11563 WHERE docno EQ @lv_docnum INTO TABLE @DATA(lt_Data).
*****SOC12345

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      MOVE-CORRESPONDING <ls_data> TO ms_root_to_create.
      ms_root_to_create-status = 'REJ'.
      INSERT CORRESPONDING #( ms_root_to_create ) INTO TABLE mt_action.

    ENDLOOP.


  ENDMETHOD.

  METHOD status.

    "--Instance Features 1
    "--Approved
    DATA(lv_docnum) = keys[ 1 ]-Docno.
    SELECT * FROM ztm_head_11563 WHERE docno EQ @lv_docnum INTO TABLE @DATA(lt_Data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      MOVE-CORRESPONDING <ls_data> TO ms_root_to_create.
      ms_root_to_create-status = 'APR'.
      INSERT CORRESPONDING #( ms_root_to_create ) INTO TABLE mt_action.

    ENDLOOP.


  ENDMETHOD.

  METHOD get_next_docno.
    SELECT MAX( docno ) FROM ztm_head_11563 INTO @DATA(lv_max_docnoid).
    r_docno_val = lv_max_docnoid + 1.
    r_docno_val = |{ r_docno_val ALPHA = IN }|.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_ITEM_11563 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    CLASS-DATA : ls_delitm      TYPE ztd_items_11563,
                 lt_item_delete TYPE STANDARD TABLE OF ztd_items_11563 WITH NON-UNIQUE DEFAULT KEY,
                 lt_item_update TYPE STANDARD TABLE OF ztd_items_11563 WITH NON-UNIQUE DEFAULT KEY.


  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_item_11563.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_item_11563.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_item_11563 RESULT result.

    METHODS rba_Header FOR READ
      IMPORTING keys_rba FOR READ zi_item_11563\_Header FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_ZI_ITEM_11563 IMPLEMENTATION.

  METHOD update.

    "--Update at ITEM LEVEL

    DATA : LT_items_UPDATE TYPE STANDARD TABLE OF ztd_items_11563,
           LS_items_UPDATE TYPE ztd_items_11563.

    lt_items_update = CORRESPONDING #( entities MAPPING FROM ENTITY ).

    SELECT * FROM ztd_items_11563
    FOR ALL ENTRIES IN @lt_items_update
    WHERE docno = @lt_items_update-docno AND item_no = @lt_items_update-item_no
    INTO TABLE @DATA(lt_item_update_old). "--Reference Record to be checked with


    "--Insert the MODIFIED DATA BACK TO TABLE
    lt_item_update = VALUE #(
*    "--Loop running once only
    FOR x = 1 WHILE x <= lines( lt_ITEMS_update )
        LET
        ls_control_flag = VALUE #( entities[ x ]-%control OPTIONAL )
        ls_item_OLD = VALUE #( lt_item_update_old[ x ]  OPTIONAL )"--Whatever User has Update it will come here
        ls_item_NEW = VALUE #( lt_items_update[ docno = ls_ITEM_old-docno item_no = ls_ITEM_OLD-item_no ] OPTIONAL )
    IN
    (
*"--Use CONTROL STRUCUTRE to IDENTIFY WHICH VALUES ARE UPDATED
*"--Still we will send those fields that are not UPDATED,Else we will get DUMP or
    docno = ls_item_old-docno
    item_no = COND #( WHEN ls_control_flag-ItemNo IS NOT INITIAL
                        THEN ls_item_new-item_no ELSE ls_item_old-item_no )
    status = COND #( WHEN ls_control_flag-Status IS NOT INITIAL
                        THEN ls_item_new-status ELSE ls_item_old-status )
     quantity = COND #( WHEN ls_control_flag-Quantity IS NOT INITIAL
                        THEN ls_item_new-quantity ELSE ls_item_old-quantity )
      item_amt = COND #( WHEN ls_control_flag-Item_Amt IS NOT INITIAL
                        THEN ls_item_new-item_amt ELSE ls_item_old-item_amt )
        tax_amt = COND #( WHEN ls_control_flag-Tax_Amt IS NOT INITIAL
                        THEN ls_item_new-tax_amt ELSE ls_item_old-tax_amt )
unit_of_measure = COND #( WHEN ls_control_flag-Unit_Of_Measure IS NOT INITIAL
                    THEN ls_item_new-unit_of_measure ELSE ls_item_old-unit_of_measure )
   currency     = COND #( WHEN ls_control_flag-Currency IS NOT INITIAL
                    THEN ls_item_new-currency ELSE ls_item_old-currency )
         changed_at = COND #( WHEN ls_control_flag-Changed_At IS NOT INITIAL
                    THEN ls_item_new-changed_at ELSE ls_item_old-changed_at )
           created_at = COND #( WHEN ls_control_flag-Created_At IS NOT INITIAL
                    THEN ls_item_new-created_at ELSE ls_item_old-created_at )
 created_by = COND #( WHEN ls_control_flag-Created_By IS NOT INITIAL
                    THEN ls_item_new-created_by ELSE ls_item_old-created_by )
     ) ).


  ENDMETHOD.

  METHOD delete.

    "--DELETE ITEM
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_delete>).
      ls_delitm-docno = <fs_delete>-Docno.
      ls_delitm-item_no = <fs_delete>-ItemNo.
      INSERT CORRESPONDING #( ls_delitm ) INTO TABLE lt_item_delete.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Header.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_ADDRESS_11563 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    CLASS-DATA : ls_deladdr        TYPE ztm_addr_11563,
                 lt_address_delete TYPE STANDARD TABLE OF ztm_addr_11563 WITH NON-UNIQUE DEFAULT KEY,
                 lt_address_update TYPE STANDARD TABLE OF ztm_addr_11563 WITH NON-UNIQUE DEFAULT KEY.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_address_11563.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_address_11563.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_address_11563 RESULT result.

    METHODS rba_Header FOR READ
      IMPORTING keys_rba FOR READ zi_address_11563\_Header FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_ZI_ADDRESS_11563 IMPLEMENTATION.

  METHOD update.

    "--Update at ADDRESS LEVEL

    DATA : LT_address_updates TYPE STANDARD TABLE OF ztm_addr_11563,
           LS_address_update  TYPE ztm_addr_11563.

    lt_address_updates = CORRESPONDING #( entities MAPPING FROM ENTITY ).

    SELECT * FROM ztm_addr_11563
    FOR ALL ENTRIES IN @lt_address_updates
    WHERE docno = @lt_address_updates-docno AND address_no = @lt_address_updates-address_no
    INTO TABLE @DATA(lt_address_update_old). "--Reference Record to be checked with


    "--Insert the MODIFIED DATA BACK TO TABLE
    lt_address_update = VALUE #(
*    "--Loop running once only
    FOR x = 1 WHILE x <= lines( lt_address_updates )
        LET
        ls_control_flag = VALUE #( entities[ x ]-%control OPTIONAL )
        ls_address_old = VALUE #( lt_address_update_old[ x ]  OPTIONAL )"--Whatever User has Update it will come here
        ls_address_NEW = VALUE #( lt_address_updates[ docno = ls_address_old-docno address_no = ls_address_old-address_no ] OPTIONAL )
    IN
    (
*"--Use CONTROL STRUCUTRE to IDENTIFY WHICH VALUES ARE UPDATED
*"--Still we will send those fields that are not UPDATED,Else we will get DUMP or
    docno = ls_address_old-docno
    address_no = COND #( WHEN ls_control_flag-AddressNo IS NOT INITIAL
                        THEN ls_address_NEW-address_no ELSE ls_address_old-address_no )
    name = COND #( WHEN ls_control_flag-Name IS NOT INITIAL
                        THEN ls_address_NEW-name ELSE ls_address_old-name )
     street_addr = COND #( WHEN ls_control_flag-StreetAddr IS NOT INITIAL
                        THEN ls_address_NEW-street_addr ELSE ls_address_old-street_addr )
     city = COND #( WHEN ls_control_flag-City IS NOT INITIAL
                        THEN ls_address_NEW-city ELSE ls_address_old-city )
        country = COND #( WHEN ls_control_flag-Country IS NOT INITIAL
                        THEN ls_address_NEW-country ELSE ls_address_old-country )
status = COND #( WHEN ls_control_flag-Status IS NOT INITIAL
                    THEN ls_address_NEW-status ELSE ls_address_old-status )

     ) ).

*    key client     : abap.clnt not null;
*  @AbapCatalog.foreignKey.screenCheck : true
*  key docno      : ztdocno_dt not null
*    with foreign key [1,1] ztm_head_11563
*      where client = ztm_addr_11563.client
*        and docno = ztm_addr_11563.docno;
*  key address_no : ztaddress_no not null;
*  name           : ztname_dt;
*  street_addr    : ztstreet_addr;
*  city           : ztcity_dt;
*  country        : ztcountry_dt;
*  status         : ztstatus_st;


  ENDMETHOD.

  METHOD delete.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_delete>).

      ls_deladdr-docno = <fs_delete>-Docno.
      ls_deladdr-address_no = <fs_delete>-AddressNo.

      INSERT CORRESPONDING #( ls_deladdr ) INTO TABLE lt_address_delete.

    ENDLOOP.


  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Header.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_HEADER_11563 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_HEADER_11563 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    IF lhc__header=>mt_root_to_create IS NOT INITIAL.
      MODIFY ztm_head_11563 FROM TABLE @lhc__header=>mt_root_to_create.
    ENDIF.

    IF lhc__header=>mt_item IS NOT INITIAL.
      MODIFY ztd_items_11563 FROM TABLE @lhc__header=>mt_item.
    ENDIF.

    "--Address
    IF lhc__header=>mt_address IS NOT INITIAL.
      MODIFY ztm_addr_11563 FROM TABLE @lhc__header=>mt_address.
    ENDIF.


    IF lhc__header=>mt_root_to_delete IS NOT INITIAL.
      DELETE ztm_head_11563 FROM TABLE @lhc__header=>mt_root_to_delete.
      DELETE ztd_items_11563 FROM TABLE @lhc__header=>mt_root_to_delete.
      DELETE ztm_addr_11563 FROM TABLE @lhc__header=>mt_root_to_delete.
    ENDIF.

    IF lhc__header=>mt_root_to_update IS NOT INITIAL.
      "--Header Update
      MODIFY ztm_head_11563 FROM TABLE @lhc__header=>mt_root_to_update.

    ENDIF.
    IF lhc_zi_item_11563=>lt_item_delete IS NOT INITIAL.

      DELETE ztd_items_11563 FROM TABLE @lhc_zi_item_11563=>lt_item_delete.

    ENDIF.

    IF lhc_zi_item_11563=>lt_item_update IS NOT INITIAL.

      MODIFY ztd_items_11563 FROM TABLE @lhc_zi_item_11563=>lt_item_update.
*
    ENDIF.
    IF lhc__header=>lt_final_update IS NOT INITIAL.

      MODIFY ztm_head_11563 FROM TABLE @lhc__header=>lt_final_update.
    ENDIF.

    IF lhc__header=>mt_action IS NOT INITIAL.
      MODIFY ztm_head_11563 FROM TABLE @lhc__header=>mt_action.
    ENDIF.

    IF lhc_zi_address_11563=>lt_address_update IS NOT INITIAL.
      MODIFY ztm_addr_11563 FROM TABLE @lhc_zi_address_11563=>lt_address_update.
    ENDIF.


    IF lhc_zi_address_11563=>lt_address_delete IS NOT INITIAL.
      DELETE ztm_addr_11563 FROM TABLE @lhc_zi_address_11563=>lt_address_delete.
    ENDIF.



  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
