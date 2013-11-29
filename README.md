# Appsignal Dashboard

http://matsimitsu.com/blog/2013/11/26/appsignnal-graphs.html

## Installation

`bundle` and run `middleman`

## Usage

All settings are given with the url.

* site_id (required) Id of the site you want to display
* token (required) Appsignal api token
* field (required) One of the following:
* * count troughput
* * pct 90th percentile
* * ex_rate exception rate
* * mean mean duration
* * qt queue time duration
* * qt_pct queue time 90th percentile
* * ex exception count (absolute number)
* postfix (optional) text behind the number
* subtitle (optional) text below the number
* background, background color
* foreground, foreground color

An example url is:

`http://appsignaldash.matsimitsu.com/index.html?site_id=[site_id]&field=count&token=[token]&postfix=RPM&subtitle=Troughput
`
