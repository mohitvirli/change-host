ETC_HOSTS=/etc/hosts
ipRegex=^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$

ARG=$1
ALIAS=$2

# Put the URL here to redirect the specified IP. (ex - redir.dev.com)
URL=some.url.com

# Prepends every uncommented URL
comment_redir () { sudo gsed -i "/^[^#].*$URL/s/^/# /g" $ETC_HOSTS; }

if [ -n "$(sudo grep -w $ARG $ETC_HOSTS)" ]
    then
    comment_redir
    if [[ $ARG =~ $ipRegex ]]
        then
        echo "$ARG is now $URL"
        sudo gsed -i "s/# $ARG/$ARG/g" $ETC_HOSTS
    else
        echo "Redirecting to IP marked with $ARG"
        sudo gsed -i "/$ARG/{n;s/# //}" $ETC_HOSTS
    fi
else
    if ! [[ $ARG =~ $ipRegex ]]
        then
        echo "Cannot find any reference to $ARG"
    elif [ -n "$ALIAS" ]
        then
        comment_redir
        sudo printf "\n# $ALIAS\n$ARG $URL" | sudo tee -a $ETC_HOSTS
    else
        comment_redir
        sudo printf "\n$ARG $URL" | sudo tee -a $ETC_HOSTS
    fi
fi
