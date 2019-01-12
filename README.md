**Automated CentOS Webuzo CSF MongoDB NVM/NodeJS Cloud9SDK Installation.**

The bash scripts in the setup automatically install and configure the following:

  - Install CSF from original source and apply Webuzo rules.
  - Change default SSH port
  - Cleanup Webuzo user/setup/leftover files that identify the user
  - Setup MongoDB and bind to publicIP
  - Setup NVM/NPM/NodeJS latest stable
  - Setup Cloud9SDK

All the installations are optional, you may refuse to setup while running the interactive cli. The scripts wich are under /setup run in the following order `install.sh` > `postinstall.sh` > `usersetup.sh`.

# To Start
```sh
wget -N https://raw.githubusercontent.com/jsEveryDay/CentOS-Config/master/setup/install.sh
chmod 0755 install.sh
./install.sh
```

#### <i class="icon-cog"></i>Create MySQL Admin User
```sh
mysql -u root -p"$(cat /var/webuzo/my.conf)"
SET @@session.old_passwords = 0;
SELECT @@session.old_passwords, @@global.old_passwords;
CREATE USER 'username'@'localhost' IDENTIFIED BY 'XXX';
CREATE USER 'username'@'%' IDENTIFIED BY 'XXX';
GRANT ALL PRIVILEGES ON *.* TO username @'localhost' IDENTIFIED BY 'XXX';
GRANT ALL PRIVILEGES ON *.* TO username @'%' IDENTIFIED BY 'XXX';
exit;
```

#### <i class="icon-refresh"></i>Continue User Setup
```sh
./usersetup.sh
```
 **Nginx Path**
```sh
/usr/local/apps/nginx
```
*/nginx-express* contains config for express server using port forwarding
*/nginx* contains config for normal host and port forwarding for Java Client websockets (chat).

**Config files**
/other/my.cnf > Great MySQL Config for heavy usage

```

License
----

MIT
