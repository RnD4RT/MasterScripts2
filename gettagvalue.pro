;+
; ==============================================================================
;
; FILE NAME:    GetTagvalue.pro
;
; DESCRIPTION:	The function indentifies the value corresponding to a specified
;		tag name. If the tag is not found, the function returns -1.
;		Otherwise, the value associated with the tage name is returned.
;
; PARAMETERS:
;	Input:	
;		data - structure of data
;		tag - string holding the tag ID
;
;	Output:
;	        error - 0 if routine fails, different from 0 otherwise
;               type - data type of returned value
;
; SYNTAX:	res = GetTagValue(data, tag, error, type)
;
; AUTHOR: 	Karsten Eilertsen, February 1997
;
; ==============================================================================
;-
FUNCTION GetTagValue, data, tag, error, type

  error = 1
  ; Check number of input parameters
  IF N_PARAMS() LT 2 THEN BEGIN
    PRINT, "SYNTAX: res = GetTagValue(data, tag)
    error = 0
    RETURN, -1
  ENDIF

  ; Check if data really is a struct
  ss = IsDefined(data, type_code)
  IF type_code NE 8 THEN BEGIN
    error = 0 
    RETURN, -1
  ENDIF

  ; Get all tag names
  names = TAG_NAMES(data)
  
  pos = WHERE(names EQ STRUPCASE(tag))
  
  IF pos(0) LT 0 THEN BEGIN
    error = 0
    RETURN, -1
  ENDIF
  
  ss = SIZE(data.(pos(0)))
  type = ss(N_ELEMENTS(ss)-2)
  
  RETURN, data.(pos(0))
  
END ; === End of GetTagValue ===================================================