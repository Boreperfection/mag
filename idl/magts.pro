;PROCEDURE MAGTS takes data from l-files generated by MAG
;and creates time series plots and statistics.
;This version reads an l-file consisting of 17 time series,
;the first record being dimensionless time. Energies and
;rms magnetic field and velocity are scaled as in MAG. tilt is dipole
;vector colatitude or geomagnetic; pole longitude is dipole vector longitude
;the time series are interpolated onto a regular interval 

;SET UP X-WINDOW FOR COLOR DISPLAY
SET_PLOT,'X'
;SET DEVICE FOR COLOR on Mac
DEVICE, RETAIN=2, DECOMPOSED=0

;CONSTANTS
pi=3.1415926

;ARRAY DIMENSIONS 
bigarr = FLTARR(17,32500)
arr    = FLTARR(17)

;SCALE FACTORS (default)
tscale=1.0
smsize=1.0

!P.MULTI=0
!P.CHARSIZE=1
!P.THICK=1
!X.THICK=1
!Y.THICK=1

;READ TIMESERIES L-FILE (17 records)
fname  = ' '		;filename of timeseries data
PRINT,'  '
PRINT,'Enter l-file name:' 
READ, fname

;READ TIMESERIES DATA FROM l-file FOR n TIMESTEPS
nstop =32000   ;maximum integer constraint
OPENR, 1, fname
n = 0
WHILE (NOT EOF(1)) DO BEGIN
	n = n + 1
	READF, 1, arr
	bigarr(*, n-1) = arr
	if (n gt nstop) then goto, LABEL31
ENDWHILE
LABEL31: PRINT,'CLOSING ' + fname
CLOSE, 1

PRINT, ' '
PRINT, 'NUMBER OF STEPS=',n
PRINT, ' '

;DEFINE TIME SERIES ARRAYS
tseries = FLTARR(17, n)
tseries = bigarr(*, 0:n-1)

time       = tseries(0,*)	
ke	   = tseries(1,*)	
kepol      = tseries(2,*)	
me         = tseries(3,*)	
mepol      = tseries(4,*)	
keaxtor    = tseries(5,*)
keaxpol    = tseries(6,*)
meaxipol   = tseries(7,*)
meaxitor   = tseries(8,*)
nutop	   = tseries(9,*)
nubot	   = tseries(10,*)
bmean	   = tseries(11,*)
dipole	   = tseries(12,*)
dipaxi	   = tseries(13,*)
tilt	   = tseries(14,*)
diplong	   = tseries(15,*)
vmean	   = tseries(16,*)

;UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
;INTERPOLATE TO UNIFORM SERIES
dtime=time(n-1)-time(0)
;create uniform time series
timeu=time(0)+(dtime*findgen(n)/n)
;create new y-data
resu=interpol(ke,time,timeu) & ke=resu
resu=interpol(kepol,time,timeu) & kepol=resu
resu=interpol(me,time,timeu) & me=resu
resu=interpol(mepol,time,timeu) & mepol=resu
resu=interpol(keaxtor,time,timeu) & keaxtor=resu
resu=interpol(meaxipol,time,timeu) & meaxipol=resu
resu=interpol(meaxitor,time,timeu) & meaxitor=resu
resu=interpol(nutop,time,timeu) & nutop=resu
resu=interpol(nubot,time,timeu) & nubot=resu
resu=interpol(bmean,time,timeu) & bmean=resu
resu=interpol(vmean,time,timeu) & vmean=resu
resu=interpol(dipole,time,timeu) & dipole=resu
resu=interpol(dipaxi,time,timeu) & dipaxi=resu
resu=interpol(tilt,time,timeu) & tilt=resu
resu=interpol(diplong,time,timeu) & diplong=resu

;replace old ts
res=resu & time=timeu

;create geomagnetic-type dipole functions
polarity=fltarr(n) & glong=fltarr(n)
for i=0, n-1 do begin
   if (tilt(i)  lt  90 ) then polarity(i)=-1  ;Reverse Polarity
   if (tilt(i)  ge  90 ) then polarity(i)=+1  ;Normal Polarity
   if (diplong(i) lt 0) then glong(i)=diplong(i) + 180 ;Geomag pole longitude
   if (diplong(i) ge 0) then glong(i)=diplong(i) - 180 ;Geomag pole longitude	 	
endfor

;create vector axial dipole
   dipaxi=-polarity*dipaxi 

;UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU


;SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
;COMPUTE STATISTICS
;find extreme values
kemax=max(ke) & kemin=min(ke)
memax=max(me) & memin=min(me)
mepmax=max(mepol) & mepmin=min(mepol)
apmax=max(meaxipol) & apmin=min(meaxipol)
atmax=max(meaxitor) & atmin=min(meaxitor)
dmax=max(dipole) & dmin=min(dipole)
admax=max(dipaxi) & admin=min(dipaxi)
nutmax=max(nutop) & nutmin=min(nutop)
nubmax=max(nubot) & nubmin=min(nubot)
vmax=max(vmean) & vmin=min(vmean)
bmax=max(bmean) & bmin=min(bmean)
tilmax=max(tilt) & tilmin=min(tilt)
lonmax=max(diplong) & lonmin=min(diplong)

