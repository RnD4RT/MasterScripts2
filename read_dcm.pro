;+
;==================================================================
; FILE NAME:
;  read_dcm.pro
;
; DESCRIPTION:
;   Function to read an image from a file specified according
;   to the DICOM-3 standard. The procedure utilizes the IDL
;   object IDLffDICOM in order to access the DICOm file.
;
; PARAMETERS:
;   Input:
;     filename  - dicom object filename
;
;   Output:
;     The function returns the object data in an anonymous
;     structure on the following format :
;
;     object = { data: data, $
;                description: description }
;
;     'Data' is a structure containing all the tag values
;     that could be extracted from the dicom file.
;
;     The structure elements of this data structure are given tag names
;     according to the following rule:
;
;       'x'+ string containing the hexadecimal value of the group number +
;            string containing the hexadecimal value of the element number
;
;        Example: The patient name is, according to the DICOm standard,
;                 identifed by the group number '0010' and element number '0010'
;                 (hex values).
;
;                 The tag name for the patient name is therefore 'x00100010' and
;                  the name can retrieved from the structure element
;                 'object.data.x00100010'
;
;     'Description' is a string array that contains the description
;     of the extracted values as specified in the DICOM spesification PS 3.6.
;     There is a 1:1 relationship between the array elements of 'Description'
;     and the structure elements of 'Data'.
;
;
; KEYWORDS:
;   HEADER - set this keyword to make the routine extract only the object header
;            i.e. the tag (7FE0,0010) is skipped
;   STATUS - set keyword to a named variable that is set to 1 if the file
;            is a valid DICOM file, 0 otherwise
;
; SIDE EFFETCS:
;
; RESTRICTIONS:
;  Private objects are not extradcted.
;  The routine does not handle sequenses properly.
;
; SEE ALSO:
;   For more details regarding the group and element numbers, refer to
;   the DICOM Data Dictionary, i.e. PART 6 of the DICOM PS 3.6 publication
;
; SYNTAX:
;   read_dcm, filename, object, HEADER=header
;
; AUTHOR:
;   K.Eilertsen, October 1999
;
;==================================================================
;-


;==================================================================
;    FUNCTION Dec2Hec
;==================================================================
; DESCRIPTION:
;   Utility function that converts an integer number in decimal
;   units to the corresponding hexadecimal representation.
;   The hex number is returned as a string
;
; PARAMETERS:
;   Input:
;     num - decimal number
;
;   Output:
;     Function returns a string containg the hexadecimal value
;
; SYNTAX:
;   res = Dec2Hex(num)
;
;==================================================================
FUNCTION Dec2Hex, num

  ; Make sure input is integer
  val = LONG(num)

  mapping = STRTRIM((INDGEN(16)),2)
  mapping[10] = 'A'
  mapping[11] = 'B'
  mapping[12] = 'C'
  mapping[13] = 'D'
  mapping[14] = 'E'
  mapping[15] = 'F'

  pp3 = 16^3
  pp2 = 16^2
  pp1 = 16
  pp0 = 0

  p3 =  val/pp3
  p2 = (val - p3*pp3)/pp2
  p1 = (val - p3*pp3 - p2*pp2)/pp1
  p0 = val - p3*pp3 - p2*pp2 - p1*pp1

  RETURN, mapping(p3) + mapping(p2) + mapping(p1) + mapping(p0)

END ; === END of Dec2Hex ===



