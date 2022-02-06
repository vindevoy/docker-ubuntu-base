#!/usr/bin/python

SOURCE_FILE = './src/docker/Dockerfile'
BUILD_FILE = './build/docker/Dockerfile'

NO_INDENT_SPACES = 0
EXTRA_INDENT_SPACES = 4
RUN_INDENT_SPACES = 4


def optimize():
    optimized = ''
    command = ''
    previous_command = ''
    next_line_continued = False
    next_command_continued = False

    src = open(SOURCE_FILE, 'r')

    for line in src.readlines():
        line = line.strip()

        if len(line) > 0 and line[0:1] != '#':
            if next_line_continued:
                extra_spaces = NO_INDENT_SPACES if next_command_continued else EXTRA_INDENT_SPACES
                optimized += '\n' + (' ' * (len(command) + extra_spaces + 1)) + '{0}'.format(line)
            else:
                command = line.split()[0].upper()

                if command == 'RUN':
                    if previous_command != 'RUN':
                        optimized += '\nRUN set -x'

                    # 4 is the length of the RUN command and a blank, nothing to do with the indent spaces
                    optimized += ' && \\ \n{0}{1}'.format(' ' * RUN_INDENT_SPACES, line[RUN_INDENT_SPACES:].strip())
                else:
                    if previous_command == 'RUN':
                        optimized += '\n'

                    if previous_command != command and previous_command != '':
                        optimized += '\n'

                    optimized += '{0} {1}\n'.format(command.upper(), line[len(command) + 1:].strip())

            previous_command = command
            next_line_continued = line.endswith('\\')
            next_command_continued = line.replace(' ', '').endswith('&&\\')

    src.close()

    build = open(BUILD_FILE, 'w+')
    build.write(optimized)
    build.close()


if __name__ == '__main__':
    optimize()
