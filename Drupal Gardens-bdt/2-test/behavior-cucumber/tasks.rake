desc 'Run full cucumber test suite'
task :summarize_tests do |args|
	puts `cd ./2-test/behavior-cucumber; cucumber -si | perl -lne 'print $1 if /^(..*)$/'| sed 's/Feature: //' | sed 's/Scenario: //'`
end

task :run_tests do |args|
end
