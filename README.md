# Brainfuck

Brainfuck interpreter in Elixir.

## Installation

Clone the repo and build the script

```
$ git clone https://github.com/jhbabon/brainfuck.ex.git
$ cd brainfuck.ex
$ mix escript.build
```

## Usage

Imagine that you have the following Brainfuck code in a file called `print_a.b`:

```brainfuck
Print the letter A from one cell to another
++++++ [ > ++++++++++ < - ] > +++++ .
```

To run it you just need to call the `brainfuck` executable with the path to the file:

```
$ ./brainfuck print_a.b
% Starting Brainfuck interpreter
% Source code:

Print the character A
++++++ [ > ++++++++++ < - ] > +++++ .

% Executing program:

A
```