;==================================================================
;    FUNCTION ReadSequence
;==================================================================
; DESCRIPTION:
;   Utility function that reads the a sequence of tags
;   Sequences within sequences are handled recursively.
;
; PARAMETERS:
;   Input:
;     oDicom - Object reference to an IDLffDicom object
;              that contains a sequence
;     ref    - The refeerence to the tag that is the start
;              point for the sequence
;
;   Output:
;     numread - number of sequence tags read (optional)
;
;     Function returns a structure containg the seqeunce data
;
; SYNTAX:
;   res = ReadSequence (oDicom, ref, numread)
;
;==================================================================
FUNCTION ReadSequence, oDicom, ref, numread

  ; Get the the sequence children
  children = oDicom->GetChildren(ref)

  IF children[0] LT 0 THEN BEGIN
    ;numread = 0
    RETURN, -1
  ENDIF

  ; Get the description of the various objects
  desc = oDicom->GetDescription(REFERENCE=children)

  ; Get the group numbers
  groups = oDicom->GetGroup(REFERENCE=children)

  ; Convert the group number to hexadecimal values
  hexgroups = Dec2Hex(groups)

  ; Get the element numbers
  elements = oDicom->GetElement(REFERENCE=children)

  ; Convert the element numbers to hexadecimal values
  hexelements = Dec2Hex(elements)

  ; Get the value representation of object contents
  vr = oDicom->GetVR(REFERENCE=children)

  ; Loop through the list of children
  count = 0

  FOR i=0, N_ELEMENTS(children)-1 DO BEGIN
    ; Create the new tagname
    tagname = 'X' + hexgroups[i] + hexelements[i]

    ; Check for a sequence within a sequence
    CASE vr[i] OF

      'SQ': BEGIN
        ; Read sequence
        sqdata = ReadSequence(oDicom,children[i], numread)

        ; Update number of elements read, i.e. in this case a sequence tag
        ;numread = numread + 1

        ; Check if sequence tag already exists
        IF IsDefined(data) THEN BEGIN
          tagval = GetTagValue(data, tagname, sq_exist)
          IF sq_exist THEN BEGIN
            ; The sequence exists - append the new sequence structure
            ; to the existing array of sequences.

            ; Extract tagvalue and struct position
            tags = TAG_NAMES(data)
            pos = WHERE(tagname EQ tags)
            pos = pos[0]

            ; Define new tagvalue and new struct
            newtagval = [data.(pos[0]),PTR_NEW(sqdata)]
            newdata = CREATE_STRUCT(tagname, newtagval)

            ; Copy remaining data struct to the new data struct
            FOR k=0, N_TAGS(data)-1 DO $
              IF k NE pos THEN $
              newdata = CREATE_STRUCT(newdata, tags[k],data.(k))

            ; Assign newdata to data
            data = newdata

            ; Increment number of tags read, i.e. numread
            numread = numread + 1
          ENDIF ELSE BEGIN
            ; New sequence to be appended to the data structure
            data = CREATE_STRUCT(data, tagname, [PTR_NEW(sqdata)])

            ; Increment number of tags read, i.e. numread
            numread = numread + 1
          ENDELSE
        ENDIF ELSE BEGIN
          ; Create a new data structure
          data = CREATE_STRUCT(tagname, [PTR_NEW(sqdata)])

          ; Increment number of tags read, i.e. numread
          numread = numread + 1
        ENDELSE
      END

      ELSE: BEGIN
        ; Extract the sequence data
        ; Get the pointers to the object data values
        val = oDicom->GetValue(REFERENCE=children[i],/NO_COPY)

        IF IsDefined(data) THEN BEGIN
          tagval = GetTagValue(data, tagname, tag_exist)

          IF tag_exist THEN BEGIN
            ; The tag already exists
            ; Extract tagvalue and struct position
            tags = TAG_NAMES(data)
            pos = WHERE(tagname EQ tags)
            pos = pos[0]

            ; Define new tagvalue and new struct
            newtagval = [data.(pos[0]),*val[0]]
            newdata = CREATE_STRUCT(tagname, newtagval)

            ; Copy remaining data struct to the new data struct
            FOR k=0, N_TAGS(data)-1 DO $
              IF k NE pos THEN $
              newdata = CREATE_STRUCT(newdata, tags[k],data.(k))

            ; Assign newdata to data
            data = newdata

            ; Increment number of tags read, i.e. numread
            numread = numread + 1
          ENDIF ELSE BEGIN
            ; New tag to be appended to the data structure
            data = CREATE_STRUCT(data, tagname, [*val[0]])

            ; Increment number of tags read, i.e. numread
            numread = numread + 1
          ENDELSE
        ENDIF ELSE BEGIN
          ; Create a new data strcuture
          data = CREATE_STRUCT(tagname, [*val[0]])

          ; Increment number of tags read, i.e. numread
          numread = numread + 1
        ENDELSE
      ENDELSE
    ENDCASE
  ENDFOR

  RETURN,data
