*&---------------------------------------------------------------------*
*& Report Z_TEST_ALVTOOLBAR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_TEST_ALVTOOLBAR.

TABLES: mkpf.

include <color>.
include <icon>.
include <symbol>.

DATA: BEGIN OF gs_output,
        mblnr     TYPE mkpf-mblnr,
        mjahr     TYPE mkpf-mjahr,
        budat     TYPE mkpf-budat,
      END OF gs_output,
gt_output LIKE STANDARD TABLE OF gs_output.


DATA:   gr_alv     TYPE REF TO cl_salv_table.

INITIALIZATION.


*---------------------------------------------------------
START-OF-SELECTION.
*---------------------------------------------------------

END-OF-SELECTION.


  PERFORM get_data.
  PERFORM display_report.


* local event handler
CLASS lcl_evt_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_on_user_command for event added_function of cl_salv_events
        importing sender e_salv_function,
      handle_doubleclick_mkpf FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column sender.

*    CLASS-METHODS:
*      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
*        IMPORTING e_object e_interactive.

ENDCLASS.


CLASS lcl_evt_handler IMPLEMENTATION.

  method handle_on_user_command.
    perform process_button.
  endmethod.

  METHOD handle_doubleclick_mkpf.

    READ TABLE gt_output ASSIGNING FIELD-SYMBOL(<fs_output>) INDEX row.
    CHECK sy-subrc = 0.

    CASE column.
      WHEN 'MBLNR'.
        "PERFORM display_details_mseg USING <fs_output>.

*     WHEN 'QTY_PO'.            " quantity po
*        PERFORM display_details_po USING <fs_output>.

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.


*  METHOD    handle_toolbar.
*        CLEAR gs_alv_toolbar.
*        MOVE 'WRD' TO gs_alv_toolbar-function. "'&XXL' - SAP-Funktionscode
*        MOVE icon_xls TO gs_alv_toolbar-icon.
*        MOVE 'Word '(001) TO gs_alv_toolbar-quickinfo.
*        MOVE ' Word'(002) TO gs_alv_toolbar-text.
*        MOVE 0 TO gs_alv_toolbar-butn_type.
*        MOVE space TO gs_alv_toolbar-disabled.
*        APPEND gs_alv_toolbar TO e_object->mt_toolbar.
*
*  ENDMETHOD.

 ENDCLASS.

FORM get_data.

  SELECT *
    FROM MKPF
    INTO CORRESPONDING FIELDS OF TABLE gt_output
    WHERE MJAHR EQ '2023'
    .

ENDFORM.

FORM display_report.
    DATA:
    lr_layout           TYPE REF TO cl_salv_layout,
    ls_key              TYPE salv_s_layout_key,
    lr_column           TYPE REF TO cl_salv_column_table,
    lr_columns          TYPE REF TO cl_salv_columns_table,
    lr_events           TYPE REF TO cl_salv_events_table,
*    lr_receiver         TYPE REF TO lcl_evt_handler,
    lr_sorts            TYPE REF TO cl_salv_sorts,
    lr_sort             TYPE REF TO cl_salv_sort,
    lr_display_settings TYPE REF TO cl_salv_display_settings.

  DATA: lr_functions  TYPE REF TO cl_salv_functions.

  DATA:
  gr_display TYPE REF TO cl_salv_display_settings.

* exception class
  DATA: lx_msg       TYPE REF TO cx_salv_msg,
        lx_not_found TYPE REF TO cx_salv_not_found.

  DATA: "lr_display_settings TYPE REF TO cl_salv_display_settings,
    lv_title   TYPE lvc_ddict,
    lv_mtext   TYPE scrtext_m,
    lv_ltext   TYPE scrtext_l,
    lv_stext   TYPE scrtext_s,
    lv_tooltip TYPE lvc_tip,
    lv_icon    TYPE string.

  TRY.
      cl_salv_table=>factory(
        EXPORTING
          r_container  = cl_gui_container=>default_screen
        IMPORTING
          r_salv_table = gr_alv
        CHANGING
          t_table      = gt_output ).

      ls_key-report = sy-repid.
      ls_key-handle = '0200'.
      lr_layout = gr_alv->get_layout( ).
      lr_layout->set_key( ls_key ).
      lr_layout->set_default( 'X' ) .
      lr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      "lr_layout->set_initial_layout( p_layout ) .
    CATCH cx_salv_msg INTO lx_msg.
  ENDTRY.

*
*  lr_display_settings = gr_alv->get_display_settings( ).
*  lr_display_settings->set_list_header( value = TEXT-t01 ).
*  lr_sorts = gr_alv->get_sorts( ).
*
*  TRY.
*
*      lr_sorts->add_sort( columnname = 'BUDAT'
*                          sequence   = if_salv_c_sort=>sort_up ).
*      lr_sort = lr_sorts->get_sort( columnname = 'BUDAT' ).
*      lr_sort->set_subtotal( value = abap_true ).
*
*    CATCH cx_salv_not_found.
*    CATCH cx_salv_data_error.
*    CATCH cx_salv_existing.
*  ENDTRY.
*
*  lr_columns = gr_alv->get_columns( ).
*  lr_columns->set_optimize( abap_true ).
*
*  TRY.
*      lr_column ?= lr_columns->get_column( 'MBLNR' ).
*      lr_column->set_output_length( 15 ).
*      lr_column->set_key( 'X' ).
*
*    CATCH cx_salv_not_found INTO lx_not_found.
*  ENDTRY.
*
*  TRY.
*      lv_title = 'M'.
*      lv_mtext = 'Год'(002).
*      lv_ltext = 'Год'(002).
*      lv_stext = 'Год документа'(002).
*      lr_column ?= lr_columns->get_column( 'MJAHR' ).
*      lr_column->set_short_text( lv_stext ).
*      lr_column->set_medium_text( lv_mtext ).
*      lr_column->set_long_text( lv_ltext ).
*      lr_column->set_fixed_header_text( lv_title ).
*    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
*  ENDTRY.
*
*  lr_events = gr_alv->get_event( ).
*
*  CREATE OBJECT lr_receiver.
*
*  SET HANDLER lr_receiver->handle_doubleclick_mkpf
*      FOR lr_events.

*  gr_display = gr_alv->get_display_settings( ).

  " Рисуем стандартный тулбар ALV
  lr_functions = gr_alv->get_functions( ).

  IF lr_functions IS BOUND.
    lr_functions->set_all( abap_true ).

    " Добавляем свой тулбар
    lv_icon = icon_word_processing.
*      try.
*        lr_functions->add_function(
*          name     = 'ADDFUNC'
*          icon     =  lv_icon
*          text     = 'Export'
*          tooltip  = 'Export to Word'
*          position = if_salv_c_function_position=>right_of_salv_functions ).
*        catch cx_salv_existing cx_salv_wrong_call.
*      endtry.
  ENDIF.

  gr_alv->set_screen_status(
    pfstatus      =  'SALV_STANDARD'
    report        =  ls_key-report
    set_functions = gr_alv->c_functions_all ).

  gr_alv->display( ).

ENDFORM.

FORM process_button.

ENDFORM.
