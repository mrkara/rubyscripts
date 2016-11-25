# This script gets the list of repos under a certain organization,
# and stars all of them. Purpose: To get all of your contributions listed on your profile.

# HOW TO RUN:
  # gem install octokit
  # ruby star_repos.rb

require 'octokit'

# Provide authentication credentials
client = Octokit::Client.new(:login => 'your_github_user_name', :password => 'your_github_password')

# Provide the organization name
org_name = 'OrganizationName'

# Get the list of repos under the organization
Octokit.auto_paginate = true
org_repos = Octokit.org_repos(org_name)

i = 0
for repo in org_repos
   i += 1
   puts i.to_s + ". " + repo.name + ": " + client.star(org_name + '/' + repo.name.to_s).to_s  # Star the next repo
end
