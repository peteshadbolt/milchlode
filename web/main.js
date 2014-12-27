var context = null;

// success callback when requesting audio input stream
function gotStream(stream) {
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    var ctx = new AudioContext();

    // Create an AudioNode from the stream.
    var micSource = ctx.createMediaStreamSource(stream);

    // Connect it to the destination to hear yourself (or any other node for processing!)
    micSource.connect(ctx.destination);

}

document.addEventListener('DOMContentLoaded', function() {

    //if (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia)
    //navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;

    if (!navigator.getUserMedia) navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
    var constraints = { "audio": { "mandatory": { "googEchoCancellation": "false", "googAutoGainControl": "false", "googNoiseSuppression": "false", "googHighpassFilter": "false" }}}
    navigator.getUserMedia(constraints, gotStream, function(e) { alert('Error getting audio'); console.log(e); });

    //var controls = $("div#sliders");

    //controls.find("input[name='delayTime']").on('input', function() {
    //delay.delayTime.value = $(this).val();
    //});

    //controls.find("input[name='feedback']").on('input', function() {
    //feedback.gain.value = $(this).val();
    //});

    //controls.find("input[name='frequency']").on('input', function() {
    //filter.frequency.value = $(this).val();
    //});

    //delay = ctx.createDelay();
    //delay.delayTime.value = 0.5;
    //feedback = ctx.createGain();
    //feedback.gain.value = 0.8;
    //filter = ctx.createBiquadFilter();
    //filter.frequency.value = 1000;
    //delay.connect(feedback);
    //feedback.connect(filter);
    //filter.connect(delay);
    //source.connect(delay);
    //source.connect(ctx.destination);
    //delay.connect(ctx.destination);

});

