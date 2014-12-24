<CsoundSynthesizer>
<CsOptions> -iadc -odac -dm0 </CsOptions>

<CsInstruments>
; CSound parameters
sr = 44100 ; Sample rate
ksmps = 20 ; Number of audio samples in each control cycle
nchnls = 2 ; Number of channels (2=stereo)
0dbfs = 1  ; Maximum amplitude

; Delay parameters
gkporttime = 0.3 ; Portamento time
gkdlt = 5        ; Max delay
gkmix = .5       ; Dry/wet
gkfeedamt = .95  ; Feedback ratio
gkamp = .7       ; Output amplitude rescaling
gkingain = .5    ; Input gain

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

; Sense keyboard
kKey FLkeyIn	
kChanged changed kKey			
printk2	kKey
;if kKey=112&&kChanged=1 then
    ;printf_i "awd"
    ;FLsetVal_i 0.0, gkfeedamt
;endif

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

outs aL * gkamp, aR * gkamp ;Mix wet/dry
clear gasigL, gasigR ;Clear global audio sends
endin

</CsInstruments>


<CsScore>
i 2 0 -1 ;Instrument 2 plays a held note
f 0 3600 ;Keep performance going
</CsScore>
</CsoundSynthesizer>
