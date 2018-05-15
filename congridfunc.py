import numpy as n
import scipy.interpolate
import scipy.ndimage

def congrid(a, newdims, method='linear', centre=False, minusone=False):
    '''Arbitrary resampling of source array to new dimension sizes.
    Currently only supports maintaining the same number of dimensions.
    To use 1-D arrays, first promote them to shape (x,1).
    
    Uses the same parameters and creates the same co-ordinate lookup points
    as IDL''s congrid routine, which apparently originally came from a VAX/VMS
    routine of the same name.

    method:
    neighbour - closest value from original data
    nearest and linear - uses n x 1-D interpolations using
                         scipy.interpolate.interp1d
    (see Numerical Recipes for validity of use of n 1-D interpolations)
    spline - uses ndimage.map_coordinates

    centre:
    True - interpolation points are at the centres of the bins
    False - points are at the front edge of the bin

    minusone:
    For example- inarray.shape = (i,j) & new dimensions = (x,y)
    False - inarray is resampled by factors of (i/x) * (j/y)
    True - inarray is resampled by(i-1)/(x-1) * (j-1)/(y-1)
    This prevents extrapolation one element beyond bounds of input array.
    '''
    if not a.dtype in [n.float64, n.float32]:
        a = n.cast[float](a)

    m1 = n.cast[int](minusone)
    ofs = n.cast[int](centre) * 0.5
    old = n.array( a.shape )
    ndims = len( a.shape )
    if len( newdims ) != ndims:
        print "[congrid] dimensions error. " \
              "This routine currently only support " \
              "rebinning to the same number of dimensions."
        return None
    newdims = n.asarray( newdims, dtype=float )
    dimlist = []

    if method == 'neighbour':
        for i in range( ndims ):
            base = n.indices(newdims)[i]
            dimlist.append( (old[i] - m1) / (newdims[i] - m1) \
                            * (base + ofs) - ofs )
        cd = n.array( dimlist ).round().astype(int)
        newa = a[list( cd )]
        return newa

    elif method in ['nearest','linear']:
        # calculate new dims
        for i in range( ndims ):
            base = n.arange( newdims[i] )
            dimlist.append( (old[i] - m1) / (newdims[i] - m1) \
                            * (base + ofs) - ofs )
        # specify old dims
        olddims = [n.arange(i, dtype = n.float) for i in list( a.shape )]

        # first interpolation - for ndims = any
        mint = scipy.interpolate.interp1d( olddims[-1], a, kind=method )
        newa = mint( dimlist[-1] )

        trorder = [ndims - 1] + range( ndims - 1 )
        for i in range( ndims - 2, -1, -1 ):
            newa = newa.transpose( trorder )

            mint = scipy.interpolate.interp1d( olddims[i], newa, kind=method )
            newa = mint( dimlist[i] )

        if ndims > 1:
            # need one more transpose to return to original dimensions
            newa = newa.transpose( trorder )

        return newa
    elif method in ['spline']:
        oslices = [ slice(0,j) for j in old ]
        oldcoords = n.ogrid[oslices]
        nslices = [ slice(0,j) for j in list(newdims) ]
        newcoords = n.mgrid[nslices]

        newcoords_dims = range(n.rank(newcoords))
        #make first index last
        newcoords_dims.append(newcoords_dims.pop(0))
        newcoords_tr = newcoords.transpose(newcoords_dims)
        # makes a view that affects newcoords

        newcoords_tr += ofs

        deltas = (n.asarray(old) - m1) / (newdims - m1)
        newcoords_tr *= deltas

        newcoords_tr -= ofs

        newa = scipy.ndimage.map_coordinates(a, newcoords)
        return newa
    else:
        print "Congrid error: Unrecognized interpolation type.\n", \
              "Currently only \'neighbour\', \'nearest\',\'linear\',", \
              "and \'spline\' are supported."
        return None

def conts(filename):
    f = n.loadtxt(filename)
    nStructs = len(f[0])/3.0
    Structs = []
    for i in range(0, int(nStructs)):
        b = f[:, i*3:i*3+3]
        check = len(b)
        for j in range(0, len(b)):
            #print b[j]
            if sum(b[j]) == 0 and min(b[j]) == max(b[j]):
                check = j
                break
                

        Structs.append(b[0:check])
    #print Structs
    return Structs

def conts_sorts(filename):
    f = n.loadtxt(filename)
    nStructs = len(f[0])/3.0
    Structs = []
    for i in range(0, int(nStructs)):
        b = f[:, i*3:i*3+3]
        check = len(b)
        # for j in range(0, len(b)):
        #     print b[j]
        #     if sum(b[j]) == 0 and min(b[j]) == max(b[j]):
        #         check = j
        #         break
                

        Structs.append(b[0:check])
    return Structs

def punkt_indekses(filename):
    f = n.loadtxt(filename)
    nStructs = len(f[0])
    Structs = []
    for i in range(0, nStructs):
        b = f[:, i]
        #print b
        check = len(b) + 1
        for j in range(0, len(b)-2):
            #print b[j]
            if b[j] == 0 and b[j+1] == 0 and b[j+2] == 0:
                check = j
                break
        Structs.append(b[0:check])
    return Structs

def pet_matrix_reader(filename, xdim, ydim, zdim):
    f = open(filename)

    return_matrix = n.zeros((round(abs(zdim)), abs(ydim), abs(xdim)))

    list1 = []
    counter = 0
    xcounter = 0
    x2counter = 0
    x3counter = 0
    ycounter = 0
    zcounter = 0

    list4 = []
    for line in f:
        list2 = []
        a = line.split(' ')
        list3 = []
        for i in range(0, len(a)):
            if a[i] == a[-1]:
                a[i] = a[i][:-2]
            if a[i] != '':
                list3.append(i)
        b = []
        for i in list3:
            b.append(a[i])
        a = b
        #print a
        #print counter
        counter += 1
        if len(a) < 1 and len(a)>0:
            list2.append(a[0])
            list1.append(list2)
            list2 = []
        else:
            for i in a:
                list2.append(i)
        xcounter += len(list2)

        for i in list2:
            list4.append(i)
        if xcounter == xdim:
            xcounter = 0

            return_matrix[zcounter][ycounter] = list4

            list4 = []

            ycounter += 1
            if ycounter == ydim:
                ycounter = 0
                zcounter += 1

    return return_matrix


def rebin(a, *args):
    shape = a.shape
    lenShape = len(shape)
    factor = n.asarray(shape)/n.asarray(args)
    evList = ['a.reshape('] + \
             ['args[%d],factor[%d],'%(i,i) for i in range(lenShape)] + \
             [')'] + ['.mean(%d)'%(i+1) for i in range(lenShape)]
    print 'Hello'
    print ''.join(evList)
    return eval(''.join(evList))