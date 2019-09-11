require 'erb'
require 'json'
require 'optparse'

#parse the command line ARGS
options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: genStudyPres.rb [options]"

    opts.on("-i FILENAME", "--input=FILENAME", "The input filename (required)") do |filename|
        options[:filename] = filename
    end

    opts.on("-o OUTDIR", "--outdir=OUTDIR", "The output directory (optional)") do |outdir|
        options[:outdir] = outdir
    end
    
    opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
    end
end.parse!

#check the filename was given
filename = options[:filename]
if filename.nil?
    puts "The input filename is required"
    exit
end

#get the filename and verify it exists
if !File.exists?(filename)
    puts "Input file '#{filename}' not found"
    exit
end

out_name = File.basename(filename, File.extname(filename))
out_dir = (!options[:outdir].nil? ? options[:outdir] : 'output') + '/' + out_name

#read the questions JSON and create the hash
questions = JSON.parse(File.read(filename))['questions']

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

#create the output directory if it does not exist
Dir.mkdir(out_dir) unless File.exists?(out_dir)

#write to the file
outTexFile = "bin/#{out_name}.tex"
open(outTexFile, 'w') do |f|
    f.puts template.result
end

#run the latex compiler
system("/usr/local/texlive/2019/bin/x86_64-darwin/pdflatex -jobname=#{out_name} -output-directory=#{out_dir} #{outTexFile}")