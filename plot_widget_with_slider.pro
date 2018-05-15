pro PLOT_WIDGET_DOC_EVENT, event
  CASE TAG_NAMES(event, /STRUCTURE_NAME) OF
    'WIDGET_SLIDER': BEGIN
      WIDGET_CONTROL, event.id, GET_UVALUE = event_UV
      ; Retrieve the Widget Window
      wDraw = WIDGET_INFO(event.top, FIND_BY_UNAME = 'DRAW')
      WIDGET_CONTROL, wDraw, GET_VALUE = graphicWin
      
      WIDGET_CONTROL, event.top, GET_UVALUE = point_z

      ; Retrieve the plot with the NAME
      ; provided on plot creation
      slider_variable = ''
      c1 = graphicWin['contour_plot']
      c2 = graphicWin['contour_plot2']
      cb = graphicWin['colorbar1']
      cb2 = graphicWin['colorbar2']
      
      counter = 0
      CASE event_UV OF
        'Z': BEGIN
            WIDGET_CONTROL, event.id, GET_VALUE = slider_variable
            z_2 = point_z[2]
            d = point_z[3]
            d2 = point_z[5]
            ctable = *(point_z[4])
            *z_2 = slider_variable
            c1.erase
            
            c1=contour((*d)[*,*, *z_2], RGB_TABLE = ctable, layout = [2, 1, 1], name = 'contour_plot',/FILL, /current) ;c_value = index, xrange = [min(x_centers), max(x_centers)], yrange = [min(y_centers), max(y_centers)], /FILL)
            cb = colorbar(target = c1, orientation = 1)
            c2 = contour((*d2)[*,*, *z_2], RGB_TABLE = ctable, layout = [2, 1, 2], name = 'contour_plot2',/FILL, /current)
            cb2 = colorbar(target = c2, orientation = 1)
            
            counter = 1
          ENDCASE
        ELSE: ; do nothing
      ENDCASE
    END

    'WIDGET_BASE': begin
      ; Handle base resize events. Retrieve our cached padding,
      ; and our new size.
      WIDGET_CONTROL, event.id, GET_UVALUE=pad, TLB_GET_SIZE=newSize
      wDraw = WIDGET_INFO(event.top, FIND_BY_UNAME='DRAW')
      ; Change the draw widget to match the new size, minus padding.
      pad = [*(pad[0]), *(pad[1])]
      xy = newSize - pad
      WIDGET_CONTROL, wDraw, $
        DRAW_XSIZE=xy[0], DRAW_YSIZE=xy[1], $
        SCR_XSIZE=xy[0], SCR_YSIZE=xy[1]
    end

    ELSE: ; do nothing
  ENDCASE
END

function plot_widget_with_slider, dose_presc, filename
;  filename = "C:\Users\Eirik\Dropbox\Universitet\Master\fraction_dose.dat"

  ;nlines = FILE_LINES(filename)
  ;sarr = STRARR(nlines)

  openr, lun, filename, /GET_LUN

  nr_voxels = make_array(3, 1, /ulong, value = 0)
  voxel_size = make_array(3, 1, /double, value = 0)
  corner = make_array(3, 1, /double, value = 0)
  total_voxels = ulong(0)


  readu, lun, nr_voxels
  readu, lun, voxel_size
  readu, lun, corner
  readu, lun, total_voxels

  
  d = make_array(nr_voxels[0], nr_voxels[1], nr_voxels[2], /double, value=0)

  readu, lun, d

  ;x_centers = corner[0] + findgen(nr_voxels[0] + 0.5, start = 0.5, increment = 1) * voxel_size[0]
  ;y_centers = corner[1] + findgen(nr_voxels[1] + 0.5, start = 0.5, increment = 1) * voxel_size[1]
  ;
  ;levels = 10
  ctable = ptr_new(/allocate_heap)
  *ctable = COLORTABLE(33)

  ;index = indgen(130, start = min(d) - 1) * max(d[*,*, ceil(nr_voxels[2]/2.)])/118.

;  free_lun, lun
  
  dose = ptr_new(/ALLOCATE_HEAP)
  dose2 = ptr_new(/ALLOCATE_HEAP)
  *dose = d*34.0/100.0
  *dose2 = dose_presc

  base1 = WIDGET_BASE(/COLUMN, TITLE='Widget Window example', $
    /TLB_SIZE_EVENTS)

  wDraw = WIDGET_WINDOW(base1, UVALUE='draw', UNAME='DRAW')
  
  ; Create the base for the button:
  base2 = WIDGET_BASE(base1, /ROW, /ALIGN_CENTER)

  ; Create the action buttons.
  ;redline = WIDGET_BUTTON(base2, VALUE='Red Line', UVALUE = 'RED')
  ;blueline = WIDGET_BUTTON(base2, VALUE='Blue line', UVALUE='BLUE')
  ;done = WIDGET_BUTTON(base2, VALUE = 'Done', UVALUE = 'DONE')
  z = PTR_NEW(/ALLOCATE_HEAP)
  *z = 110
  slider = widget_slider(base2, value = *z, uvalue = 'Z', maximum = nr_voxels[2], minimum = 0)

  ; Realize the widget (i.e., display it on screen).
  WIDGET_CONTROL, base1, SET_UVALUE = z, /REALIZE
  ; Register the widget with the XMANAGER, leaving the IDL command
  ; line active.
  XMANAGER, 'PLOT_WIDGET_DOC', base1, /NO_BLOCK
  
  ; Cache the padding between the base and the draw
  WIDGET_CONTROL, base1, TLB_GET_SIZE=basesize
  xpad = ptr_new(/ALLOCATE_HEAP)
  ypad = ptr_new(/ALLOCATE_HEAP)
  *xpad = basesize[0] - 640
  *ypad = basesize[1] - 512
  stash = ptrarr(6)
  stash = [xpad, ypad, z, dose, ctable, dose2]
  WIDGET_CONTROL, base1, SET_UVALUE=stash

  ; Retrieve the newly-created Window object.
  WIDGET_CONTROL, wDraw, GET_VALUE = graphicWin

  graphicWin.SELECT
 
  ; Plot #1: In position #1 on the grid defined by LAYOUT
  c1=contour((*dose)[*,*, *z], RGB_TABLE = *ctable, layout = [2, 1, 1], name = 'contour_plot',/FILL, /current) ;c_value = index, xrange = [min(x_centers), max(x_centers)], yrange = [min(y_centers), max(y_centers)], /FILL)
  cb = colorbar(target = c1, orientation = 1, name = 'colorbar1')
  c2 = contour((*dose2)[*,*, *z], RGB_TABLE = *ctable, layout = [2, 1, 2], name = 'contour_plot2',/FILL, /current)
  cb2 = colorbar(target = c2, orientation = 1, name = 'colorbar2')
END