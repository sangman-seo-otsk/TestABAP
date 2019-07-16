"! FastRWebABAPConnector Class
"!
"! Copyright (c) 2016 Florian Pfeffer
"!
"! Licensed under the Apache License, Version 2.0 (the "License");
"! you may not use this file except in compliance with the License.
"! You may obtain a copy of the License at
"!
"!    http://www.apache.org/licenses/LICENSE-2.0
"!
"! Unless required by applicable law or agreed to in writing, software
"! distributed under the License is distributed on an "AS IS" BASIS,
"! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
"! See the License for the specific language governing permissions and
"! limitations under the License.
"!
CLASS zz_cl_fastrweb_connector DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zz_if_fastrweb_connector.
    ALIASES execute_script FOR zz_if_fastrweb_connector~execute_rscript.

    "! constructor
    "! @parameter iv_result_type | result type
    "! @parameter iv_destination | destination
    "! @parameter iv_rscript_path | path to R script
    METHODS constructor IMPORTING iv_result_type  TYPE string
                                  iv_destination  TYPE rfcdest
                                  iv_rscript_path TYPE string.


  PROTECTED SECTION.

  PRIVATE SECTION.
    "! default timeout 5000s
    CONSTANTS mc_default_timeout TYPE i VALUE 5000.

    "! result type
    DATA mv_result_type TYPE string.
    "! RFC destination
    DATA mv_destination TYPE rfcdest.
    "! path to R script
    DATA mv_rscript_path TYPE string.
    "! http client
    DATA mo_http_client TYPE REF TO if_http_client.

    "! result type - setter
    "! @parameter iv_result_type | result type
    METHODS set_result_type IMPORTING iv_result_type TYPE string.

    "! result type - getter
    "! @parameter rv_result_type | result type
    METHODS get_result_type RETURNING VALUE(rv_result_type) TYPE string.

    "! destination - setter
    "! @parameter iv_destination | destination
    METHODS set_destination IMPORTING iv_destination TYPE rfcdest.
    "! destination - getter
    "! @parameter rv_destination | destination
    METHODS get_destination RETURNING VALUE(rv_destination) TYPE rfcdest.

    "! R script path - setter
    "! @parameter iv_rscript_path | R script path
    METHODS set_rscript_path IMPORTING iv_rscript_path TYPE string.
    "! R script path - getter
    "! @parameter rv_rscript_path | R script path
    METHODS get_rscript_path RETURNING VALUE(rv_rscript_path) TYPE string.

    "! http client - setter
    "! @parameter io_http_client | http client
    METHODS set_http_client IMPORTING io_http_client TYPE REF TO if_http_client.
    "! http client - getter
    "! @parameter ro_http_client |
    METHODS get_http_client RETURNING VALUE(ro_http_client) TYPE REF TO if_http_client.

    "! execute R script - inner logic
    "! @parameter it_parameter | parameter
    "! @parameter ct_result | result
    "! @raising cx_t100_msg | exception
    METHODS inner_execute_rscript IMPORTING it_parameter TYPE zz_if_fastrweb_connector=>mtt_key_value
                                  CHANGING  ct_result    TYPE zz_if_fastrweb_connector=>mtt_key_value
                                  RAISING   cx_t100_msg.

    "! create http client
    "! @raising cx_t100_msg | exception
    METHODS create_http_client RAISING cx_t100_msg.

    "! prepare http request
    "! @parameter it_parameter | parameter
    METHODS prepare_http_request IMPORTING it_parameter TYPE zz_if_fastrweb_connector=>mtt_key_value.

    "! send http request
    "! @raising cx_t100_msg | exception
    METHODS send_http_request RAISING cx_t100_msg.

    "! handle http response
    "! @parameter ct_result | result
    "! @raising cx_t100_msg | exception
    METHODS handle_http_response CHANGING ct_result TYPE zz_if_fastrweb_connector=>mtt_key_value
                                 RAISING  cx_t100_msg.

    "! cleanup
    "! @raising cx_t100_msg | exception
    METHODS cleanup RAISING cx_t100_msg.

    "! helper for exception raising
    "! @raising cx_t100_msg | exception
    METHODS raise_cx_t100_msg RAISING cx_t100_msg.

    "! transform to JSON string
    METHODS transform_to_json_string IMPORTING ir_data               TYPE REF TO data
                                     RETURNING VALUE(rv_json_string) TYPE string.

    "! transform from JSON string
    METHODS transform_from_json_string IMPORTING iv_json_string TYPE string
                                       CHANGING  cr_data        TYPE REF TO data.
ENDCLASS.