PRINT, ' '
PRINT, 'Parameter   Average    Stnd Dev    Max     Min'
res1=moment(ke,sdev=sd1) & print, 'KE:         ' ,res1(0),sd1,kemax,kemin
res2=moment(kepol,sdev=sd2) & print, 'KE(pol):    ',res2(0),sd2  
res3=moment(me,sdev=sd3) & print, 'ME:         ', res3(0),sd3,memax,memin 
res4=moment(mepol,sdev=sd4) & print, 'ME(pol):    ', res4(0),sd4      
res5=moment(keaxtor,sdev=sd5) & print, 'KE(axitor): ', res5(0),sd5   
res6=moment(keaxpol,sdev=sd6) & print, 'KE(axipol): ', res6(0),sd6  
res8=moment(meaxipol,sdev=sd8) & print, 'ME(axipol): ', res8(0),sd8,apmax,apmin   
res9=moment(meaxitor,sdev=sd9) & print, 'ME(axitor): ', res9(0),sd9,atmax,atmin   
res10=moment(nutop,sdev=sd10) & print, 'Nu(top):    ', res10(0),sd10,nutmax,nutmin	   
res11=moment(nubot,sdev=sd11) & print, 'Nu(bot):    ', res11(0),sd11,nubmax,nubmin	  
res12=moment(bmean,sdev=sd12) & print, 'B(rmsvol):     ', res12(0),sd12,bmax,bmin	   
res13=moment(dipole,sdev=sd13) & print, 'B(dip):     ', res13(0),sd13,dmax,dmin	   
res14=moment(dipaxi,sdev=sd14) & print, 'B(axi):     ', res14(0),sd14,admax,admin	   
res15=moment(tilt,sdev=sd15) & print, 'Tilt:        ', res15(0),sd15,tilmax,tilmin
res16=moment(diplong,sdev=sd16) & print, 'Lon(ave):   ', res16(0),sd16,lonmax,lonmin		   
res17=moment(vmean,sdev=sd17) & print, 'V(rmsvol):     ', res17(0),sd17,vmax,vmin	

;calculate me-toroidal
  metor=me-mepol


PRINT, ' '
PRINT,'Correlations'
PRINT, 'KE vs ME:          ', correlate(ke,me)
PRINT, 'KE vs Nu(top):     ', correlate(ke,nutop)
PRINT, 'KE vs Nu(bot):     ', correlate(ke,nubot)
PRINT, 'ME vs Nu(top):     ', correlate(me,nutop)
PRINT, 'ME vs Nu(bot):     ', correlate(me,nubot)
PRINT, 'dipole vs Nu(top): ', correlate(dipole,nutop)
PRINT, 'dipole vs Nu(bot): ', correlate(dipole,nubot)
PRINT, 'dipole vs vmean:   ', correlate(dipole,vmean)
PRINT, 'dipole vs tilt:    ', correlate(dipole,tilt)
;SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS 


;#######################################################################
; Here begins plotting material:
;#######################################################################
; Define window size and plotting frames
  XDIM=18.0
  YDIM=24.0
  IGIFPS=0

  LCOLOR = 0 
  LOADCT, LCOLOR 		;loads B&W color table

;** WINDOW SIZE IN PIXELS (ALSO SIZE OF GIF FILE)
  XWINDOW=500
  YWINDOW=575
  SCWINDOW=1.25
  XWIND=XWINDOW*SCWINDOW
  YWIND=YWINDOW*SCWINDOW
  CSZ=1.00 & CSB=1.50 & CSS=0.720       ; CHARACTER SIZES
  SZF=1.2*SCWINDOW                      ; MAKES JPG AND PS CHARACTERS SAME SIZE
 
;*** Normalized coordinates for 2x2 plots
  XY1=[ 1.5/XDIM,14./YDIM, 8.5/XDIM,22./YDIM] & XT1=5./XDIM & YT1=22.2/YDIM
	XP1 = 6.5/XDIM  & YP1 = 20.5/YDIM
  XY2=[ 10.5/XDIM,14./YDIM,17.5/XDIM,22./YDIM] & XT2=14./XDIM & YT2=22.2/YDIM
	XP2 = 15.5/XDIM  & YP2 = 20.5/YDIM
  XY3=[ 1.5/XDIM, 3.5/YDIM, 8.5/XDIM,11.5/YDIM] & XT3=5./XDIM & YT3=11.7/YDIM
  XY4=[ 10.5/XDIM, 3.5/YDIM,17.5/XDIM,11.5/YDIM] & XT4=14./XDIM & YT4=11.7/YDIM
	XCT=8/XDIM & YCT=16/YDIM

;*************************************************************************
;**************  THE PLOTTING MENU STARTS HERE **************************
;*************************************************************************
LABEL0: IF IGIFPS EQ 1 THEN PRINT,"USE --GOTO, LABELOUT-- STATEMENT HERE."
        PRINT,'  ' & PRINT,'  ' & PRINT,'  ' & PRINT,'  ' & PRINT,'  ' 
        PRINT, "ENTER OPTION: "
        PRINT, "EXIT PROCEDURE = -1"
	PRINT, "ENERGIES I = 1;  ENERGIES II = 2"
	PRINT, "FIELD PLOTS = 3; STATISTICS = 4"
	PRINT, "RESCALE = 5; SPECTRA = 6"
	PRINT, "POLE PLOTS = 7; ENERGIES SCATTER = 8"
        PRINT, "CHANGE WINDOW SIZE = 11"
	PRINT, "TRIM SERIES = 12"
        PRINT, "MAKE POSTSCRIPT = 21"

        READ,IOPTION

        IF (IOPTION GE 1 AND IOPTION LE 8) THEN BEGIN
           WINDOW,0,xsize=XWIND,ysize=YWIND,title='GRAPHIC WINDOW'
           !P.CHARTHICK=1.5
           !P.FONT=0
        ENDIF

        CASE IOPTION OF
       -1:    GOTO, LABEL98
        0:    GOTO, LABEL0
        1:    GOTO, LABEL1
        2:    GOTO, LABEL2
        3:    GOTO, LABEL3
 	4:    GOTO, LABEL4
	5:    GOTO, LABEL5
	6:    GOTO, LABEL6
	7:    GOTO, LABEL7
	8:    GOTO, LABEL8
        11:   GOTO, LABEL11
        12:   GOTO, LABEL12 
        21:   GOTO, LABEL21
        22:   GOTO, LABEL0             
        ELSE: GOTO, LABEL0
        ENDCASE
 
