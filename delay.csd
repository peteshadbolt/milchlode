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

; FLTK GUI interface
FLpanel "M I L C H L O D E", 500, 300, 0, 0, 0, 1
gkInputGain,ihInputGain FLslider "Input Gain", 0, 1, 0, 3, -1, 400, 20, 5, 5
gkInputMute,ihInputMute FLbutton "Mute", 0, 1, 3, 85, 25, 410, 5, 0, 1, 0, -1

; Sliders
gkdlt,ihdlt FLslider "Delay Time (sec)", .001, 5, 0, 3, -1, 490, 25, 5, 50
gkmix,ihmix FLslider "Dry/Wet Mix", 0, 1, 0, 3, -1, 490, 25, 5, 100
gkfeedamt,ihfeedamt FLslider "Feedback Ratio", 0, 1, 0, 3, -1, 490, 25, 5, 150

; Set defaults
FLsetVal_i 1, ihInputMute
FLsetVal_i .5, ihInputGain
FLsetVal_i 1, ihdlt
FLsetVal_i 0.5, ihmix
FLsetVal_i 0.95, ihfeedamt

FLpanel_end ;End of GUI
FLrun ;Run the FLTK thread

; Instr 1 is the source
instr 1 

; Turn off with the switch
if gkInputMute=0 then 
turnoff 
endif

; Get input from mic/line
asigL, asigR ins 
gasigL = asigL * gkInputGain 
gasigR = asigR * gkInputGain 
endin

; Instr 2 is the delay line
instr 2 

adlt = gkdlt

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

gkamp = .7;
outs aL * gkamp, aR * gkamp ; Mix wet/dry
clear gasigL, gasigR        ; Clear global audio sends
endin

</CsInstruments>

<CsScore>
i 2 0 -1 ;Instrument 2 plays a held note
f 0 3600 ;Keep performance going
</CsScore>

</CsoundSynthesizer>
