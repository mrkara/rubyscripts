# This script gets the list of repos under a certain organization,
# and stars all of them.
# Purpose: To get all of your contributions listed on your profile.

# HOW TO RUN:
  # gem install octokit
  # ruby star_repos.rb

require 'octokit'
require 'io/console'

# Provide authentication credentials
print "Enter GitHub username: "
username = gets.chomp
print "Enter password: "
password = (STDIN.noecho(&:gets)).gsub("\n","")

# Provide the organization name
print "\nEnter organization name: "
org_name = gets.chomp

# Connect to GitHub
print "Connecting to GitHub..."
client = Octokit::Client.new(:login => username, :password => password)
print " Done!\n"
print "Getting repository list..."
# Get the list of repos under the organization
Octokit.auto_paginate = true
org_repos = Octokit.org_repos(org_name)
print " Done!\n"

# Start starring process
i = 0
for repo in org_repos
   i += 1
   puts i.to_s + ". " + org_name + " - " + repo.name + ": " + client.star(org_name + '/' + repo.name.to_s).to_s  # Star the next repo
end
