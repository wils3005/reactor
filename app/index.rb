# frozen_string_literal: true

index_html = File.read(File.join(__dir__, 'index.html'))

get /\A\/\z/ do
  body = format(
    index_html,
    title: 'Flump!',
    host: Flump::HOST,
    port: Flump::PORT
  )

  [200, {}, body]
end