;####################################################################

;11111111111111111111111111111111111111111111111111111111111111111111111
LABEL1: & IPAGE=1
ERASE
!P.MULTI = [0,1,4,0]
TL='   Scale='+string(tscale)+' Smooth='+string(smsize)

PLOT, time, ke, LINESTYLE = 0, TITLE='KE', YRANGE=[kemin,kemax],xstyle=1
OPLOT, time, replicate(res1(0),n),LINESTYLE = 2
OPLOT, time, replicate(res1(0)-sd1,n),LINESTYLE = 1
OPLOT, time, replicate(res1(0)+sd1,n),LINESTYLE = 1

PLOT, time, me, LINESTYLE = 0, TITLE='ME',YRANGE=[memin,memax],xstyle=1
OPLOT, time, replicate(res3(0),n),LINESTYLE = 2
OPLOT, time, replicate(res3(0)-sd3,n),LINESTYLE = 1
OPLOT, time, replicate(res3(0)+sd3,n),LINESTYLE = 1

PLOT, time, nutop, LINESTYLE = 0, TITLE='Nu(top)',$
	YRANGE=[nutmin,nutmax],xstyle=1
OPLOT, time, replicate(res10(0),n),LINESTYLE = 2
OPLOT, time, replicate(res10(0)-sd10,n),LINESTYLE = 1
OPLOT, time, replicate(res10(0)+sd10,n),LINESTYLE = 1

PLOT, time, nubot, LINESTYLE = 0, TITLE='Nu(bot)', YRANGE=[nubmin,nubmax],$
	XTITLE='Time'+TL,xstyle=1
OPLOT, time, replicate(res11(0),n),LINESTYLE = 2
OPLOT, time, replicate(res11(0)-sd11,n),LINESTYLE = 1
OPLOT, time, replicate(res11(0)+sd11,n),LINESTYLE = 1


GOTO, LABEL99
;111111111111111111111111111111111111111111111111111111111111111111111111


;222222222222222222222222222222222222222222222222222222222222222222222222
LABEL2: IPAGE=2
ERASE
!P.MULTI = [0,1,4,0]
TL='   Scale='+string(tscale)+' Smooth='+string(smsize)

PLOT, time, mepol, LINESTYLE = 0, TITLE='ME(pol)',$
	YRANGE=[mepmin,mepmax],xstyle=1
OPLOT, time, replicate(res4(0),n),LINESTYLE = 2
OPLOT, time, replicate(res4(0)-sd4,n),LINESTYLE = 1
OPLOT, time, replicate(res4(0)+sd4,n),LINESTYLE = 1

PLOT, time, meaxipol, LINESTYLE = 0, TITLE='MEaxi(pol)',$
 	YRANGE=[apmin,apmax],xstyle=1
OPLOT, time, replicate(res8(0),n),LINESTYLE = 2
OPLOT, time, replicate(res8(0)-sd8,n),LINESTYLE = 1
OPLOT, time, replicate(res8(0)+sd8,n),LINESTYLE = 1

PLOT, time, meaxitor, LINESTYLE = 0, TITLE='MEaxi(tor)',$
	YRANGE=[atmin,atmax],xstyle=1
OPLOT, time, replicate(res9(0),n),LINESTYLE = 2
OPLOT, time, replicate(res9(0)-sd9,n),LINESTYLE = 1
OPLOT, time, replicate(res9(0)+sd9,n),LINESTYLE = 1

PLOT, time, dipaxi, LINESTYLE = 0, TITLE='Axial Dipole (rms,cmb)',$
	YRANGE=[admin,admax],xstyle=1
OPLOT, time, replicate(res14(0),n),LINESTYLE = 2
OPLOT, time, replicate(0,n),LINESTYLE = 0
OPLOT, time, replicate(res14(0)-sd14,n),LINESTYLE = 1
OPLOT, time, replicate(res14(0)+sd14,n),LINESTYLE = 1

GOTO, LABEL99
;22222222222222222222222222222222222222222222222222222222222222222222222


;33333333333333333333333333333333333333333333333333333333333333333333333
LABEL3: IPAGE=3

tiltype=0
ptilt=tilt
PRINT,' '
PRINT,'SELECT TILT TYPE (VECTOR=0, GEOMAGNETIC=1):'
READ, tiltype

;assign tilt type
if (tiltype ne 1) then begin
	tiltitle='Vector Tilt'
	ptilt=tilt
endif
if (tiltype eq 1) then begin
	tiltitle='Geomagnetic Tilt'
	ptilt=180-tilt
endif

pres=moment(ptilt,sdev=sdp) 
ptilmin=min(ptilt) & ptilmax=max(ptilt)

ERASE
!P.MULTI = [0,1,4,0]
TL='  Scale='+string(tscale)+' Smooth='+string(smsize)

PLOT, time, vmean, LINESTYLE = 0, TITLE='V (rms,vol)',$
	YRANGE=[vmin,vmax],xstyle=1
OPLOT, time, replicate(res17(0),n),LINESTYLE = 2
OPLOT, time, replicate(res17(0)-sd17,n),LINESTYLE = 1
OPLOT, time, replicate(res17(0)+sd17,n),LINESTYLE = 1

PLOT, time, bmean, LINESTYLE = 0, TITLE='B (rms,vol)',$
	YRANGE=[bmin,bmax],xstyle=1
