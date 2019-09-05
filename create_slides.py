#get the last used src file name
f = open('questions_answers.tex', 'r')
old_src_file = f.readline()
f.close()
old_src_file = old_src_file[1:][:-1] #remove first and last character

print('Enter the src file name or nothing for last used file (' + old_src_file + ')')
src_file = input()

if src_file == '':
    src_file = old_src_file

#open file and create list
from os import path
if not path.isfile('src\\' + src_file + '.txt'):
    print('src file src\\' + src_file + '.txt not found')
    print('Press enter to exit...')
    input()
    quit()

f = open('src\\' + src_file + '.txt', 'r')
lines = list(f)
f.close()

#re-structure the list with q,a pairs
qa_list = []
for line in lines:
    if line[-1] == '\n':
        line = line[:-1]
    qa = line.split('&')
    qa_list.append([qa.pop(0), qa])

#randomize the list
import random
for i in range(0, len(qa_list)):
    rand = random.randint(0, len(qa_list)-1)
    if not rand == i:
        temp = qa_list[rand]
        qa_list[rand] = qa_list[i]
        qa_list[i] = temp

#open new file and write the qa's
f = open('questions_answers.tex', 'w')
f.write('%' + src_file + '\n\n')
i = 1
for qa in qa_list:
    template = "\\begin{{frame}}\n\\frametitle{{Question {} of {}}}\n\\begin{{block}}{{{}}}\n\\pause \\begin{{itemize}}\n{}\\end{{itemize}}\n\\end{{block}}\n\\end{{frame}}\n\n"
    answer_text = ''
    for answer in qa[1]:
        answer_text += '\item ' + answer + '\n'
    f.write(template.format(i, len(qa_list), qa[0] + " ({})".format(len(qa[1])), answer_text))
    i+=1
f.close()

#run latex compiler
from subprocess import call
call(['XeLaTeX', 'study_pres.tex', '--output-directory=output/', '-job-name=' + src_file, '-aux-directory=bin/'])

print('\nPress enter to exit...')
input()
