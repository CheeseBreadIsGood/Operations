Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.speak('Testing')
##('Starting Internet Reliability Analysis')
$information = Test-NetConnection -ComputerName google.com
$lag = $information.PingReplyDetails.RoundtripTime