OPLOT, time, replicate(res12(0),n),LINESTYLE = 2
OPLOT, time, replicate(res12(0)-sd12,n),LINESTYLE = 1
OPLOT, time, replicate(res12(0)+sd12,n),LINESTYLE = 1

PLOT, time, dipole, LINESTYLE = 0, TITLE='Dipole (rms,cmb) ',$
	YRANGE=[dmin,dmax],xstyle=1
OPLOT, time, replicate(res13(0),n),LINESTYLE = 2
OPLOT, time, replicate(res13(0)-sd13,n),LINESTYLE = 1
OPLOT, time, replicate(res13(0)+sd13,n),LINESTYLE = 1

;plot tilt
if ptilmax lt 90 then begin  ;reduced scale
PLOT, time, ptilt, LINESTYLE = 0, TITLE=tiltitle,$
	YRANGE=[ptilmin,ptilmax],XTITLE='Time'+TL,xstyle=1
endif
if ptilmax ge 90 then begin   ;full scale
PLOT, time, ptilt, LINESTYLE = 0, TITLE=tiltitle,$
	YRANGE=[0,180],XTITLE='Time'+TL,xstyle=1,ystyle=1,ytickinterval=30
endif
OPLOT, time, replicate(pres(0),n),LINESTYLE = 2
OPLOT, time, replicate(90,n),LINESTYLE = 0

GOTO, LABEL99
;33333333333333333333333333333333333333333333333333333333333333333333333


;4444444444444444444444444444444444444444444444444444444444444444444
;COMPUTE STATISTICS
LABEL4: IPAGE=4

kemax=max(ke) & kemin=min(ke)
memax=max(me) & memin=min(me)
mepmax=max(mepol) & mepmin=min(mepol)
apmax=max(meaxipol) & apmin=min(meaxipol)
atmax=max(meaxitor) & atmin=min(meaxitor)
dmax=max(dipole) & dmin=min(dipole)
admax=max(dipaxi) & admin=min(dipaxi)
nutmax=max(nutop) & nutmin=min(nutop)
nubmax=max(nubot) & nubmin=min(nubot)
vmax=max(vmean) & vmin=min(vmean)
bmax=max(bmean) & bmin=min(bmean)
tilmax=max(tilt) & tilmin=min(tilt)
lonmax=max(diplong) & lonmin=min(diplong)

PRINT, ' '
PRINT, 'Parameter   Average    Stnd Dev    Max     Min'
res1=moment(ke,sdev=sd1) & print, 'KE:         ' ,res1(0),sd1,kemax,kemin
res2=moment(kepol,sdev=sd2) & print, 'KE(pol):    ',res2(0),sd2  
res3=moment(me,sdev=sd3) & print, 'ME:         ', res3(0),sd3,memax,memin 
res4=moment(mepol,sdev=sd4) & print, 'ME(pol):    ', res4(0),sd4      
res5=moment(keaxtor,sdev=sd5) & print, 'KE(axitor): ', res5(0),sd5   
res6=moment(keaxpol,sdev=sd6) & print, 'KE(axipol): ', res6(0),sd6   
res8=moment(meaxipol,sdev=sd8) & print, 'ME(axipol): ', res8(0),sd8,apmax,apmin   
res9=moment(meaxitor,sdev=sd9) & print, 'ME(axitor): ', res9(0),sd9,atmax,atmin   
res10=moment(nutop,sdev=sd10) & print, 'Nu(top):    ', res10(0),sd10,nutmax,nutmin	   
res11=moment(nubot,sdev=sd11) & print, 'Nu(bot):    ', res11(0),sd11,nubmax,nubmin	  
res12=moment(bmean,sdev=sd12) & print, 'B(rmsvol):     ', res12(0),sd12,bmax,bmin	   
res13=moment(dipole,sdev=sd13) & print, 'B(dip):     ', res13(0),sd13,dmax,dmin	   
res14=moment(dipaxi,sdev=sd14) & print, 'B(axi):     ', res14(0),sd14,admax,admin
res15=moment(tilt,sdev=sd15) & print, 'Tilt:         ', res15(0),sd15,tilmax,tilmin
res16=moment(diplong,sdev=sd16) & print, 'Lon(ave):    ', res16(0),sd16,lonmax,lonmin		   
res17=moment(vmean,sdev=sd17) & print, 'V(rmsvol):     ', res17(0),sd17,vmax,vmin	

;calculate me-toroidal
metor=me-mepol

	   
PRINT, ' '
PRINT,'Correlations'
PRINT, 'KE vs ME:          ', correlate(ke,me)
PRINT, 'KE vs Nu(top):     ', correlate(ke,nutop)
PRINT, 'KE vs Nu(bot):     ', correlate(ke,nubot)
PRINT, 'ME vs Nu(top):     ', correlate(me,nutop)
PRINT, 'ME vs Nu(bot):     ', correlate(me,nubot)
PRINT, 'dipole vs Nu(top): ', correlate(dipole,nutop)
PRINT, 'dipole vs Nu(bot): ', correlate(dipole,nubot)
PRINT, 'dipole vs v(rmsvol):   ', correlate(dipole,vmean)
PRINT, 'b(rmsvol) vs v(rmsvol): ', correlate(bmean,vmean)
PRINT, 'dipole vs tilt:    ', correlate(dipole,tilt)
PRINT, 'dipole vs MEaxitor:', correlate(dipole,meaxitor)
PRINT, 'dipole vs tilt:   ', correlate(dipole,tilt)
PRINT, 'ME(axpol)vsME(axtor):',correlate(meaxipol,meaxitor)
PRINT, 'ME vs ME(pol):     ',correlate(mepol,me)
PRINT, 'ME vs ME(tor):     ',correlate(metor,me)


