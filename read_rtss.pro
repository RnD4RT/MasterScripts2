;+
;==================================================================
; FILE NAME:
;  read_rtss.pro
;
; DESCRIPTION:
;   Function to read a DICOM Structure Set File. The bulk of
;   of the work is handled by the procedure Read_DCM.pro. See
;   this file for details.
;
; PARAMETERS:
;   Input:
;     filename  - dicom object filename
;
;   Output:
;     rtss -  Structure that contains the Strucure Set data.
;
; SIDE EFFETCS:
;   <none>
;
; RESTRICTIONS:
;   Private tags are skipped
;
; SEE ALSO:
;   For more information regarding the stucture set data, refere to
;   DICOM Standard, Part 3.
;
; SYNTAX:
;   read_rtss, filename, objstructure
;
; AUTHOR:
;   K.Eilertsen, Nvember 2001
;
;==================================================================
;-
PRO Read_RTSS, file, rtss


  ; Make sure that file exist
  IF NOT FILE_TEST(file, /REGULAR, /READ) THEN BEGIN
    msg = [ 'The file ', $
            ' ', $
            file, $
            ' ', $
            'could not be found or opened.' ]
    dia = DIALOG_MESSAGE( msg, /ERR, DIALOG_PARENT=parent, TITLE='Read_RTSS')
    RETURN
  ENDIF

  ; Read the structure file
  READ_DCM, file, rtstruct


  ; Extract main features from strucure set such as ..
  ;
  date = STRTRIM(rtstruct.data.x00080020,2)
  time = STRTRIM(rtstruct.data.x00080030,2)

;  rtss = CREATE_STRUCT( 'datetime',  date+time, $
;                        'modality', STRTRIM(rtstruct.data.x00080060,2), $
;                        'patname', STRTRIM(rtstruct.data.x00100010,2), $
;                        'patid', STRTRIM(rtstruct.data.x00100020,2), $
;                        'studyid', STRTRIM(rtstruct.data.x00200010,2), $
;                        'label', STRTRIM(rtstruct.data.x30060002,2))
;                        
;  rtss = CREATE_STRUCT( 'datetime',  date+time, $
;                        'modality', STRTRIM(rtstruct.data.x00080060,2), $
;                        'patname', STRTRIM(rtstruct.data.x00100010,2), $
;                        'patid', STRTRIM(rtstruct.data.x00100020,2), $
;                        'label', STRTRIM(rtstruct.data.x30060002,2))