CLASS zz_cl_fastrweb_connector IMPLEMENTATION.

  METHOD constructor.
    set_result_type( iv_result_type ).
    set_destination( iv_destination ).
    set_rscript_path( iv_rscript_path ).
  ENDMETHOD.

  METHOD set_result_type.
    mv_result_type = iv_result_type.
  ENDMETHOD.

  METHOD get_result_type.
    rv_result_type = mv_result_type.
  ENDMETHOD.

  METHOD set_destination.
    mv_destination = iv_destination.
  ENDMETHOD.

  METHOD get_destination.
    rv_destination = mv_destination.
  ENDMETHOD.

  METHOD set_rscript_path.
    mv_rscript_path = iv_rscript_path.
  ENDMETHOD.

  METHOD get_rscript_path.
    rv_rscript_path = mv_rscript_path.
  ENDMETHOD.

  METHOD set_http_client.
    mo_http_client = io_http_client.
  ENDMETHOD.

  METHOD get_http_client.
    ro_http_client = mo_http_client.
  ENDMETHOD.

  METHOD zz_if_fastrweb_connector~execute_rscript.
    inner_execute_rscript( EXPORTING it_parameter = it_parameter CHANGING ct_result = ct_result ).
  ENDMETHOD.

  METHOD inner_execute_rscript.
    create_http_client( ).

    prepare_http_request( it_parameter = it_parameter ).

    send_http_request( ).

    handle_http_response( CHANGING ct_result = ct_result ).

    cleanup( ).
  ENDMETHOD.

  METHOD create_http_client.
    cl_http_client=>create_by_destination(
    EXPORTING
      destination              = get_destination( )
    IMPORTING
      client                   = DATA(lo_http_client)
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6 ).
    IF sy-subrc <> 0.
      raise_cx_t100_msg( ).
    ENDIF.

    set_http_client( lo_http_client ).
  ENDMETHOD.

  METHOD prepare_http_request.
    get_http_client( )->request->set_version( if_http_request=>co_protocol_version_1_1 ).
    get_http_client( )->request->set_method( method = if_http_request=>co_request_method_get ).

    IF NOT it_parameter[] IS INITIAL.
      DATA(lv_parameter) = REDUCE string( INIT res = || FOR ls_par IN it_parameter NEXT res = res && ls_par-key && '=' && transform_to_json_string( ls_par-value ) && '&' ).
      DATA(lv_length) = strlen( lv_parameter ) - 1.
      lv_parameter = lv_parameter+0(lv_length).
      lv_parameter = '?' && lv_parameter.
    ENDIF.

    cl_http_utility=>set_request_uri( request = get_http_client( )->request
                                      uri = get_rscript_path( ) && lv_parameter ).
  ENDMETHOD.

  METHOD send_http_request.
    get_http_client( )->send(
      EXPORTING
        timeout                    = mc_default_timeout
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        OTHERS                     = 5 ).
    IF sy-subrc <> 0.
      raise_cx_t100_msg( ).
    ENDIF.
  ENDMETHOD.

  METHOD handle_http_response.
    get_http_client( )->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      raise_cx_t100_msg( ).
    ENDIF.

    get_http_client( )->response->get_status( IMPORTING reason = DATA(lv_http_reason) ).

    IF lv_http_reason <> if_http_status=>reason_200.
      RETURN.
    ENDIF.

    IF line_exists( ct_result[ key = zz_if_fastrweb_connector=>mc_result_key ] ).
      CASE get_result_type( ).
        WHEN zz_if_fastrweb_connector=>mc_result_type_json.
          transform_from_json_string( EXPORTING iv_json_string = get_http_client( )->response->get_cdata( )
                                      CHANGING cr_data = ct_result[ key = zz_if_fastrweb_connector=>mc_result_key ]-value ).
        WHEN zz_if_fastrweb_connector=>mc_result_type_image.
          FIELD-SYMBOLS <la_any> TYPE any.

          DATA(lr_data) = ct_result[ key = zz_if_fastrweb_connector=>mc_result_key ]-value.

          ASSIGN lr_data->* TO <la_any>.

          IF <la_any> IS ASSIGNED.
            <la_any> = get_http_client( )->response->get_data( ).
          ENDIF.
      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
    get_http_client( )->close(
      EXCEPTIONS
        http_invalid_state = 1
        OTHERS             = 2 ).
    IF sy-subrc <> 0.
      raise_cx_t100_msg( ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_cx_t100_msg.
    RAISE EXCEPTION TYPE cx_t100_msg
      EXPORTING
        t100_msgid = sy-msgid
        t100_msgno = sy-msgno
        t100_msgv1 = CONV string( sy-msgv1 )
        t100_msgv2 = CONV string( sy-msgv2 )
        t100_msgv3 = CONV string( sy-msgv3 )
        t100_msgv4 = CONV string( sy-msgv4 ).
  ENDMETHOD.

  METHOD transform_to_json_string.
    FIELD-SYMBOLS <la_any> TYPE any.

    DATA(lo_json_writer) = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

    ASSIGN ir_data->* TO <la_any>.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CALL TRANSFORMATION id SOURCE data = <la_any>
                           RESULT XML lo_json_writer.

    DATA(lv_json_xstring) = lo_json_writer->get_output( ).

    DATA(lo_converter) = cl_abap_conv_in_ce=>create( input = lv_json_xstring ).

    lo_converter->read( IMPORTING data = rv_json_string ).
  ENDMETHOD.

  METHOD transform_from_json_string.
    FIELD-SYMBOLS <la_any> TYPE any.

    IF iv_json_string IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN cr_data->* TO <la_any>.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CALL TRANSFORMATION id SOURCE XML iv_json_string
                           RESULT data = <la_any>.
  ENDMETHOD.

ENDCLASS.