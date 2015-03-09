# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

public_policy = Hydra::AdminPolicy.create(id: 'authorities/policies/public', title: ["Public Access"])
public_policy.default_permissions.create(type: "group", name: "public", access: "read")
public_policy.save!
