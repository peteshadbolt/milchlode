<CsoundSynthesizer>
<CsOptions> 
-iadc -odac -dm0 
</CsOptions>

<CsInstruments>
; CSound parameters
sr = 44100 ; Sample rate
ksmps = 20 ; Number of audio samples in each control cycle
nchnls = 2 ; Number of channels (2=stereo)
0dbfs = 1  ; Maximum amplitude

; Delay parameters
gkporttime init 0.3 ; Portamento time
;gkdlt init 5        ; Max delay
;gkmix init .5       ; Dry/wet
;gkfeedamt init .95  ; Feedback ratio
;gkamp init .7       ; Output amplitude rescaling
;gkingain init .5    ; Input gain
;gkOnOff init 1      ; Input on off

;FLTK GUI interface
FLcolor 200, 200, 255, 0, 0, 0
FLpanel "M I L C H L O D E", 500, 300, 0, 0, 0, 1
gkOnOff,ihOnOff FLbutton "Input On/Off", 1, 0, 22, 180, 25, 5, 5, 0, 1, 0, -1

; Sliders
gkdlt,ihdlt FLslider "Delay Time (sec)", .001, 5, 0, 23, -1, 490, 25, 5, 50
gkmix,ihmix FLslider "Dry/Wet Mix", 0, 1, 0, 23, -1, 490, 25, 5, 100
gkfeedamt,ihfeedamt FLslider "Feedback Ratio", -1, 1, 0, 23, -1, 490, 25, 5, 150
gkamp,ihamp FLslider "Output Amplitude Rescaling", 0, 1, 0, 23, -1, 490, 25, 5, 200
gkingain,ihingain FLslider "Input Gain", 0, 1, 0, 23, -1, 140, 20, 350, 5
ih FLbox "Keys: ", 1, 5, 14, 490, 20, 0, 250

;Set defaults
FLsetVal_i 1, ihOnOff
FLsetVal_i .5, ihingain
FLsetVal_i 4, ihdlt
FLsetVal_i 0.5, ihmix
FLsetVal_i 0.95, ihfeedamt
FLsetVal_i .7, ihamp

FLpanel_end ;End of GUI
FLrun ;Run the FLTK thread

; Instr 1 is the source
instr 1 

; Turn off with the switch
if gkOnOff=0 then 
    turnoff 
endif

; Get input from mic/line
asigL, asigR ins 
gasigL = asigL * gkingain 
gasigR = asigR * gkingain 
endin

; Instr 2 is the delay line
instr 2 

kporttime linseg 0, .001, 1, 1, 1  ; A short envelope
kporttime = kporttime * gkporttime ; TODO: remove this
kdlt portk gkdlt, kporttime        ; Apply portamento
adlt interp kdlt                   ; Interpolate

;Left channel
abufferL delayr 5 ;Buffer
adelsigL deltap3 adlt ;Tap
delayw gasigL + (adelsigL * gkfeedamt) ;Feedback

;Right channel
abufferR delayr 5 ;Buffer
adelsigR deltap3 adlt ;Tap
delayw gasigR + (adelsigR * gkfeedamt) ;Feedback

aL ntrpol gasigL, adelsigL, gkmix
aR ntrpol gasigR, adelsigR, gkmix

outs aL * gkamp, aR * gkamp ; Mix wet/dry
clear gasigL, gasigR        ; Clear global audio sends
endin

</CsInstruments>


<CsScore>
i 2 0 -1 ;Instrument 2 plays a held note
f 0 3600 ;Keep performance going
</CsScore>

</CsoundSynthesizer>
