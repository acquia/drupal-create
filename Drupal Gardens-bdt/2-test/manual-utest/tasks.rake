desc 'Export TCM for uTest'
task :export_tcm_for_utest do |args|
  puts `cd ./2-test/behavior-cucumber; cucumber -t @utest -d  -m -i -s -x | sed s/@utest//`
end
