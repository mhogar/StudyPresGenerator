require 'erb'
require 'json'

filename = 'testInput.json'
out_name = 'TestSlides'

#read the questions JSON and create the hash
questions = JSON.parse(File.read('src/' + filename))['questions']

#randomize the question order
range = 0...questions.length
for i in range do
    newIndex = rand(range)

    if (newIndex != i)
        temp = questions[i]
        questions[i] = questions[newIndex]
        questions[newIndex] = temp
    end
end

#compile the template
template = ERB.new(File.read('slidesTemplate.tex.erb'))

#write to the file
outTexFile = 'bin/slides.tex'
open(outTexFile, 'w') do |f|
    f.puts template.result
end

#run the latex compiler
system("/usr/local/texlive/2019/bin/x86_64-darwin/pdflatex -jobname=#{out_name} -output-directory=output #{outTexFile}")