;POLE STATISTICS
rad=pi*abs(cos(tilt))/180.
phi=pi*diplong/180.
xpole=rad*cos(phi) & ypole=rad*sin(phi)
resx=moment(xpole,sdev=sdx)  
resy=moment(ypole,sdev=sdy)
aver=sqrt(resx(0)^2 + resy(0)^2)
aveincl=180*atan(aver,1)/pi
avelong=180*atan(resy(0),resx(0))/pi
rmstilt=res15(0)  
PRINT, ' '
PRINT, 'POLE STASTICS'
PRINT, '       Xave         Xsd          Yave          Ysd          Rave'
PRINT, resx(0),sdx,resy(0),sdy,aver
PRINT,'Dipole Long(ave) Tilt(rms,deg)  Incl(ave,deg)'
PRINT, avelong,rmstilt,aveincl
PRINT,' '
	   
GOTO, LABEL99 
;4444444444444444444444444444444444444444444444444444444444444444444444


;5555555555555555555555555555555555555555555555555555555555555555555
LABEL5: IPAGE=5
PRINT, 'CHANGE TIME AND AMPLITUDE SCALES AND SMOOTH'
PRINT, ' '
PRINT, 'TIMESCALE FACTOR=' , tscale
PRINT, 'ENTER TIME SCALE FACTOR (def=1):' & read,tscale
	time=tscale*time
PRINT, ' '
	tzro=time(0)
PRINT, 'SHIFT INITIAL TIME TO 0? (yes=1):' & read,tshift
       if tshift eq 1 then time=time-tzro

bsc=1 & vsc=1
PRINT, ' '
PRINT, 'ENTER MAG FIELD, VELOCITY, NUSSELT SCALE FACTORS (def=1):'
READ, bsc, vsc, nsc

smsize=1 & filt=1
PRINT, 'ENTER SMOOTHING FACTOR (odd; def=1):' 
READ,smsize
;SCALE AND SMOOTH
kes=vsc*vsc*smooth(ke,smsize,/edge_truncate)
kepols=vsc*vsc*smooth(kepol,smsize,/edge_truncate)
mes=bsc*bsc*smooth(me,smsize,/edge_truncate)
mepols=bsc*bsc*smooth(mepol,smsize,/edge_truncate)
keaxtors=vsc*vsc*smooth(keaxtor,smsize,/edge_truncate)
keaxpols=vsc*vsc*smooth(keaxpol,smsize,/edge_truncate)
meaxipols=bsc*bsc*smooth(meaxipol,smsize,/edge_truncate)
meaxitors=bsc*bsc*smooth(meaxitor,smsize,/edge_truncate)
metors=bsc*bsc*smooth(metor,smsize,/edge_truncate)
nutops=nsc*smooth(nutop,smsize,/edge_truncate)
nubots=nsc*smooth(nubot,smsize,/edge_truncate)
bmeans=bsc*smooth(bmean,smsize,/edge_truncate)
dipoles=bsc*smooth(dipole,smsize,/edge_truncate)
dipaxis=bsc*smooth(dipaxi,smsize,/edge_truncate)
tilts=smooth(tilt,smsize,/edge_truncate)
vmeans=vsc*smooth(vmean,smsize,/edge_truncate)
PRINT, 'ENTER FILTER: LOW PASS=1; HIGH PASS=-1:'
READ,filt

if filt eq 1 then begin
ke=kes
kepol=kepols
me=mes
mepol=mepols
keaxtor=keaxtors
keaxpol=keaxpols
meaxipol=meaxipols
meaxitor=meaxitors
metor=metors
nutop=nutops
nubot=nubots
bmean=bmeans
dipole=dipoles
dipaxi=dipaxis
tilt=tilts
vmean=vmeans
endif

if filt eq -1 then begin
ke=ke-kes
kepol=kepol-kepols
me=me-mes
mepol=mepol-mepols
keaxtor=keaxtor-keaxtors
keaxpol=keaxpol-keaxpols
meaxipol=meaxipol-meaxipols
meaxitor=meaxitor-meaxitors
metor=metor-metors
nutop=nutop-nutops
nubot=nubot-nubots
bmean=bmean-bmeans
dipole=dipole-dipoles
dipaxi=dipaxi-dipaxis
tilt=tilt-tilts
vmean=vmean-vmeans
endif


PRINT, ' '
PRINT,'NEW TIMESCALE FACTOR=',tscale
PRINT,'NEW SMOOTHING FACTOR=',smsize*filt

GOTO, LABEL4       ;re-do statistics
;5555555555555555555555555555555555555555555555555555555555555555555

;666666666666666666666666666666666666666666666666666666666666666666
;SPECTRA
LABEL6: IPAGE=6
PRINT, 'Nyquist frequency = ', n/2
nf=(n/2)-1
PRINT, ' '
PRINT, 'Enter number of frequencies to plot:'
Read, nf

powsm=1
PRINT, 'Enter spectral smoothing (odd,def=1):'
Read, powsm

;REMOVE MEANS
bzm=bmean-res12(0)
dzm=dipole-res13(0)
azm=dipaxi-res14(0)
vzm=vmean-res17(0)
nzm=(nutop-res10(0)+nubot-res11(0))/2

;DEFAULT POWER SPECTRA FREQUENCY SCALINGS
fyes=0
freq=findgen(n) 
pscale=1 
fmax=freq(nf-1)
fmin=1
stitle='Frequency, n'

