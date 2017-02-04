#!/usr/bin/env ruby

require "jekyll"
require "yaml"

$created_at = Time.now

def create_yaml(path, time)
    file = File.new(path, "w")
    empty_data = {"created" => time}
    file.puts(empty_data.to_yaml)
    file.close
end

module Jekyll
  class StaticFile
    def initialize(site, base, dir, name, collection = nil)
        @site = site
        @base = base
        @dir  = dir
        @name = name
        @collection = collection
        @relative_path = File.join(*[@dir, @name].compact)
        @extname = File.extname(@name)

        if site.config['filesize_yaml']
            if !File.exist?(site.config['filesize_yaml'])
                create_yaml(site.config['filesize_yaml'], site.time)
            end
            yamldata = YAML.load_file(site.config['filesize_yaml'])
            if yamldata[@relative_path] <=> File.size(File.join(".", @relative_path))
                return
            end
            yamldata[@relative_path] = File.size(File.join(".", @relative_path))
            File.open(site.config['filesize_yaml'], "w") {|f| f.write yamldata.to_yaml }
        end
    end

    def to_liquid
      {
        "basename"      => File.basename(name, extname),
        "name"          => name,
        "extname"       => extname,
        "modified_time" => modified_time,
        "filesize"      => File.size(File.join(".", relative_path)),
        "path"          => File.join("", relative_path)
      }
    end
  end
end
