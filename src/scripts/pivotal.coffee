# Get current stories from PivotalTracker
#
# You need to set the following variables:
#   HUBOT_PIVOTAL_TOKEN = <API token>
#HUBOT_PIVOTAL_TOKEN = "ddb2187632ade586c12fa4442b1055b8"
#
# If you're working on a single project, you can set it once:
#   HUBOT_PIVOTAL_PROJECT = <project name>
#
# Otherwise, include the project name in your message to Hubot.
#
# show me <state> stories for <project> -- shows stories for <project> that have <state> (unstarted,started,finished,delivered); ommit for all states.
# list all projects -- list all your (atm Simao's) projects
# ls projects -- alias for list all projects
#

module.exports = (robot) ->
  HARD_CODED_PIVOTAL_TOKEN="a1ed4421da846021e6fa9facb5f1b2c2"
  #robot.respond /show\s+(me\s+)?stories\s+(for\s+)?(.*)/i, (msg)->
  robot.respond /show\s+(me\s+)?(unstarted|started|finished|unfinished|delivered)?\s*stories\s+(for\s+)?(.*)/i, (msg)->
    Parser = require("xml2js").Parser
    #token = process.env.HUBOT_PIVOTAL_TOKEN
    token = HARD_CODED_PIVOTAL_TOKEN
    if msg.match[2] && msg.match[2] != ""
      state = msg.match[2]
    else
      state = "unstarted,started,finished,delivered"
    project_name = msg.match[5]
    if !project_name? || project_name == ""
      project_name = RegExp(process.env.HUBOT_PIVOTAL_PROJECT, "i")
    else
      project_name = RegExp(project_name + ".*", "i")

    msg.http("http://www.pivotaltracker.com/services/v3/projects").headers("X-TrackerToken": token).get() (err, res, body) ->
      if err
        msg.send "Pivotal says: #{err}"
        return
      (new Parser).parseString body, (err, json)->
        for the_project in json.project
          if project_name.test(the_project.name)
            msg.http("https://www.pivotaltracker.com/services/v3/projects/#{the_project.id}/stories").headers("X-TrackerToken": token).query(filter: "state:#{state}").get() (err, res, body) ->
              if err
                msg.send "Pivotal says: #{err}"
                return

              (new Parser).parseString body, (err, json)->
                for story in json.story
                  message = "##{story.id['#']} #{story.name}"
                  message += " (#{story.owned_by})" if story.owned_by
                  message += " is #{story.current_state}" if story.current_state && story.current_state != "unstarted"
                  msg.send message
            return
        msg.send "No project #{project_name}"

  robot.respond /(pivotal story)? (.*)/i, (msg)->
    Parser = require("xml2js").Parser
    token = process.env.HUBOT_PIVOTAL_TOKEN
    project_id = process.env.HUBOT_PIVOTAL_PROJECT
    story_id = msg.match[2]

    msg.http("http://www.pivotaltracker.com/services/v3/projects").headers("X-TrackerToken": token).get() (err, res, body) ->
      if err
        msg.send "Pivotal says: #{err}"
        return
      (new Parser).parseString body, (err, json)->
        for project in json.project
          msg.http("https://www.pivotaltracker.com/services/v3/projects/#{project.id}/stories/#{story_id}").headers("X-TrackerToken": token).get() (err, res, body) ->
            if err
              msg.send "Pivotal says: #{err}"
              return
            if res.statusCode != 500
              (new Parser).parseString body, (err, story)->
                if !story.id
                  return
                message = "##{story.id['#']} #{story.name}"
                message += " (#{story.owned_by})" if story.owned_by
                message += " is #{story.current_state}" if story.current_state && story.current_state != "unstarted"
                msg.send message
                storyReturned = true
                return
    return

  robot.respond /(ls|list all) projects/i, (msg) ->
    Parser = require("xml2js").Parser
    #token = process.env.HUBOT_PIVOTAL_TOKEN
    token = HARD_CODED_PIVOTAL_TOKEN
    msg.http("http://www.pivotaltracker.com/services/v3/projects").headers("X-TrackerToken":token).get() (err, res, body) ->
      if err
        msg.send "Pivotal says: #{err}"
        return
      (new Parser).parseString body, (err, json)->
        msg.send "Here are your projects:"
        for project in json.project
          message = "#{project.name} ; #{project.id}"
          msg.send message
    return

  robot.hear /wasup?/i, (msg) ->
    msg.send "notin"
    return
