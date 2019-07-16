"! FastRWebABAPConnector Interface
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
INTERFACE zz_if_fastrweb_connector
  PUBLIC .

  TYPES:
    "! key value structure type
    BEGIN OF mts_key_value,
      key   TYPE string,
      value TYPE REF TO data,
    END OF mts_key_value.

  "! key value table type
  TYPES mtt_key_value TYPE STANDARD TABLE OF mts_key_value WITH DEFAULT KEY.

  "! result key
  CONSTANTS mc_result_key TYPE string VALUE 'result'.

  "! result type - JSON
  CONSTANTS mc_result_type_json TYPE string VALUE 'JSON'.
  "! result type - Image
  CONSTANTS mc_result_type_image TYPE string VALUE 'IMAGE'.

  "! execute R script
  "! @parameter it_parameter | parameter
  "! @parameter ct_result | result
  "! @raising cx_t100_msg | exception
  METHODS execute_rscript IMPORTING it_parameter TYPE mtt_key_value OPTIONAL
                          CHANGING  ct_result    TYPE mtt_key_value
                          RAISING   cx_t100_msg.

ENDINTERFACE.