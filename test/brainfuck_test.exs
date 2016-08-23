defmodule BrainfuckTest do
  use ExUnit.Case
  doctest Brainfuck

  # @tag :pending
  test "eval '+'" do
    tape = %Brainfuck.Tape{cells: [0,0,0], head: 0}
    {:ok, tape} = Brainfuck.eval("+", tape)

    assert tape.cells == [1, 0, 0]
  end

  # @tag :pending
  test "eval '-'" do
    tape = %Brainfuck.Tape{cells: [1,0,0], head: 0}
    {:ok, tape} = Brainfuck.eval("-", tape)

    assert tape.cells == [0, 0, 0]
  end

  # @tag :pending
  test "eval '>'" do
    tape = %Brainfuck.Tape{cells: [1,0,0], head: 0}
    {:ok, tape} = Brainfuck.eval(">", tape)

    assert tape.head == 1
  end

  # @tag :pending
  test "eval '<'" do
    tape = %Brainfuck.Tape{cells: [1,0,0], head: 1}
    {:ok, tape} = Brainfuck.eval("<", tape)

    assert tape.head == 0
  end

  # @tag :pending
  test "eval '.'" do
    tape = %Brainfuck.Tape{cells: [65,0,0], head: 0}
    {:ok, io} = StringIO.open("")
    Brainfuck.eval(".", tape, io)
    {_, output} = StringIO.contents(io)

    assert output == "A"

    StringIO.close(io)
  end

  # @tag :pending
  test "eval ','" do
    tape = %Brainfuck.Tape{cells: [0,0,0], head: 0}
    {:ok, io} = StringIO.open("A")
    {:ok, tape} = Brainfuck.eval(",", tape, io)

    assert tape.cells == [65,0,0]

    StringIO.close(io)
  end

  # @tag :pending
  test "eval '[-]' over zero value" do
    tape = %Brainfuck.Tape{cells: [0,0,0], head: 0}
    {:ok, tape} = Brainfuck.eval("[-]", tape)

    assert tape.cells == [0,0,0]
  end

  # @tag :pending
  test "eval '[-]' over non zero value" do
    tape = %Brainfuck.Tape{cells: [2,0,0], head: 0}
    {:ok, tape} = Brainfuck.eval("[-]", tape)

    assert tape.cells == [0,0,0]
  end

  # @tag :pending
  test "eval nested loops '[[-]>]'" do
    tape = %Brainfuck.Tape{cells: [2,2,0], head: 0}
    {:ok, tape} = Brainfuck.eval("[[-]>]", tape)

    assert tape.cells == [0,0,0]
    assert tape.head == 2
  end

  test "eval '++++++ [ > ++++++++++ < - ] > +++++ .' prints A" do
    tape = %Brainfuck.Tape{cells: [0,0,0], head: 0}
    {:ok, io} = StringIO.open("")
    {:ok, tape} = Brainfuck.eval("++++++ [ > ++++++++++ < - ] > +++++ .", tape, io)
    {_, output} = StringIO.contents(io)

    assert output == "A"
    assert tape.cells == [0, 65, 0]

    StringIO.close(io)
  end

  test "eval ', [ > + < - ] > .' moves input" do
    tape = %Brainfuck.Tape{cells: [0,0,0], head: 0}
    {:ok, io} = StringIO.open("B")
    {:ok, tape} = Brainfuck.eval(", [ > + < - ] > .", tape, io)
    {_, output} = StringIO.contents(io)

    assert output == "B"
    assert tape.cells == [0, 66, 0]

    StringIO.close(io)
  end

  test "eval does not allow unbalanced loops" do
    tape = %Brainfuck.Tape{cells: [0,0,0], head: 0}
    {:error, value} = Brainfuck.eval("[-]]", tape)

    assert value == :unbalanced_loop
  end
end
