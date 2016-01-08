import re


def _actual_lines(path):
    """
    Returns a generator that yields each line in the file at the given path.
    """
    with open(path) as f:
        for line in f:
            yield line


def _expected_lines(path, check_prefix):
    """
    Returns a generator that yields each line in the file at the given path
    that begins with the given prefix.
    """
    with open(path) as f:
        for line in f:
            if line.startswith(check_prefix):
                yield line[len(check_prefix):]


def compare(actual, expected, check_prefix):
    """
    Compares each line in the two given files.
    If any line in the 'actual' file doesn't match the regex in the 'expected'
    file, raises an AssertionError. Also raises an AssertionError if the number
    of lines in the two files differ.
    """
    for actual_line, expected_line in map(
            None,
            _actual_lines(actual),
            _expected_lines(expected, check_prefix)):
        if actual_line is None:
            raise AssertionError('There were more lines expected to appear '
                                 'than there were lines in the actual input.')
        if expected_line is None:
            raise AssertionError('There were more lines than expected to '
                                 'appear.')
        if not re.match(expected_line, actual_line):
            raise AssertionError('Actual line did not match the expected '
                                 'regular expression.\n'
                                 'Actual: {}\n'
                                 'Expected: {}\n'.format(
                                     repr(actual_line), repr(expected_line)))
