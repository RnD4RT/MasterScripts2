;+
;==============================================================================
;
; DESCRIPTION:	This function determines whether a given variable is defined
;		or not. If defined, the function returns the logical value
;		for TRUE (i.e. a value differant from zero). Otherwise, the
;		function returns FALSE (i.e. zero). In addtion, the function
;		will return the IDL typecode if the reurn parameter "typecode" 
;		is specified. 
;
; PARAMETERS:
;	Input: 
;		var - input variable 
;	Output:
;		type_code - The IDL typecode for var
;	
;		Function returns 1 if var is defined, 
;		and 0 if var is undefined.
;
; SYNTAX: 	res = IsDefined(var, typecode)
;
; AUTHOR: 	Karsten Eilertsen, DNR, February 1997
;		
;==============================================================================
;-
FUNCTION IsDefined, var, type_code

  ss = SIZE(var)
  
  type_code = ss(N_ELEMENTS(ss)-2)
  IF type_code EQ 0 THEN RETURN, 0 ELSE RETURN,1 
  
END
  