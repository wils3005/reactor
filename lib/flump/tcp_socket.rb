# typed: true
# frozen_string_literal: true

class TCPSocket
  def read_write_async
    @req = read_async
    Flump.logger.info(@req)
    @res = Marshal.dump(eval(@req))
    Flump.logger.info(@res)
    write_async(@res)
  rescue EOFError, Errno::ECONNRESET => e
    Flump.logger.warn(e)
    close
  end
end
