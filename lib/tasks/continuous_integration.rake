task :ci => ['db:setup', :test, :cucumber]
