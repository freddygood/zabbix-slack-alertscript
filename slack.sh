#!/bin/bash

# Slack incoming web-hook URL and user name
url='CHANGEME'		# example: https://hooks.slack.com/services/QW3R7Y/D34DC0D3/BCADFGabcDEF123
username='Zabbix'

## Values received by this script:
# To = $1 (Slack channel or user to send the message to, specified in the Zabbix web interface; "@username" or "#channel")
# Subject = $2 (usually either PROBLEM or RECOVERY)
# Message = $3 (whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")

# Get the Slack channel or user ($1) and Zabbix subject ($2 - hopefully either PROBLEM or RECOVERY)
to="$1"
subject="$2"
message="$3"

# Change message emoji depending on the subject - smile (RECOVERY), frowning (PROBLEM), or ghost (for everything else)

problemsub='^PROBLEM'
recoversub='^(RECOVER(Y|ED)?|OK)'

if [[ "$subject" =~ ${recoversub} ]]; then
	emoji=':sweat_smile:'
	color='good'
elif [[ "$subject" =~ ${problemsub} ]]; then
	emoji=':scream:'
	color='danger'
else
	emoji=':robot_face:'
	color='warning'
fi

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL

payload="payload={
        \"channel\": \"${to//\"/\\\"}\",
        \"username\": \"${username//\"/\\\"}\",
        \"icon_emoji\": \"${emoji}\",
        \"parse\": \"full\",
        \"attachments\": [{
                \"title\": \"${subject//\"/\\\"}\",
                \"title_link\": \"http://zabbix32.zvq.me/\",
                \"text\": \"${message//\"/\\\"}\",
                \"color\": \"${color}\"
        }],
}"

curl -m 5 --data-urlencode "${payload}" $url -A 'zabbix-slack-alertscript / https://github.com/ericoc/zabbix-slack-alertscript'
