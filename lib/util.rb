require 'stringio'

module Kernel
  # Temporarily silence stdout for noisy code
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end