END



PRO Read_dcm, filename, object, IMAGE=image, HEADER=header, SILENT=silent, STATUS=status

  ; Set up error handling
;  CATCH, errorStatus
;  IF (errorStatus NE 0) THEN BEGIN
;    CATCH,/CANCEL
;    PRINT, !ERR_STRING
;    IF NOT KEYWORD_SET(SILENT) THEN $
;      res = DIALOG_MESSAGE(!ERR_STRING, /ERROR, TITLE='READ_DCM.PRO')
;    IF (OBJ_VALID(oDicom)) THEN OBJ_DESTROY, oDicom
;    RETURN
;  ENDIF

  ; Create the DICOM object
  oDicom = OBJ_NEW('IDLffDICOM')
  IF (NOT OBJ_VALID(oDicom)) THEN BEGIN
    msg = 'IDLffDICOM object not supported on this platform.'
    MESSAGE, msg
  END

  ; Open the file
  IF (oDicom->Read(filename) NE 1) THEN BEGIN
    msg = 'The file '+filename+' is not in a supported DICOM format.'
    ;MESSAGE, msg
    PRINT, msg
    status=0
    RETURN
  END
  status = 1

  ; Get a reference to all the tags in the file
  ref = oDicom->GetReference()

  ; Get the description of the various objects
  desc = oDicom->GetDescription()

  ; Get the group numbers
  groups = oDicom->GetGroup()

  ; Convert the group number to hexadecimal values
  hexgroups = Dec2Hex(groups)

  ; Get the element numbers
  elements = oDicom->GetElement()

  ; Convert the element numbers to hexadecimal values
  hexelements = Dec2Hex(elements)

  ; Get the value representation of object contents
  vr = oDicom->GetVR()

  ; Skip all private objects for now
;  indx = WHERE ( (groups MOD 2) EQ 0)
;
;  ref = ref[indx]
;  groups = groups[indx]
;  elements = elements[indx]
;  hexgroups = hexgroups[indx]
;  hexelements = hexelements[indx]
;  desc = desc[ref]
;  vr = vr[indx]

  ; Get the pointers to the object data values
  val = oDicom->GetValue(REFERENCE=ref,/NO_COPY)

  ; Check keyword settings
  num = N_ELEMENTS(val) - 1

  ; Only extract image ??
  IF KEYWORD_SET(image) THEN BEGIN
    image = oDicom->GetValue('7FE0'x,'0010')
  ENDIF

  IF KEYWORD_SET(header) THEN num = N_ELEMENTS(val) - 2