PRINT, 'Scale frequencies by record length? (yes=1):'
READ, fyes
if fyes eq 1 then begin
	dtime=time(n-1)-time(0)
	freq=freq/dtime
	fmax=freq(nf)
	pscale=dtime
	ftitle='Frequency, f'
  PRINT,'Enter minimum frequency (ie, 0.1):'
  READ, fread
  fmin=fread		
endif

axif=1
PRINT, 'ENTER OPTION: Nu=0, CMB Axial Dipole=1:'
read, axif

hanif=0
PRINT, 'ENTER FILTER CHOICE: Square=0, Hannning=1:'
read, hanif

;SQUARE FILTER DEFAULT
	hn=replicate(1,n)
;HANNING FILTER OPTION
	if hanif eq 1 then hn=hanning(n)

;COMPUTE POWER SPECTRA
	bp=pscale*abs(fft(hn*bzm,-1))^2
	dp=pscale*abs(fft(hn*dzm,-1))^2
	ap=pscale*abs(fft(hn*azm,-1))^2
	vp=pscale*abs(fft(hn*vzm,-1))^2
	np=pscale*abs(fft(hn*nzm,-1))^2
;SMOOTH POWER SPECTRA
	bp=smooth(bp,powsm,/edge_truncate)
	dp=smooth(dp,powsm,/edge_truncate)
	ap=smooth(ap,powsm,/edge_truncate)
	vp=smooth(vp,powsm,/edge_truncate)
	np=smooth(np,powsm,/edge_truncate)
;VARIANCE PRESERVATION: integrate power spectra
	df=(fmax-fmin)/(nf-1)
;TRAPAZOIDAL RULE 
	bpvar=total(bp[0:nf]*df)
	dpvar=total(dp[0:nf]*df)
	apvar=total(ap[0:nf]*df)
	vpvar=total(vp[0:nf]*df)
	npvar=total(np[0:nf]*df)
;FORM VARIANCE PRESERVING FACTORS
	bpf=res12(1)/(2*bpvar)
	vpf=res17(1)/(2*vpvar)
	dpf=res13(1)/(2*dpvar)
	apf=res14(1)/(2*apvar)
	npf=1   ;nominal
;RESCALE SPECTRA - VARIANCE CONSERVED AFTER FILTER & SMOOTH
	bp=bpf*bp
	vp=vpf*vp
	dp=dpf*dp
	ap=apf*ap
	np=npf*np
;compare with time-domain variances
;PRINT, ' '
;PRINT, ' VARIANCE COMPARISON'
;PRINT, 'VARIABLE    VARIANCE    STDEV^2    SPECTRAL VARIANCE'  
;PRINT, 'Brms',res12(1),sd12^2,2*bpvar
;PRINT, 'Vrms',res17(1),sd17^2,2*vpvar
;PRINT, 'Nurms*',(res11(1)+res10(1))/4,(sd11^2 + sd10^2)/4,2*npvar
;PRINT, 'DIPrms',res13(1),sd13^2,2*dpvar
;PRINT, 'AXdip',res14(1),sd14^2,2*apvar
;PRINT, ' '
;PRINT, '* Nurms combines Nu(top) and Nu(bot)
;PRINT, 'SPECTRUM PLOTS CONSERVE VARIANCE WITH f<f_Nyquist' 
;PRINT, ''
;END OF VARIANCE CHECK


;PLOT SPECTRA - NOTE 2-FACTORS TO CONSERVE VARIANCE f<f_Nyquist'
!P.MULTI = [0,2,2,0]
;!P.POSITION = XY1
plot, /ylog,/xlog,freq,2*bp,title='RMS FIELD',ytitle='Power',$
	xtitle=ftitle,xrange=[fmin,fmax]

;!P.POSITION = XY2
plot, /ylog,/xlog,freq,2*dp,title='RMS CMB DIPOLE',ytitle='Power',$
	xtitle=ftitle,xrange=[fmin,fmax]

;!P.POSITION = XY3
plot, /ylog,/xlog,freq,2*vp,title='RMS VELOCITY',ytitle='Power',$
	xtitle=ftitle,xrange=[fmin,fmax]

;!P.POSITION = XY4
if axif eq 1 then begin
plot, /ylog,/xlog,freq,2*ap,title='AXIAL CMB DIPOLE',$
	ytitle='Power',xtitle=ftitle,xrange=[fmin,fmax]
endif

if axif eq 0 then begin
plot, /ylog,/xlog,freq,2*np,title='AVE NU',ytitle='Power',$
	xtitle=ftitle,xrange=[fmin,fmax]
oplot,freq,2*nph,linestyle=2
endif


GOTO, LABEL99
;666666666666666666666666666666666666666666666666666666666666666666


;77777777777777777777777777777777777777777777777777777777777777777
LABEL7: IPAGE=7
!P.MULTI = [0,2,3,0]

LOADCT, 39 		;loads color table 39

tiltype=0
ptilt=tilt
longtitle='Vector Longitude'
PRINT,' '
PRINT,'SELECT TILT TYPE (VECTOR=0, GEOMAGNETIC=1):'
READ, tiltype
;apply tilt type to poles
if (tiltype ne 1) then begin
	tiltitle='Vector Tilt'
	longtitle='Vector Dipole Longitude'
	ptilt=tilt
	plong=diplong 
endif
if (tiltype eq 1) then begin
	tiltitle='Geomagnetic Tilt'
	longtitle='Geomagnetic Dipole Longitude'
	ptilt=180-tilt
	plong=glong
endif

;CONVERT FROM TILT TO LATITUDE
diplat=90-ptilt

;CONVERT FROM (-180,180) TO (0,360) FOR HISTOGRAMS
hlong=fltarr(n)
for i=0, n-1 do begin
   if (plong(i)  gt  0 ) then hlong(i)=plong(i)
   if (plong(i)  le  0 ) then hlong(i)=360+plong(i)
