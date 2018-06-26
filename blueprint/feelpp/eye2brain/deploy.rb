#!/usr/bin/ruby

require 'Liquid'
@template = Liquid::Template.parse(File.read("blueprint.yaml.template"))
for l in 0..2
  puts l
  puts ("level #{l}")
  system 'mkdir', '-p', "level#{l}"
  unless Dir.exist?("level#{l}/scripts")
    system 'cp', '-r', 'upload/scripts', "level#{l}"
  end
  File.write("level#{l}/blueprint.yaml", @template.render(
               "level" => "#{l}",
               "job_tasks" => "1"
             )) if l == 0
  File.write("level#{l}/blueprint.yaml", @template.render(
               "level" => "#{l}",
               "job_tasks" => "10",
             )) unless l == 0
  if File.exist?("feelpp_e2b_level#{l}.tar")
    system 'rm',"feelpp_e2b_level#{l}.tar"
  end
  system 'tar','cvf',"feelpp_e2b_level#{l}.tar","level#{l}"
end
