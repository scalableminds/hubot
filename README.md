# Hubot

## Install

*   Install native icu (`brew install icu4c`, `brew link icu4c --force` or `apt-get install libexpat1-dev libicu-dev`)
*   Install Redis (`brew redis` or `apt-get install redis-server`). 
*   Make sure to have `node` (Version >= 0.10). 
*   Get the scm `.env` file and put it in hubot's root directory.
*   Run `./start`


## Useful commands

*   `hubot update` – Have hubot update itself.
*   `hubot die` – Kill hubot. It's actually a restart.
*   `hubot set env SECRET="Beer is awesome."` – We don't push API keys and such to Github. So set them here. Make sure to restart hubot afterwards.
*   `hubot pug bomb 10` – Aren't they cute?
*   `hubot give me some love` – Isn't he stupid?


## Testing Hubot without Campfire

You can test your hubot by running the following.

    % bin/hubot
    
Keep in mind to export any needed environment variables manually or use `hubot set env`.

You'll see some start up output about where your scripts come from and a
prompt.

    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading adapter shell
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/scripts
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/src/scripts
    Hubot>

Then you can interact with hubot by typing `hubot help`.

    Hubot> hubot help

    Hubot> animate me <query> - The same thing as `image me`, except adds a few
    convert me <expression> to <units> - Convert expression to given units.
    help - Displays all of the help commands that Hubot knows about.
    ...

Take a look at the scripts in the `./scripts` folder for examples.
Delete any scripts you think are silly.  Add whatever functionality you
want hubot to have.

## hubot-scripts

There will inevitably be functionality that everyone will want. Instead
of adding it to hubot itself, you can submit pull requests to
[hubot-scripts][hubot-scripts].

To enable scripts from the hubot-scripts package, add the script name with
extension as a double quoted string to the `hubot-scripts.json` file in this
repo.

[hubot-scripts]: https://github.com/github/hubot-scripts

## external-scripts

Tired of waiting for your script to be merged into `hubot-scripts`? Want to
maintain the repository and package yourself? Then this added functionality
maybe for you!

Hubot is now able to load scripts from third-party `npm` packages! To enable
this functionality you can follow the following steps.

1. Add the packages as dependencies into your `package.json`
2. `npm install` to make sure those packages are installed

To enable third-party scripts that you've added you will need to add the package
name as a double quoted string to the `external-scripts.json` file in this repo.