endfor  

PRINT, 'TILT RANGE= ',MIN(PTILT),MAX(PTILT)
NOL=90-25  & SOL=25-90
PRINT, 'ENTER POLAR PLOT LIMIT, deg (def=25):'
READ, INCLIMIT
HMIN=0 & HMAX=180 & HBIN=5
PRINT, 'ENTER TILT HISTOGRAM LIMIT, BINSIZE, deg (def=180,5):'
READ, HMAX, HBIN
NOL=90-INCLIMIT   &    SOL=INCLIMIT-90
;NORTH POLAR
MAP_SET,90,0,0,/ORTHOGRAPHIC,/ADVANCE,/NOBORDER,/NOERASE,/ISOTROPIC,$
	TITLE= TILTITLE + ' North', LIMIT=[NOL,-180,90,180]
PLOTS,plong,diplat,PSYM=3,SYMSIZE=1,COLOR=250,NOCLIP=0     
MAP_GRID,LATDEL=5,LONDEL=45,LONLAB=72,LATLAB=45,GLINETHICK=1,$
	LABEL=2,GLINESTYLE=0

;SOUTH POLAR
MAP_SET,-90,0,0,/ORTHOGRAPHIC,/ADVANCE,/NOBORDER,/NOERASE,/ISOTROPIC,$
	TITLE='South', LIMIT=[-90,-180,SOL,180]
PLOTS,plong,diplat,PSYM=3,SYMSIZE=1,COLOR=250,NOCLIP=0  
MAP_GRID,LATDEL=5,LONDEL=45,LONLAB=-72,LATLAB=45,GLINETHICK=1,$
	LABEL=2,GLINESTYLE=0 
 
;FULL AITOFF
MAP_SET,0,0,0,/AITOFF,/ADVANCE,/NOBORDER,/NOERASE,/ISOTROPIC,TITLE='0' 
PLOTS,plong,diplat,PSYM=3,SYMSIZE=2,COLOR=250
MAP_GRID,LATDEL=30,LONDEL=60,GLINESTYLE=0

;MAP_SET,0,180,0,/AITOFF,/ADVANCE,/NOBORDER,/NOERASE,/ISOTROPIC,TITLE='180' 
;PLOTS,plong,diplat,PSYM=3,SYMSIZE=2,COLOR=250
;MAP_GRID,LATDEL=30,LONDEL=60,GLINESTYLE=0   

;HISTOGRAM PLOTS
PRINT, 'Axial dipole min, max = '
PRINT, admin, admax
PRINT, ' '
PRINT, 'Enter axial dipole histogram (min, max, binsize):'
Read, axmin, axmax, axbin
dax=axmax-axmin

hnorm3=histogram(dipaxi,min=axmin,max=axmax,binsize=axbin)   ;axial dipole histogram
axhist=axbin*findgen(fix(dax/axbin))+ axmin; axial dipole size array
PLOT,axhist,float(hnorm3)/n,xtitle='Axial Dipole (cmb,rms)',title='Probability',PSYM=10,$
	xrange=[axmin,axmax],xstyle=1

hnorm1=histogram(ptilt,min=hmin,max=hmax,binsize=hbin)  ;histogram
tangle=hbin*findgen(hmax/hbin) + (hbin/2); tilt angle array
PLOT,tangle,float(hnorm1)/n,xtitle=tiltitle,title='Probability',PSYM=10,$
	xrange=[hmin,hmax],xstyle=1,xtickinterval=45


hnorm2=histogram(hlong,min=0, max=360, binsize=10)  ;histogram
langle=10*findgen(36) +5 
PLOT,langle,float(hnorm2)/n,xtitle=longtitle,title='Probability',PSYM=10,$
	xrange=[0,360],xstyle=1,xtickinterval=60


;HISTOGRAM TESTS
tsum=total(float(hnorm1)/n) 
lsum=total(float(hnorm2)/n)
PRINT, ''
PRINT, 'HISTOGRAM SUMS: (TILT, LONG)=  '
PRINT, tsum,lsum


GOTO, LABEL99
;77777777777777777777777777777777777777777777777777777777777777777

;88888888888888888888888888888888888888888888888888888888888888888
LABEL8: IPAGE=8

LOADCT, 39 		;loads color table 39

;SCATTER PLOTS
!P.MULTI = [0,2,1,0]
PRINT,'FIRST PLOT ME-1/KE SCATTER'
;PLOT,1/KE,ME,PSYM=3,XTITLE='1/KE',YTITLE='ME'
;COMPUTE FIT
AB=LINFIT(1/KE,ME,SIGMA=SS)
PRINT,'FIT TO Y=A+BX'
PRINT,'    A    sd(A)     B   sd(B)'
PRINT, AB(0),SS(0),AB(1),SS(1)
;PLOT LINEAR FIT ME vs 1/KE
X1=1/MAX(KE) & X2=1/MIN(KE) 
Y1=AB(0)+AB(1)*X1 & Y2=AB(0)+AB(1)*X2
;OPLOT,[X1,X2],[Y1,Y2],LINESTYLE=0,COLOR=250,THICK=2

PRINT,'SECOND PLOT Bmean-Dipole SCATTER
;PLOT,bmean,dipole,PSYM=3,XTITLE='Brms',YTITLE='Dipole'
;COMPUTE FIT
AD=LINFIT(bmean,dipole,SIGMA=SD)
PRINT,'FIT TO Y=A+BX'
PRINT,'    A    sd(A)     B   sd(B)'
PRINT, AD(0),SD(0),AD(1),SD(1)
;PLOT LINEAR FIT dipole vs bmean
X1=MAX(bmean) & X2=MIN(bmean) 
Y1=AD(0)+AD(1)*X1 & Y2=AD(0)+AD(1)*X2
;OPLOT,[X1,X2],[Y1,Y2],LINESTYLE=0,COLOR=250,THICK=2

