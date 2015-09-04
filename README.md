# mysql_community Cookbook

This cookbook is a wrapper for the [mysqld](https://github.com/chr4-cookbooks/mysqld)
cookbook, and is specifically tuned to install and configure Oracle MySQL Community
Edition.

Additionals provided with this cookbook:
* Logrotate template to rotate logs specified in my.cnf
* Set root password via node run_state or node attribute
* On non-debian, stores root password in /root/.my.cnf for logrotate and to
prevent password change race condition.
