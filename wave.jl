using WAV

"""
### waverender(Timbrer;frequency, framerate=44100, amplitude=0.5)
- Timbrer as the timbre function, with T as 2pi, amplitude as 1.

return the standard wave synthesis method
"""
function waverender(Timbrer;frequency=440.0, framerate=44100, amplitude=0.5)
    amplitude > 1 && (amplitude = 1.0)
    amplitude < 0 && (amplitude = 0.0)
    return (i) -> begin
        T = 1.0 / frequency
        t = 1.0 / framerate * i
        amplitude * Timbrer(2.0 * pi * t / T)
    end
end;

"""
### computesamples(noteArray::AbstractArray;framerate=44100,shader=nothing::Any,shaderportion=0.1)
- noteArray as Array{[wavefunction,ticklen]}
- shader should be a function, take 1 float parameter, range from 0 to 1. return a scale from 1 to 0.

return the rendered data, as Array{Float64, 1}
"""
function computesamples(noteArray::AbstractArray;framerate=44100.0,shader=nothing::Any,shaderportion=0.1)
    finalRender = Array{Float64}(0)
    shader == nothing && (shader = (x) -> 1 - x)
    for (wavefunction,ticklen) in noteArray
        shaderStart = ticklen * ( 1.0 - shaderportion)
        finalRender = vcat(finalRender, Float32[wavefunction(i) for i = 1:shaderStart])
        finalRender = vcat(finalRender, Float32[wavefunction(i) * shader((i-shaderStart)/(ticklen-shaderStart)) for i = shaderStart:ticklen])
    end
    return finalRender
end;

toneDict = Dict(
    "C" => 1,
    "C#" => 2,
    "D" => 3,
    "D#" => 4,
    "E" => 5,
    "F" => 6,
    "F#" => 7,
    "G" => 8,
    "G#" => 9,
    "A" => 10,
    "A#" => 11,
    "B" => 12
);

function composer(sheet::String; f0 = 440.0, unit = 1.0, gap=0.05, timbrer=sin, framerate=44100.0, base_amplitude=0.5, shader=nothing,shaderportion=0.1)
    noteArray = Array{Array}(0)
    for note in split(sheet)
        if note == "-"
            noteArray[end-1][end] += unit*framerate
            continue
        end
        m = match(r"(?<tone>\w#?)(?<octave>\d)",note)
        tone = m[:tone]
        octave = Int(parse(m[:octave]))
        frequency = f0 * 2 ^(((toneDict[tone] + (octave-4)*12) - toneDict["A"])/12)

        noteArray = vcat(noteArray, [[waverender(timbrer,frequency=frequency),(1-gap)*framerate*unit],[waverender(timbrer,amplitude=0.0),gap*framerate*unit]])
    end
    render = computesamples(noteArray,framerate=framerate,shader=shader,shaderportion=shaderportion);
    return render
end;

function composer(sheet::String, outfilename::String; f0 = 440.0, unit=1.0, gap=0.05, timbrer=sin, framerate=44100.0, base_amplitude=0.5, shader=nothing,shaderportion=0.1)
    samples = composer(sheet, f0=f0, unit=unit,gap=gap, timbrer=timbrer, framerate=framerate, base_amplitude=base_amplitude, shader=shader,shaderportion=shaderportion)
    wavwrite(samples, outfilename, Fs=framerate);
    return samples
end;
