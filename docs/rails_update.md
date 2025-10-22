### How to update Rails version? (Container)

- make rails-starts
- cd ~
- gem install rails -v 8.1
- rails new RailsApp --force --skip-bundle --skip-git
- cd RailsApp
- bundle install
- bundle exec rails db:create