PRINT, 'NOW PLOT DISSIPATION MODEL (BEST WITH SMOOTHED DATA)'
PRINT, 'CONTINUE WITH DISSIPATION MODEL=1'
READ,agone
;DEFINE MODEL ARRAYS
MEM=FLTARR(N)
BMM=FLTARR(N)
DIM=FLTARR(N)
;CALCULATE ME - bmean^2 scaling factor
BRATIO=TOTAL(BMEAN*BMEAN/2)/(TOTAL(ME)) & BRATIO=SQRT(BRATIO)
;CALCULATE DISSIPATION MODEL FOR ME, Brms, Dipole
MEM = AB(0) + (AB(1)/KE)
BMM = BRATIO*SQRT((2*AB(1)/KE) + 2*AB(0))
DIM = AD(0) + AD(1)*BMM

!P.MULTI = [0,1,4,0]

PLOT, time, KE, LINESTYLE = 0, TITLE='KE',$
	YRANGE=[kemin,kemax],xstyle=1

PLOT, time, ME, LINESTYLE = 0, TITLE='ME',$
	YRANGE=[memin,memax],xstyle=1
OPLOT, time, MEM, LINESTYLE = 0, color=250

PLOT, time, Dipole, LINESTYLE = 0, TITLE='Dipole',$
	YRANGE=[dmin,dmax],xstyle=1
OPLOT, time, DIM, LINESTYLE = 0, color=250

!P.MULTI=0
GOTO, LABEL99
;8888888888888888888888888888888888888888888888888888888888888

;11 11 11 11  11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11  11 
LABEL11: PRINT, 'ENTER NEW X,Y WINDOW DIMENSIONS; CURRENT= ',XWIND,YWIND
	  READ,XWIND,YWIND 
	 PRINT, FORMAT='("WINDOW SCALE FACTOR?  CURRENT=",F7.3)',SCWINDOW
          READ, SCWINDOW
          XWIND=XWINDOW*SCWINDOW & YWIND=YWINDOW*SCWINDOW
          CSZ=SCWINDOW*0.8 & CSB=1.12*SCWINDOW & CSS=0.60*SCWINDOW
          GOTO, LABEL99
;11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 


;12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12
LABEL12: PRINT, 'TRIM TIME SERIES'
PRINT, ' '

PRINT,'TIME RANGE= ',min(time),max(time)
PRINT, 'ENTER TIME START,STOP:'
READ,TSTART,TSTOP
dtime=max(time)-min(time)
nstart=ceil(n*tstart/dtime)
nstop=floor(n*tstop/dtime)
PRINT,'NSTART,NSTOP= ',nstart,nstop

time       = time(nstart:nstop)
ke	   = ke(nstart:nstop)	
kepol      = kepol(nstart:nstop)	
me         = me(nstart:nstop)	
mepol      = mepol(nstart:nstop)	
keaxtor    = keaxtor(nstart:nstop)
keaxpol    = keaxpol(nstart:nstop)
meaxipol   = meaxipol(nstart:nstop)
meaxitor   = meaxitor(nstart:nstop)
nutop	   = nutop(nstart:nstop)
nubot	   = nubot(nstart:nstop)
bmean	   = bmean(nstart:nstop)
dipole	   = dipole(nstart:nstop)
dipaxi	   = dipaxi(nstart:nstop)
tilt	   = tilt(nstart:nstop)
diplong	   = diplong(nstart:nstop)
vmean	   = vmean(nstart:nstop)
n          = nstop-nstart

GOTO, LABEL0
;12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12


;21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21
LABEL21: &
OUTFILE= ' '
PRINT,'ENTER FULL .PS FILE NAME:'
READ, OUTFILE 
SET_PLOT,'PS'
DEVICE,FILENAME=OUTFILE,/COLOR 
DEVICE,XSIZE=XDIM,YSIZE=YDIM,XOFFSET=1.8,YOFFSET=2.0

IF IPAGE LE 4 THEN BEGIN
!P.CHARSIZE=2
!P.THICK=3
!X.THICK=3
!Y.THICK=3
ENDIF

IF IPAGE EQ 6 THEN BEGIN
!P.CHARSIZE=1 
!P.THICK=2 
!X.THICK=2 
!Y.THICK=2
ENDIF

IF IPAGE EQ 7 THEN BEGIN
!P.CHARSIZE=1 
!P.THICK=2 
!X.THICK=2 
!Y.THICK=2
ENDIF

IF IPAGE EQ 8 THEN BEGIN
!P.CHARSIZE=1 
!P.THICK=2 
!X.THICK=2 
!Y.THICK=2
ENDIF

       CASE IPAGE OF
        1:    GOTO, LABEL1
        2:    GOTO, LABEL2
        3:    GOTO, LABEL3
 	4:    GOTO, LABEL4
	5:    GOTO, LABEL5
	6:    GOTO, LABEL6
	7:    GOTO, LABEL7
	8:    GOTO, LABEL8
        ELSE: GOTO, LABEL0
        ENDCASE

;21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21

;99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99
LABEL99: IF IOPTION EQ 21 THEN DEVICE,/CLOSE 
	 !P.MULTI = 0
	 SET_PLOT, 'X'	
	 !P.CHARSIZE=1
	 !P.THICK=1
	 !X.THICK=1
         !Y.THICK=1
	 LOADCT,LCOLOR
	 GOTO,LABEL0	
;99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99			

LABEL98: PRINT,'EXIT MAGTS'

END
