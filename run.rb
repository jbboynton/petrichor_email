require "pathname"
require "premailer"

SOURCE_GLOB = Pathname.new("./source/**.*")
DIST_TXT_PATH = Pathname.new("./dist/txt")
DIST_HTML_PATH = Pathname.new("./dist/html")

def output_filepath(filename:, suffix:)
  prefix = path_without_extension(filename)
  build_output_path(prefix, suffix)
end

def path_without_extension(path)
  File.basename(path, ".*")
end

def build_output_path(base, extension)
  if extension == "html"
    dist_path = DIST_HTML_PATH
  elsif extension == "txt"
    dist_path = DIST_TXT_PATH
  else
    raise "invalid file extension given (must be .html or .txt)"
  end

  extension = check_extension_format(extension)
  new_filename = Pathname.new(base).sub_ext(extension)
  output_path = dist_path.join(new_filename)

  output_path
end

def check_extension_format(extension)
  unless extension.start_with?(".")
    extension = extension.prepend(".")
  end

  extension
end

Dir.glob(SOURCE_GLOB) do |raw_mail|
  premailer = Premailer.new(raw_mail, :warn_level => Premailer::Warnings::SAFE)
  txt_filepath = output_filepath(filename: raw_mail, suffix: "txt")
  html_filepath = output_filepath(filename: raw_mail, suffix: "html")

  File.open(txt_filepath, "w") do |fout|
    fout.puts premailer.to_plain_text
  end

  File.open(html_filepath, "w") do |fout|
    fout.puts premailer.to_inline_css
  end

  premailer.warnings.each do |w|
    puts "#{w[:message]} (#{w[:level]}) may not render properly in #{w[:clients]}"
  end
end
