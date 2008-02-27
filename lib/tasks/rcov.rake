namespace :test do
  desc 'Delete coverage files'
  task 'coverage:clean' do
    rm_rf 'coverage'
  end


  desc 'Generate coverage files'
  task :coverage => 'test:coverage:clean' do
    sh 'rcov --rails spec/**/*_spec.rb test/**/*_test.rb'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