rtss = CREATE_STRUCT( 'datetime',  date+time, $
                        'modality', STRTRIM(rtstruct.data.x00080060,2), $
                        ;'patname', STRTRIM(rtstruct.data.x00100010,2), $
                        ;'patid', STRTRIM(rtstruct.data.x00100020,2), $
                        'label', STRTRIM(rtstruct.data.x30060002,2))
                                          

  manufacturer = GetTagValue(rtstruct.data, 'X00080070', exist)
  IF exist THEN $
    rtss = CREATE_STRUCT( rtss, 'manufacturer', STRTRIM(manufacturer,2))

  software = GetTagValue(rtstruct.data, 'X00181020', exist)
  IF exist THEN $
    rtss = CREATE_STRUCT( rtss, 'software', STRTRIM(software,2))

  ; Contour data and ReferencedSOPInstanceUID
  ;

  ; Look for  Referenced FrameOfReferenceSequence (FORSQ)
  val = GetTagValue( rtstruct.data, 'X30060010', exist)
  IF exist THEN BEGIN
    ; Define pointer array to hold FOR structures
    p_for = PTRARR(N_ELEMENTS(val))

    FOR i=0, N_ELEMENTS(val)-1 DO BEGIN
      ; Make shortcut to the FORSQ
      forsq = *val[i]

      ; Create a structure to hold the FOR data
      fors = CREATE_STRUCT( 'FrameOfRefUID', forsq.x00200052)

      ; Look for a ReferencedStudySQ (RSSQ)
      refstudy = GetTagValue(forsq, 'X30060012', exist)
      IF exist THEN BEGIN
        ; Define pointer array to hold refstudysq structures
        p_refstudy = PTRARR(N_ELEMENTS(refstudy))

        FOR j=0, N_ELEMENTS(refstudy)-1 DO BEGIN
          ; Make a shortcut to the RSSQ
          rssq = *refstudy[j]

          ; Create a structure to hold the refstudy data
          refstudys = CREATE_STRUCT( 'RefSOPClassUID', rssq.x00081150[0], $
                                     'RefSOPInstUID', rssq.x00081155[0])

          ; Loop over all ReferencedSeries sequences
          ; (this is type 1C, i.e. must present)
          ;Create a ptr array to hold all refseries
          p_refseries = PTRARR(N_ELEMENTS(rssq.x30060014))
          FOR k=0, N_ELEMENTS(rssq.x30060014)-1 DO BEGIN
            rsesq = *rssq.x30060014[k]

            ; Create a structure to hold the ref series data
            refseries = CREATE_STRUCT( 'SerInstUID', rsesq.x0020000E[k])

            ; Loop over all ContourImageSq
            ; Create a pointer array to hold the contour image data
            p_contimg = PTRARR(N_ELEMENTS(rsesq.x30060016))
            FOR l=0, N_ELEMENTS(rsesq.x30060016)-1 DO BEGIN
              ; Make shortcut to contour image sq
              cisq = *rsesq.x30060016[l]

              ; Create structure to hold the contour image sq data
              contimg = CREATE_STRUCT( 'RefSOPClass',   cisq.x00081150, $
                                       'RefSOPInstUID', cisq.x00081155 )

              p_contimg[l] = PTR_NEW(contimg)
            ENDFOR
            ; Append the contimg ptr array to the series structure
            refseries = CREATE_STRUCT( refseries, $
                                       'ContourImages', p_contimg)

            p_refseries[k] = PTR_NEW(refseries)
          ENDFOR

          ; Append the ref.series ptr array to the refstudy structure
          refstudys = CREATE_STRUCT( refstudys, $
                                     'RefSeries', p_refseries)
          p_refstudy[j] = PTR_NEW(refstudys)
        ENDFOR

        ; Append the refstudySQ to FORS
        fors = CREATE_STRUCT(fors, 'RefStudy', p_refstudy)
      ENDIF

      ; Append p_for
      p_for[i] = PTR_NEW(fors)
    ENDFOR
    ; Append FOR to RTSS
    rtss = CREATE_STRUCT(rtss, 'RefFrameOfRef', p_for)
  ENDIF


  ; Look for a StructuresetROI SQ (SSROISQ)
  val = GetTagValue( rtstruct.data, 'X30060020', exist)
  IF exist THEN BEGIN
    ; Define a ptr array to hold the Structure Set ROI data
    p_ssroi = PTRARR(N_ELEMENTS(val))
    FOR i=0, N_ELEMENTS(val)-1 DO BEGIN
      ; Make a shortcut to SSROISQ)
      ssroisq = *(rtstruct.data).x30060020[i]

      ; Create structure to hold ROI daata
      ; Mandatory
      ssrois = CREATE_STRUCT( 'ROInum',  ssroisq.x30060022, $
                              'ROIname', ssroisq.x30060026)

      ; Append ROI description if present
      roidesc = GetTagValue(ssroisq, 'X30060028', exist)
      IF exist THEN $
        ssrois = CREATE_STRUCT( ssrois, 'ROIDescription', roidesc)

      ; Append ROI volume if present
      roivol = GetTagValue(ssroisq, 'X3006002C', exist)
      IF exist THEN $
        ssrois = CREATE_STRUCT( ssrois, 'ROIVolume', roivol)

      ; Append structure to ptr array
      p_ssroi[i] = PTR_NEW(ssrois)
    ENDFOR

    ; Append pointer to rtss
    rtss = CREATE_STRUCT( rtss, 'StructureSetROI', p_ssroi)
  ENDIF


  ; Look for a ROIContour module (ROICMSQ)
  val = GetTagValue(rtstruct.data, 'X30060039', exist)
  IF exist THEN BEGIN
    ; Define pointer array to hold ROICM structures
    p_roicm = PTRARR(N_ELEMENTS(val))

    FOR i=0, N_ELEMENTS(val)-1 DO BEGIN
      ; Make a shortcut to a ROICSQ)
      roicmsq = *(rtstruct.data).x30060039[i]

      ; Create a structure to hold the ROIContourModule SQ data
      roicm = CREATE_STRUCT( 'RefROINum', roicmsq.x30060084)

      ; Get ROI colors - if present
      roicolor = GetTagValue(roicmsq, 'X3006002A', exist)
      IF exist THEN $
        roicm = CREATE_STRUCT(roicm, 'ROIColor', roicolor)

      ; Look for Contour SQ
      csq = GetTagValue(roicmsq, 'X30060040', exist)
    dum=0
      IF exist THEN BEGIN
        ; Make a pointer array to hold the contour data
        p_contour = PTRARR(N_ELEMENTS(csq))

        FOR j=0, N_ELEMENTS(csq)-1 DO BEGIN
          ; Create a structure to hold the contour data
          contour = CREATE_STRUCT( 'contourtype', (*csq[j]).x30060042, $
                                   'numpoints', (*csq[j]).x30060046)

          ; Extract the contour data for all the image planes
          cdata = (*csq[j]).x30060050
          cc3D = CREATE_STRUCT( 'RefROInumber',roicmsq.x30060084[j])
          ;---------------------endring-----------
            cont=fltarr(3,199000)
            dum=0

         ;-----------------
          FOR k=0, N_ELEMENTS(cdata)-1 DO BEGIN
            num = contour.numpoints[k]
            indx = INDGEN(num)*3

            d = STRSPLIT(cdata[k], '\', /EXTRACT)
            x = d[indx]
            y = d[indx+1]
            z = d[indx+2]
            cc = FLOAT(TRANSPOSE([[x],[y],[z]]))
         ;----------------------endring-------------------------
         lengde=+n_elements(x)-1

         cont(0,dum:dum+lengde)=cc(0,*)
         cont(1, dum:dum+lengde)=cc(1,*)
         cont(2, dum:dum+lengde)=cc(2,*)
         ;print, cont
         dum=dum+n_elements(x)
         ;-----------------------------------------------
            cc3d = CREATE_STRUCT( cc3D, 'c'+STRTRIM(k+1,2), cc)
          ENDFOR
          ; Append the roi data to the contour structure
          contour = CREATE_STRUCT( contour, 'data', cc3d)


              ; Get hold of the referenced images, i.e. SOPInstanceUIDS and SOPClass
          imgsq = GetTagValue( *csq[j], 'X30060016', exist)
          IF exist THEN BEGIN
            RefSOPInstUID = STRARR(N_ELEMENTS((*csq[j]).x30060016))
            RefSOPClass   = STRARR(N_ELEMENTS((*csq[j]).x30060016))
            FOR k=0, N_ELEMENTS((*csq[j]).x30060016)-1 DO BEGIN
               RefSOPInstUID[k] = (*(*csq[j]).x30060016[k]).x00081155[0]
               RefSOPClass[k]   = (*(*csq[j]).x30060016[k]).x00081150[0]
            ENDFOR

            ; Append to structure
            contour = CREATE_STRUCT( contour, $
                                     'RefSOPInstUID', RefSOPInstUID,$
                                     'RefSOPClass', RefSOPClass)
          ENDIF

          ; Append the contour to the contour ptr array
          p_contour[j] = PTR_NEW(contour)
        ENDFOR
        ; Append the pointer to the roicm
        roicm = CREATE_STRUCT(roicm, 'contours', p_contour)
      ENDIF

      ; Append structure to the pointer array
      p_roicm[i] = PTR_NEW(roicm)
    ENDFOR
    ; Append to RTSS
    rtss = CREATE_STRUCT( rtss, 'ROIContourModule', p_roicm)
  ENDIF


  ; Look for a ROI Observation Module)
  val = GetTagValue(rtstruct.data, 'X30060080', exist)
  IF exist THEN BEGIN
    ; Define pointer array to hold ROI Obs. modules
    p_roiom = PTRARR(N_ELEMENTS(val))

    FOR i=0, N_ELEMENTS(val)-1 DO BEGIN
      ; Append Referenced ROI Numbers
      roioms = CREATE_STRUCT( 'ObsNum',   (*val[i]).x30060082, $
                              'RefROInum',(*val[i]).x30060084)

      roitype = GetTagValue((*val[i]), 'X300600A4', exist)
      IF exist THEN $
        roioms = CREATE_STRUCT( roioms,'ROItype', roitype)

      ; Append the observation structure to the pointer array
      p_roiom[i] = PTR_NEW(roioms)
    ENDFOR
    ; Append structure to RTSS
    rtss = CREATE_STRUCT( rtss, 'ROIObsModule', p_roiom)
  ENDIF
  ;stop
END ; === End of Read_RTSS.pro =============================================