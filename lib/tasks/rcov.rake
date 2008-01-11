namespace :test do
  namespace :coverage do
    desc "Delete coverage files"
    task :clean do
      rm_rf "coverage"
    end
  end

  desc "Generage coverage files"
  task :coverage => "test:coverage:clean" do
    sh "rcov -x __sandbox -x /usr/local -x /var/lib/gems -x spec --rails spec/**/*_spec.rb test/**/*_test.rb"
  end
end
