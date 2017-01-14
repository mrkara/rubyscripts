#!/usr/bin/ruby -w
# This script imports bugzilla bug reports from an xml file
# to github issues.

# HOW TO RUN:
  # gem install octokit xmlsimple
  # ruby import_issues_from_bugzilla.rb

require 'octokit'
require 'xmlsimple'

# Provide authentication credentials
# GitHub username
username = ''
# GitHub password or access token
password = ''
# GitHub projects full name: (like 'mrkara/gtranslator')"
repo = ""
# Location of the xml input file on your disk
xmlFile = '.xml'
# Main URL of the bugzilla without the trailing slash (/)
bgzUrl = "https://"
# Bugzilla acronym (like 'bgo' for 'bugzilla.gnome.org')
acro = "bgo"
# Anti-abuse delays (in seconds)
shortDelay = 2
longDelay = 15

################################################################################

# Read the input file
print "Reading the XML file...... "
xmlDoc = XmlSimple.xml_in(xmlFile)
if xmlDoc.nil?
	print "Failed!\n"
	puts "Please check the content and the location of the input file."
end
print "Success!\n"

# Connect to GitHub
print "Connecting to GitHub...... "
client = Octokit::Client.new(:login => username, :password => password)
print "Success!\n"

puts "Total number of bugs to be imported: " + xmlDoc["bug"].count.to_s

# Create issues
total_issues = 0
total_comments = 0
xmlDoc["bug"].each do |bug|
	print "\rCreating the next issue....."
	### Prepare the issue
	title = "[" + acro + "#" + bug["bug_id"][0] + "] " + bug["short_desc"][0]

	body = bug["long_desc"][0]["thetext"][0]
	body += "\n\nOriginally reported by "
	unless bug["reporter"][0]["name"].nil?
		body += bug["reporter"][0]["name"]
	end
	body += " at " + bgzUrl + "/show_bug.cgi?id=" + bug["bug_id"][0]

	label = "bug"
	label = "enhancement" if bug["bug_severity"][0] == "enhancement"

	### Create the issue
	issue = client.create_issue(repo, title, body, {:labels => label})
	issueNum = issue.to_hash[:number]
	sleep(shortDelay)

	### Post the comments
	commentCount = 0
	bug["long_desc"].each do |comment|
		# Skip the bug description
		if comment["comment_count"][0] == "0"
			next
		end

		commentMsg = comment["thetext"][0]
		commentMsg += "\n\nOriginally posted by " + comment["who"][0]["name"]

		# Add attachment if any
		unless comment["attachid"].nil?
			attachUrl = bgzUrl + "/attachment.cgi?id=" + comment["attachid"][0]
			commentMsg += "\n\n Attachment: " + attachUrl
		end

		client.add_comment(repo, issueNum, commentMsg)
		commentCount += 1
		total_comments += 1
		sleep(shortDelay)
	end

	puts "\rIssue#" + issueNum.to_s + " has been created successfully with " + commentCount.to_s + " comments."
	total_issues += 1

	# Sleep longDelay seconds to avoid GitHub's API abuse detection
	print "Cooling the GitHub API......"
	sleep(longDelay)
end

puts total_issues.to_s + " issues have been created successfully."
puts total_comments.to_s + " comments have been posted in total."
