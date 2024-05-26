# MWT Share PHP Version

![Screenshot](screenshot.png)

This is a barebones PHP reimplementation of [the nullpointer](https://0x0.st/) file-sharing and link-shortening service by Mia Herkt. Unlike the original, this version is intended to be used on shared hosting and does not require a database. This version also does no file verification or filtering. It is not recommended to leave this service open to the public. The original version can be found [here](https://mwt.sh). Unlike the nullpointer, this version requires a username and password to upload files or shorten links.

## Installation

This project will only work on a web server that supports `.htaccess` files such as Apache or Litespeed. This project is not compatible with Nginx, caddy, or any server where `.htaccess` support is not enabled.

To install this project:

1. Clone this repository to your web server.
2. Run `./install.sh` to configure password authentication. You may rerun this script to change the password(s) or add additional users.
3. Symlink your document root to the `public_html` directory or move the contents of `public_html` to your document root.

## Removing Files

You can delete files manually from the `f` directory. There is no database to keep track of files. So, there is no additional cleanup required. Shortened URLs can be deleted by removing the corresponding folder in the `l` directory.

## CLI Usage

This project is fully compatible with command line tools that support nullpointer such as [pb](https://github.com/jamestomasino/pb). You can also use `curl` directly.

### HTTP POST files here

```bash
curl -F'file=@yourfile.png' https://user:pass@mwt.sh
```

### Or you can shorten URLs:

```bash
curl -F'shorten=https://www.matthewthom.as/' https://user:pass@mwt.sh
```
