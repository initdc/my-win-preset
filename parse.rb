require "json"
require "yaml"

# read json from preset directory, generate readme file
# short desc read from blow url, replace the url for each package
# https://github.com/microsoft/winget-pkgs/blob/master/manifests/b/Bitwarden/Bitwarden/2025.4.2/Bitwarden.Bitwarden.locale.en-US.yaml
# with row
# 软件包名称 | 软件包ID | 软件包描述 | 软件包版本  | 来源

# Define the preset directory and output file
PRESET_DIR = "./preset".freeze
OUTPUT_FILE = "./README.md".freeze

def read_json_file
  JSON.parse(File.read("#{PRESET_DIR}/coder.ubundle"))
end

# Generate the README content
def generate_readme(data)
  title = "# My Win Preset\n\n>My preset bundles of UniGetUI for Windows 10.\n\n"
  t1 = "## Coder bundle\n\n"
  t2 = "## License\n\nMPL-2.0\n"

  header = "| 软件包名称 | 软件包ID | 软件包描述 | 软件包版本 | 来源 |\n"
  separator = "|------------|-----------|------------|------------|------|\n"
  packages = data["packages"]

  arr = []
  hash = {}

  packages.each do |package|
    index_name = package["Name"].downcase
    arr.push index_name
    hash[index_name] = package
  end

  rows = []
  arr.sort.each do |index_name|
    package = hash[index_name]
    source = package["Source"]
    name = package["Name"] || "N/A"
    id = package["Id"] || "N/A"
    version = package["Version"] || "N/A"
    source = package["Source"] || "N/A"
    row = "| #{name} | #{id} | N/A | #{version} | #{source} |"

    if source == "winget"
      manifest_info = manifest(package)
      unless manifest_info
        puts row
        rows.push row
        next
      end
      icon = manifest_info["PublisherUrl"] ? "<img width='32px' height='32px' src='https://www.google.com/s2/favicons?sz=32&domain=#{manifest_info["PublisherUrl"].gsub("https://", "")}'>" : ""
      # description = manifest_info ? "#{manifest_info["ShortDescription"]}" : "N/A"
      description = "N/A"
      row = "| #{icon}#{name} | #{id} | #{description} | #{version} | #{source} |"
    end

    puts row
    rows.push row
  end
  title + t1 + header + separator + rows.join("\n") + "\n\n" + t2
end

def manifest(package)
  index = package["Id"][0].downcase
  id = package["Id"]
  version = package["Version"]
  # path = "../winget-pkgs/manifests/#{index}/#{id.gsub(".","/")}/#{version}/#{id}.yaml"
  # locale = JSON.load(crlf_to_lf(path))["DefaultLocale"] || "zh-CN"
  locale = "zh-CN"
  path = "../winget-pkgs/manifests/#{index}/#{id.gsub(".", "/")}/#{version}/#{id}.locale.#{locale}.yaml"
  unless File.file?(path)
    path = "../winget-pkgs/manifests/#{index}/#{id.gsub(".", "/")}/#{version}/#{id}.locale.en-US.yaml"
  end
  return nil unless File.file?(path)

  YAML.safe_load(crlf_to_lf(path))
end

def crlf_to_lf(path)
  lines = File.readlines(path)
  lines.join.gsub("\r\n", "\n")
end

# Write the README file
def write_readme(content)
  File.open(OUTPUT_FILE, "w") do |file|
    file.write(content)
  end
end

# Main logic
def main
  data = read_json_file
  readme_content = generate_readme(data)
  write_readme(readme_content)
  puts "README.md has been generated successfully."
end

main
