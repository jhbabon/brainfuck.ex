defmodule Brainfuck do
  # TODO: More documentation
  @moduledoc """
  Brainfuck interpreter

  ## Examples

      iex> Brainfuck.eval("++++++ [ > ++++++++++ < - ] > +++++ .")
      A
  """

  @token_inc ?+
  @token_dec ?-
  @token_right ?>
  @token_left ?<
  @token_output ?.
  @token_input ?,
  @token_loop_begin ?[
  @token_loop_end ?]

  @tokens [
    @token_inc,
    @token_dec,
    @token_right,
    @token_left,
    @token_output,
    @token_input,
    @token_loop_begin,
    @token_loop_end,
  ]

  defmodule Token do
    defstruct symbol: nil, meta: %{}
  end

  defmodule Tape do
    @size 30
    @cells Stream.iterate(0, fn(_) -> 0 end) |> Enum.take(@size)

    defstruct cells: @cells, head: 0
  end

  defprotocol Memory do
    def read(data)
    def write(data, value)
    def inc(data)
    def dec(data)
    def right(data)
    def left(data)
  end

  defimpl Memory, for: Tape do
    def read(tape) do
      Enum.at(tape.cells, tape.head)
    end

    def write(tape, value) do
      cells = List.replace_at(tape.cells, tape.head, value)

      %{tape | cells: cells}
    end

    def inc(tape) do
      write(tape, read(tape) + 1)
    end

    def dec(tape) do
      write(tape, read(tape) - 1)
    end

    def right(tape) do
      %{tape | head: tape.head + 1}
    end

    def left(tape) do
      %{tape | head: tape.head - 1}
    end
  end

  def eval(src, tape \\ %Tape{}, io \\ :stdio) do
    src |> tokenize |> execute(tape, io)
  end

  def token?(char) do
    Enum.member?(@tokens, char)
  end

  def tokenize(src) when is_binary(src) do
    src |> String.to_charlist |> Enum.filter(&token?/1) |> tokenize
  end

  def tokenize([]), do: []

  def tokenize([@token_loop_begin | tail]) do
    # We found a loop, we need to extract its
    # body so we now the size of it at
    # execution time.
    {token, loop, rest} = extract_loop(tail)
    [token | loop ++ tokenize(rest) ]
  end

  def tokenize([char | tail]) do
    [%Token{symbol: char} | tokenize(tail)]
  end

  def extract_loop(source) do
    loop  = tokenize_loop(source)
    size  = length(loop)
    token = %Token{symbol: @token_loop_begin, meta: %{size: size}}
    rest  = Enum.drop(source, size)

    {token, loop, rest}
  end

  def tokenize_loop([]), do: []

  def tokenize_loop([@token_loop_begin | tail]) do
    # This is a loop inside a loop, we need
    # to start again the loop process
    {token, loop, rest} = extract_loop(tail)
    [token | loop ++ tokenize_loop(rest) ]
  end

  def tokenize_loop([@token_loop_end | _tail]) do
    [%Token{symbol: @token_loop_end}]
  end

  def tokenize_loop([char | tail]) do
    [%Token{symbol: char} | tokenize_loop(tail)]
  end

  def execute([], tape, _io) do
    {:ok, tape}
  end

  def execute([%Token{symbol: @token_inc} | tail], tape, io) do
    execute(tail, Brainfuck.Memory.inc(tape), io)
  end

  def execute([%Token{symbol: @token_dec} | tail], tape, io) do
    execute(tail, Brainfuck.Memory.dec(tape), io)
  end

  def execute([%Token{symbol: @token_right} | tail], tape, io) do
    execute(tail, Brainfuck.Memory.right(tape), io)
  end

  def execute([%Token{symbol: @token_left} | tail], tape, io) do
    execute(tail, Brainfuck.Memory.left(tape), io)
  end

  def execute([%Token{symbol: @token_output} | tail], tape, io) do
    codepoint = Brainfuck.Memory.read(tape)
    IO.write(io, to_string([codepoint]))

    execute(tail, tape, io)
  end

  def execute([%Token{symbol: @token_input} | tail], tape, io) do
    value = IO.read(io, 1) |> String.to_charlist |> hd

    execute(tail, Brainfuck.Memory.write(tape, value), io)
  end

  def execute([%Token{symbol: @token_loop_begin} = token | tail], tape, io) do
    value = Brainfuck.Memory.read(tape)
    size = token.meta.size
    if value == 0 do
      # jump!
      execute(Enum.drop(tail, size), tape, io)
    else
      loop_body = Enum.take(tail, size - 1) # skip ?]
      {:ok, tape} = execute(loop_body, tape, io)
      execute([token | tail], tape, io) # restart
    end
  end

  def execute([%Token{symbol: @token_loop_end} | _], _, _) do
    # This should never happen
    {:error, :unbalanced_loop}
  end
end
