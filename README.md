# change-host :metal:
While developing, we are always stuck with the tiresome edit of etc/hosts to map the redirecting dev IP to some.url.com.  Using this script below, you can do that using a single command using the CLI and save yourself some time. 
Something like `change-host myFavouriteIp`.

## Step-by-step guide
1. Go to the directory wherever you store your scripts and create a file to whatever name you want the command to be.
   ```sh
    cd ~/workspace/scripts
    vim change-host
    ```
2. (For Mac users) Install `gsed` the mac alternative for `sed` which actually does the job for find and replace
    ```sh
    brew install gsed
    ```
3. Copy and paste this piece of code to the file created which you can also find in this repository itself [change-host.sh](https://github.com/mohitvirli/change-host/blob/master/change-host.sh). 
    > NOTE: Replace `URL` inside the script to actually redirect it to the url you want to redirect to. By default it is some.url.com. 

    ```sh
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
    ```
4. Make this file an executable.
    ```sh
    chmod +x change-host
    ```
5. Add the path to the scripts folder in the PATH variable wherever you are exporting it (.bash_profile/.zshrc etc)
    ```sh
    export PATH=$HOME/workspace/scripts:$PATH
 
    source .bash_profile
    ```
6. YOU ARE GOOD TO GO :metal:

# How to use
Since everyone must be having a different kind of etc/hosts, I have made the script according to how I manage my etc/hosts. Here is how it looks like for me.
> Note the comments above the IPs (**Me, aliasName, theOne**) which would come in handy later.
```sh
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
 
# Me
# 10.2.102.54 redir.dev.com
 
# aliasName
# 10.2.148.86 redir.dev.com
 
# theOne
10.2.200.76 redir.dev.com
 
# 10.2.148.83 redir.dev.com
# 10.2.420.69 redir.dev.com
```

> Note I have set my `URL` to redir.dev.com inside the `change-host` file

* Using it with an existing IP (would comment every other except the provided one)
    ```sh
    change-host 10.2.102.54
    ```
* Using it with an alias (ex- Me, aliasName, theOne etc..)
    ```
    change-host aliasName
    ```
* Adding a new IP without an alias
    ```sh
    change_host 10.10.10.10
    ```
* (Recommended) Adding a new IP with an Alias so that it can be used later.
    ```sh
    change_host 10.10.10.10 newRedirect
    ```
    *Later you can use it like this.* `change_host newRedirect`

> Note: This uses sudo internally cause you know how etc/host is. So you would be asked to enter the password. 

# TODOs
- [ ] Add support for removal
- [ ] Add support for passing the redirect url inside the CLI.
