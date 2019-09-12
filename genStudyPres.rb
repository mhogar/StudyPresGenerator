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
    
    opts.on("-r", "--random", "Randomize the question order (Default: false)") do
        options[:random] = true
    end

    opts.on("-v", "--verbose", "Run the LaTeX compiler with more output (Default: false") do
        options[:verbose] = true
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

#set the other inputs
out_name = File.basename(filename, File.extname(filename))
out_dir = (!options[:outdir].nil? ? options[:outdir] : 'output') + '/' + out_name
random = !options[:random].nil?
verbose = !options[:verbose].nil?

#print the application name and input state
puts 'Study Pres Generator (v1.0.0)'
puts "Input Filename: '#{filename}'"
puts "Ouput Directory: '#{out_dir}'"
puts "Randomize Question Order: #{random}"
puts "Verbose LaTeX Output: #{verbose}"
puts "\n"

#read the questions JSON and create the hash
questions = JSON.parse(File.read(filename))['questions']

#randomize the question order if the flag is set
if (random)
    range = 0...questions.length
    for i in range do
        newIndex = rand(range)

        if (newIndex != i)
            temp = questions[i]
            questions[i] = questions[newIndex]
            questions[newIndex] = temp
        end
    end
end

#compile the template
template = ERB.new(File.read('slidesTemplate.tex.erb'))

#create the output directory if it does not exist
Dir.mkdir(out_dir) unless File.exists?(out_dir)

#write to the file
outTexFile = "#{out_dir}/#{out_name}.tex"
open(outTexFile, 'w') do |f|
    f.puts template.result
end

#LaTeX command
#Update the program to the location of the latex executable. If it is on your path, then you can just use the executable name
#Update the flag values according to your distribution as they tend to vary
#Optionally, you can also add new flags to this hash
latex_command = {
    program: "/usr/local/texlive/2019/bin/x86_64-darwin/pdflatex",
    jobname: "-jobname=#{out_name}",
    outdir: "-output-directory=#{out_dir}",
    verbose: (verbose ? '' : '-interaction=batchmode'),
    filename: "#{outTexFile}"
}

#run the latex compiler
result = system(latex_command.values.join(' '))
if (result == true)
    puts "LaTeX completed successfully. Created '#{out_dir}/#{out_name}.pdf'"
elsif
    puts "LaTeX failed. Re-run with '-v' flag for more output."
end