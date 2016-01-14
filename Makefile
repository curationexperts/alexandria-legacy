.PHONY: prod rubocop spec vagrant

prod:
	REPO=ssh://git@stash.library.ucsb.edu:7999/dr/adrl-v2.git bundle exec cap production deploy

rubocop:
	rubocop --format simple --config .rubocop.yml --auto-correct

spec:
	RAILS=test bundle exec rspec

vagrant:
	SERVER=127.0.0.1 REPO=/vagrant/alex2 bundle exec cap vagrant deploy
