include("kiwiComposer.jl")
import kiwiComposer

const doc = """
kiwiComposer

Usage:
    compose.jl FILENAME [-o OUTPUTNAME]
"""
const version = v"0.1"

using DocOpt

arguments = docopt(doc, version=version)
print(arguments)

targetFile = open(arguments["FILENAME"])
setting = readline(targetFile)
sheet = readstring(targetFile)
close(targetFile)

unit = 1.0
eval(parse(setting))
@show setting
print(sheet)

if arguments["-o"]
    kiwiComposer.composer(sheet,arguments["OUTPUTNAME"],unit=unit)
else
    name = match(r"(?<name>.*?)\.\w?", arguments["FILENAME"])[:name]
    kiwiComposer.composer(sheet,name*".wav",unit=unit)
end