;stop

  ; Loop over all tag items
  numread = 0
  i = 0
  ;FOR i=0, num DO BEGIN
  WHILE numread LE num DO BEGIN
    ; Create the structure tagname to use
    tagname = 'x' + hexgroups[i] + hexelements[i]

    ; Look for a sequence
    IF vr[i] EQ 'SQ' THEN BEGIN
      ; Read Sequence
      sqdata = ReadSequence(oDicom, ref[i], numread )

      ; Make sure sequence contained data
      IF numread GT 0 THEN BEGIN

        tagval = GetTagValue(data, tagname, sq_exist)
        IF sq_exist THEN BEGIN
          ; The sequence exists - append the new sequence structure
          ; to the existing arrray of sequences.

          ; Extract tagvalue and struct position
          tags = TAG_NAMES(data)
          pos = WHERE(tagname EQ tags)
          pos = pos[0]

          ; Define new tagvalue and new struct
          newtagval = [data.(pos[0]),PTR_NEW(sqdata)]
          newdata = CREATE_STRUCT(tagname, newtagval)

          ; Copy remaining data struct to the new data struct
          FOR k=0, N_TAGS(data)-1 DO $
            IF k NE pos THEN $
              newdata = CREATE_STRUCT(newdata, tags[k],data.(k))

          ; Assign newdata to data
          data = newdata

          ; Increment number of tags read, i.e. numread
          numread = numread + 1
        ENDIF ELSE BEGIN
          ; New sequence to be appended to the data structure
          data = CREATE_STRUCT(data, tagname, [PTR_NEW(sqdata)])

          ; Increment number of tags read, i.e. numread
          numread = numread + 1
        ENDELSE
      ENDIF
    ENDIF ELSE IF elements[i] EQ '0000'x THEN BEGIN
      ; Skip Group lenghts
      desc[i] = "SKIPPED
      numread = numread + 1
    ENDIF ELSE IF elements[i] EQ '0001'x THEN BEGIN
      ; Skip lenght to end
      desc[i] = "SKIPPED"
      numread = numread + 1
    ENDIF ELSE BEGIN
      ; Make sure the val pointer is valid ..
      IF PTR_VALID( val[i] ) THEN BEGIN

        ; Is the data structure defined ?
        IF N_ELEMENTS(data) NE 0 THEN BEGIN
          ; Data is defined. Append new tag

          ; Handle image data separately
          IF groups[i] EQ '07FE0'x AND elements[i] EQ '0010'x THEN BEGIN
            ; Multiframe ??
            num_frames = GetTagValue(data, 'X00280008', multi_frame_exist)
            IF multi_frame_exist THEN BEGIN
              dim = SIZE(*val[i], /DIM)

              ; Pixel representation
              IF data.x00280103 EQ 0 THEN $
                frames = UINTARR(dim[0],dim[1],FIX(num_frames)) ELSE $
                frames = INTARR(dim[0],dim[1],FIX(num_frames))

              ; Read the frames
              FOR k=0, FIX(num_frames)-1 DO frames[*,*,k] = *val[i+k]

              ; Append the multiframe image
              data = CREATE_STRUCT( data, tagname, frames )

              ; Increment number of tags red
              numread = numread + FIX(num_frames)
            ENDIF ELSE BEGIN
              ; Append single frame
              data = CREATE_STRUCT( data, tagname, *val[i] )
              ; Increment number tags read
              numread = numread + 1
            ENDELSE
          ENDIF ELSE BEGIN
            ; Append tag
            ;data = CREATE_STRUCT( data, tagname, *val[i] )
            IF SIZE(*val[i], /TYPE) EQ 7 THEN BEGIN
              indx =  WHERE(BYTE(*val[i]) GE 1)
              IF STRLEN(*val[i]) GT 0 AND indx[0] GE 0 THEN BEGIN
                data = CREATE_STRUCT(data, tagname, STRING((BYTE(*val[i]))(indx)))
              ENDIF
            ENDIF ELSE data = CREATE_STRUCT(data, tagname, *val[i])
            ; Increment number tags read
            numread = numread + 1
          ENDELSE
        ENDIF ELSE BEGIN
          ; Create the data structure
          ;data = CREATE_STRUCT( tagname, *val[i])
          IF SIZE(*val[i], /TYPE) EQ 7 THEN BEGIN
            IF STRLEN(*val[i]) GT 0 THEN BEGIN
              data = CREATE_STRUCT( tagname, STRING((BYTE(*val[i]))(WHERE(BYTE(*val[i]) GE 1))))
            ENDIF
          ENDIF ELSE data = CREATE_STRUCT( tagname, *val[i])
          ; Increment number tags read
          numread = numread + 1
        ENDELSE

      ENDIF ELSE BEGIN
        ; Val is not a valid pointer reference
        IF SIZE(data, /TYPE) NE 0 THEN $
          data = CREATE_STRUCT( data, tagname, "NaN" ) ELSE $
          data = CREATE_STRUCT( tagname, "NaN" )

         ; Increment number of tags read
         numread = numread + 1
       ENDELSE
    ENDELSE
    i = numread
  ENDWHILE

  ; Destroy the object reference
  OBJ_DESTROY, oDicom

  ; Extract the descriptions for those elements that were not skipped
  indx = WHERE(desc NE "SKIPPED")

  ; Create the return structure
  object = { data: data, description: desc(indx) }

  RETURN

END ; ============ End Read_DCM ======================================================
