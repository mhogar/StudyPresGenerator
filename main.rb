require 'erb'
require 'json'

filename = 'testInput.json'
#out_name = 'TestSlides'

#read the questions JSON and create the hash
questions = JSON.parse(File.read('./src/' + filename))['questions']

#do some processing on the questions (ie. randomize the order)

#compile the template
template = ERB.new(File.read('./slidesTemplate.tex.erb'))

#write to the file
open('bin/slides.tex', 'w') do |f|
    f.puts template.result
end

#run the latex compiler
